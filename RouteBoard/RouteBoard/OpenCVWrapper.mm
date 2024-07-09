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


const float DROP_INPUTFRAME_FACTOR = 0.5f;
const float MAX_RESOLUTION_PX = 480.0f;
const float LOWES_RATIO_LAW = 0.7f;
const unsigned long MIN_MATCH_COUNT = 10;
const int AREA_OF_INTEREST_AROUND_LINE = 75;

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
        
        matcher->add(routeDescriptors);
        
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

+ (CVMap *) detectRoutesAndAddOverlay:(ProcessedSamplesSwift*)processedSamples inputFrame:(UIImage *) inputFrame {
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
        return cv_map;
    }
    
    
    std::vector< std::vector<cv::DMatch> > knn_matches;
    
    matcher->knnMatch(frameDescriptors, knn_matches, 2);
    
    std::map<int, std::vector<std::pair<cv::Point2f, cv::Point2f>>> matchesMap;
    std::vector<cv::Point2f> srcPts, dstPts;
    for (size_t j = 0; j < knn_matches.size(); j++) {
        if (knn_matches[j][0].distance < LOWES_RATIO_LAW * knn_matches[j][1].distance) {
            cv::Point2f *bestPoint = new cv::Point2f(processedSamples.processedSamples[knn_matches[j][0].imgIdx].referenceKP[knn_matches[j][0].trainIdx].pt.x, processedSamples.processedSamples[knn_matches[j][0].imgIdx].referenceKP[knn_matches[j][0].trainIdx].pt.y);
            matchesMap[knn_matches[j][0].imgIdx].push_back(std::make_pair(*bestPoint, frameKeypoints[knn_matches[j][0].queryIdx].pt));
        }
    }
    
    knn_matches.clear();
    
    for (auto& match : matchesMap) {
        if (match.second.size() >= MIN_MATCH_COUNT) {
            std::vector<cv::Point2f> srcPts;
            std::vector<cv::Point2f> dstPts;
            
            for (auto& p : match.second) {
                srcPts.push_back(p.first);
                dstPts.push_back(p.second);
            }
            
            cv::Mat H = cv::findHomography(srcPts, dstPts, cv::RANSAC, 5.0);
            
            if (!H.empty() && H.rows == 3 && H.cols == 3) {
                cv::Mat routeMatrix;
                UIImageToMat(processedSamples.processedSamples[match.first].routeReference, routeMatrix);
                
                cv::Mat overlay;
                cv::warpPerspective(routeMatrix, overlay, H, cv::Size(frameCols, frameRows));
                
                frameOutput += overlay;
                overlay.release();
                routeMatrix.release();
            }
            
            srcPts.clear();
            dstPts.clear();
            H.release();
        }
    }
    
    
    frameMatrix.release();
    NSData *data = [[NSData alloc] initWithBytes:frameOutput.data length:frameOutput.u->size];
    CVMap *cv_map = [[CVMap alloc] initWithRows:frameOutput.rows cols:frameOutput.cols type:frameOutput.type() data:data step:frameOutput.step];
    frameOutput.release();
    return cv_map;
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
