//
//  OpenCVWrapper.m
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 29.06.2024..
//

#ifdef __cplusplus

#import <opencv2/opencv.hpp>
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/features2d.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "OpenCVWrapper.h"
#import "RouteBoard-Swift.h"


const float DROP_INPUTFRAME_FACTOR = 0.75f;
const float MAX_RESOLUTION_PX = 600.0f;
const float LOWES_RATIO_LAW = 0.7f;
const unsigned long MIN_MATCH_COUNT = 10;
const int AREA_OF_INTEREST_AROUND_LINE = 75;
const bool REUSE_OLD_OVERLAY = true;
const int SKIP_FRAMES = 3;
int frame_counter = 0;
OverlayAndRouteId *old_overlay;

std::vector<cv::Vec4i> detectLines(cv::Mat image) {
    cv::Mat gray;
    cvtColor(image, gray, cv::COLOR_BGR2GRAY);
    
    cv::Mat blur;
    cv::GaussianBlur(gray, blur, cv::Size(5, 5), 0);
    
    cv::Mat edges;
    Canny(blur, edges, 50, 150, 3);
    
    std::vector<cv::Vec4i> lines;
    HoughLinesP(edges, lines, 10, CV_PI / 180, 10, 0, 100);
    
    gray.release();
    blur.release();
    edges.release();
    
    return lines;
}

cv::Mat createMaskFromLines(std::vector<cv::Vec4i> lines, cv::Size imageSize) {
    cv::Mat mask = cv::Mat::zeros(imageSize, CV_8UC1);
    
    for (size_t i = 0; i < lines.size(); i++) {
        cv::Vec4i l = lines[i];
        cv::line(mask, cv::Point(l[0], l[1]), cv::Point(l[2], l[3]), cv::Scalar(255), AREA_OF_INTEREST_AROUND_LINE);
    }
    
    return mask;
}

void maximizeHueSaturationEfficient(cv::Mat& image) {
    // TODO: this is wrong
    if (image.empty()) {
        std::cout << "Image is empty." << std::endl;
        return;
    }
    
    cv::Mat hsvImage;
    cv::cvtColor(image , hsvImage, cv::COLOR_RGB2HSV);

    cv::Mat mask;  // red is on the left side of the [0..180] hue range
    cv::inRange(hsvImage, cv::Scalar(0,50,50), cv::Scalar(30,255,255), mask);

    cv::Mat maskRgb; // make a 3channel mask
    cv::cvtColor(mask, maskRgb, cv::COLOR_GRAY2RGB);
    
    bitwise_and(image, maskRgb, image);
}


std::mutex mtx;

@implementation OpenCVWrapper

cv::Ptr<cv::FlannBasedMatcher> matcher = cv::FlannBasedMatcher::create();

+ (NSString *)getOpenCVVersion {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

+ (ProcessedSamplesSwift*) processInputSamples:(ImportSamplesSwift*)samples {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:samples.samples.count];
    cv::Ptr<cv::SIFT> siftPtr = cv::SIFT::create();
    matcher->clear();
    
    for (int i = 0; i<samples.samples.count; i++) {
        cv::Mat routeImageMatrix;
        cv::Mat resizedRouteImageMatrix;
        
        cv::Mat pathImageMatrix;
        cv::Mat resizedPathImageMatrix;
        
        UIImageToMat(samples.samples[i].route, routeImageMatrix);
        UIImageToMat(samples.samples[i].path, pathImageMatrix);
        
        float resizeFactor = MAX_RESOLUTION_PX / MAX(routeImageMatrix.rows, routeImageMatrix.cols);
        
        cv::resize(routeImageMatrix, resizedRouteImageMatrix, cv::Size(), resizeFactor, resizeFactor);
        cv::resize(pathImageMatrix, resizedPathImageMatrix, cv::Size(), resizeFactor, resizeFactor);
        
        routeImageMatrix.release();
        pathImageMatrix.release();
        
        std::vector<cv::KeyPoint> routeKeypoints;
        cv::Mat routeDescriptors;
        cv::Mat mask = createMaskFromLines(detectLines(resizedPathImageMatrix), resizedPathImageMatrix.size());
        
        if (mask.empty()) NSLog(@"mask is empty for routeId: %d", samples.samples[i].routeId);
        
        // Potentially would be usefully to mask only around the line
        siftPtr->detectAndCompute(resizedRouteImageMatrix, cv::noArray(), routeKeypoints, routeDescriptors);
        
        unsigned long keypointsCount = routeKeypoints.size();
        NSMutableArray *keypointsArray = [NSMutableArray arrayWithCapacity:keypointsCount];
        for (int j = 0; j < keypointsCount; ++j) {
            KeyPoint *keypoint = [[KeyPoint alloc] initWithX:routeKeypoints[j].pt.x y:routeKeypoints[j].pt.y size:routeKeypoints[j].size angle:routeKeypoints[j].angle response:routeKeypoints[j].response octave:routeKeypoints[j].octave class_id:routeKeypoints[j].class_id];
            [keypointsArray insertObject:keypoint atIndex:keypointsArray.count];
        }
        
        if (keypointsCount == 0 || routeDescriptors.empty()) {
            NSLog(@"keypoints or descriptor empty for routeId: %d", samples.samples[i].routeId);
            continue;
        }
        
        NSData *data = [[NSData alloc] initWithBytes:routeDescriptors.data length:routeDescriptors.u->size];
        CVMap *cv_map = [[CVMap alloc] initWithRows:routeDescriptors.rows cols:routeDescriptors.cols type:routeDescriptors.type() data:data step:routeDescriptors.step];
        
        ProcessedSample *processedSample = [[ProcessedSample alloc] initWithReferenceKP:keypointsArray referenceDES:cv_map routeReference:MatToUIImage(resizedPathImageMatrix) routeId:samples.samples[i].routeId];
        
        [array insertObject:processedSample atIndex:array.count];
    }
    
    return [[ProcessedSamplesSwift alloc] initWithProcessedSamples:array];
}

+ (OverlayAndRouteId *) detectRoutesAndAddOverlay:(ProcessedSamplesSwift*)processedSamples inputFrame:(UIImage *) inputFrame {
    if (REUSE_OLD_OVERLAY) {
        mtx.lock();
        if (frame_counter % SKIP_FRAMES != 0 && old_overlay) {
            frame_counter = (frame_counter + 1) % SKIP_FRAMES;
            mtx.unlock();
            return old_overlay;
        }
        
        frame_counter = (frame_counter + 1) % SKIP_FRAMES;
        mtx.unlock();
    }
    
    cv::Ptr<cv::SIFT> siftPtr = cv::SIFT::create();
    
    cv::Mat frameMatrix;
    UIImageToMat(inputFrame, frameMatrix);
    
    cv::Mat resizedframeMatrix;
    cv::resize(frameMatrix, resizedframeMatrix, cv::Size(), DROP_INPUTFRAME_FACTOR, DROP_INPUTFRAME_FACTOR);
    
    cv::Mat frameOutput = cv::Mat::zeros(resizedframeMatrix.rows, resizedframeMatrix.cols, resizedframeMatrix.type());
    
    std::vector<cv::KeyPoint> frameKeypoints;
    cv::Mat frameDescriptors;
    
    siftPtr->detectAndCompute(resizedframeMatrix, cv::noArray(), frameKeypoints, frameDescriptors);
    
    int frameRows = resizedframeMatrix.rows;
    int frameCols = resizedframeMatrix.cols;
    
    resizedframeMatrix.release();
    
    if (frameKeypoints.size() < 3 || frameDescriptors.empty()) {
        NSData *data = [[NSData alloc] initWithBytes:frameOutput.data length:frameOutput.u->size];
        CVMap *cv_map = [[CVMap alloc] initWithRows:frameOutput.rows cols:frameOutput.cols type:frameOutput.type() data:data step:frameOutput.step];
        return [[OverlayAndRouteId alloc] initWithOverlay:cv_map routeId:-1];
    }
    
    double minDistance = std::numeric_limits<double>::max();
    int closestRouteId = -1;
    cv::Mat closestOverlay;
    
    int centerX = frameCols / 2;
    int centerY = frameRows / 2;
    cv::Point2f frameCenter(centerX, centerY);
    
    std::vector< std::vector<cv::DMatch> > knn_matches;
    
    for (int i = 0; i<processedSamples.processedSamples.count; i++) {
        unsigned char *bytes = (unsigned char *) processedSamples.processedSamples[i].referenceDES.data.bytes;
        
        cv::Mat *descriptor = new cv::Mat(processedSamples.processedSamples[i].referenceDES.rows, processedSamples.processedSamples[i].referenceDES.cols, processedSamples.processedSamples[i].referenceDES.type, bytes);
        std::vector< std::vector<cv::DMatch> > knn_matches;
        
        matcher->knnMatch(*descriptor, frameDescriptors, knn_matches, 2);
        
        descriptor->release();
        
        int numberOfGoodPoints = 0;
        std::vector<cv::Point2f> srcPts, dstPts;
        for (size_t j = 0; j < knn_matches.size(); j++) {
            if (knn_matches[j][0].distance < LOWES_RATIO_LAW * knn_matches[j][1].distance) {
                numberOfGoodPoints++;
                cv::Point2f *bestPoint = new cv::Point2f(processedSamples.processedSamples[i].referenceKP[knn_matches[j][0].queryIdx].pt.x, processedSamples.processedSamples[i].referenceKP[knn_matches[j][0].queryIdx].pt.y);
                srcPts.push_back(*bestPoint);
                dstPts.push_back(frameKeypoints[knn_matches[j][0].trainIdx].pt);
            }
        }
        
        knn_matches.clear();
        
        if (numberOfGoodPoints > MIN_MATCH_COUNT) {
            cv::Mat srcMat = cv::Mat(srcPts);
            cv::Mat dstMat = cv::Mat(dstPts);
            cv::Mat H = cv::findHomography(srcMat, dstMat, cv::RANSAC, 5.0);
            
            srcMat.release();
            dstMat.release();
            srcPts.clear();
            dstPts.clear();
            
            if (!H.empty() && H.rows == 3 && H.cols == 3) {
                
                std::vector<cv::Point2f> transformedCenter(1);
                cv::perspectiveTransform(std::vector<cv::Point2f>{frameCenter}, transformedCenter, H.inv());
                
                cv::Mat routeMatrix;
                UIImageToMat(processedSamples.processedSamples[i].routeReference, routeMatrix);
                
                cv::Point2f routeReferencePoint(routeMatrix.cols / 2.0f, routeMatrix.rows / 2.0f);
                double distance = cv::norm(transformedCenter[0] - routeReferencePoint);
                
                cv::Mat overlay;
                cv::warpPerspective(routeMatrix, overlay, H, cv::Size(frameCols, frameRows));
                
                if (distance < minDistance) {
                    minDistance = distance;
                    if (!closestOverlay.empty()) {
                        frameOutput += closestOverlay;
                    }
                    closestOverlay = overlay;
                    closestRouteId = processedSamples.processedSamples[i].routeId;
                } else {
                    frameOutput += overlay;
                    overlay.release();
                }
                
                routeMatrix.release();
            }
            
            srcPts.clear();
            dstPts.clear();
            H.release();
        }
    }
    
    
    if (!closestOverlay.empty()) {
        // maximizeHueSaturationEfficient(closestOverlay);
        frameOutput += closestOverlay;
    }
    
    
    frameMatrix.release();
    NSData *data = [[NSData alloc] initWithBytes:frameOutput.data length:frameOutput.u->size];
    CVMap *cv_map = [[CVMap alloc] initWithRows:frameOutput.rows cols:frameOutput.cols type:frameOutput.type() data:data step:frameOutput.step];
    frameOutput.release();
    old_overlay = [[OverlayAndRouteId alloc] initWithOverlay:cv_map routeId:closestRouteId];
    return old_overlay;
}

+ (UIImage *) addOverlayToFrame:(UIImage *)inputFrame overlay:(CVMap *) overlay {
    unsigned char *bytes = (unsigned char *) overlay.data.bytes;
    cv::Mat *overlayMatrix = new cv::Mat(overlay.rows, overlay.cols, overlay.type, bytes);
    
    cv::Mat frameMatrix;
    UIImageToMat(inputFrame, frameMatrix);
    
    cv::resize(*overlayMatrix, *overlayMatrix, cv::Size(frameMatrix.cols, frameMatrix.rows), 0, 0, cv::INTER_CUBIC);
    cv::addWeighted(frameMatrix, 1, *overlayMatrix, 1, 0, frameMatrix);
    
    overlayMatrix->release();
    
    return MatToUIImage(frameMatrix);
}

+ (CVMap *) convertImageToMat:(UIImage *)image {
    cv::Mat matImage;
    UIImageToMat(image, matImage);
    
    NSData *data = [[NSData alloc] initWithBytes:matImage.data length:matImage.u->size];
    CVMap *cv_mat = [[CVMap alloc] initWithRows:matImage.rows cols:matImage.cols type:matImage.type() data:data step:matImage.step];
    
    return cv_mat;
}

+ (UIImage *) convertMatToImage:(CVMap *)mat {
    unsigned char *bytes = (unsigned char *) mat.data.bytes;
    cv::Mat *overlayMatrix = new cv::Mat(mat.rows, mat.cols, mat.type, bytes);
    
    return MatToUIImage(*overlayMatrix);
}

+ (UIImage *) createRouteLineImage:(RoutePoints *)points picture:(CVMap *) picture {
    cv::Mat lineMat = cv::Mat::zeros(picture.rows, picture.cols, picture.type);
    
    for (NSInteger i = 0; i < points.points.count - 1; i++) {
        Point2d *pt1 = points.points[i];
        Point2d *pt2 = points.points[i + 1];
        
        cv::Point point1(pt1.x, pt1.y);
        cv::Point point2(pt2.x, pt2.y);
        
        cv::line(lineMat, point1, point2, cv::Scalar(100,100, 0,255), 25);
    }
    
    return MatToUIImage(lineMat);
}

@end

#endif
