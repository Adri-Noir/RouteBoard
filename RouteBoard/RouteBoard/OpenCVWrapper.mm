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


const float DROP_INPUTFRAME_FACTOR = 0.3f;
const float MAX_RESOLUTION_PX = 500.0f;
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

+ (NSString *)getOpenCVVersion {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

+ (ProcessedSamplesSwift*) processInputSamples:(ImportSamplesSwift*)samples {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:samples.samples.count];
    cv::Ptr<cv::SIFT> siftPtr = cv::SIFT::create();
    
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
        siftPtr->detectAndCompute(resizedRouteImageMatrix, mask, routeKeypoints, routeDescriptors);
        
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
    
    cv::Mat frameOutput = cv::Mat::zeros(frameMatrix.rows, frameMatrix.cols, frameMatrix.type());
    
    std::vector<cv::KeyPoint> frameKeypoints;
    cv::Mat frameDescriptors;
    
    // Potentially would be usefully to mask only around the line
    siftPtr->detectAndCompute(resizedframeMatrix, cv::noArray(), frameKeypoints, frameDescriptors);
    
    int frameRows = resizedframeMatrix.rows;
    int frameCols = resizedframeMatrix.cols;
    
    resizedframeMatrix.release();
    
    if (frameKeypoints.size() < 3 || frameDescriptors.empty()) {
        NSData *data = [[NSData alloc] initWithBytes:frameOutput.data length:frameOutput.u->size];
        CVMap *cv_map = [[CVMap alloc] initWithRows:frameOutput.rows cols:frameOutput.cols type:frameOutput.type() data:data step:frameOutput.step];
        return cv_map;
    }
    
    // would potentially be usefull to use flann based explicitly
    cv::Ptr<cv::FlannBasedMatcher> matcher = cv::FlannBasedMatcher::create();
    
    // there is an add method for the matcher which could be usefull for something, check later
    
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
            
            if (H.rows != 3 || H.cols != 3) continue;
            
            cv::Mat routeMatrix;
            UIImageToMat(processedSamples.processedSamples[i].routeReference, routeMatrix);

            cv::Mat overlay;
            cv::warpPerspective(routeMatrix, overlay, H, cv::Size(frameCols, frameRows));
            cv::resize(overlay, overlay, cv::Size(frameMatrix.cols, frameMatrix.rows), 0, 0, cv::INTER_CUBIC);
            
            routeMatrix.release();
            H.release();

            frameOutput += overlay;
            // cv::addWeighted(frameOutput, 1, overlay, 1, 0, frameOutput);
            overlay.release();
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

@end

#endif
