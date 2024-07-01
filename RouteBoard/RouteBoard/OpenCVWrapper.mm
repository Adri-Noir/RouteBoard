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


const float DROP_RESOLUTION_FACTOR = 0.08f;
const float UPSCALE_FACTOR = 1/DROP_RESOLUTION_FACTOR;
const float LOWES_RATIO_LAW = 0.7f;
const unsigned long MIN_MATCH_COUNT = 10;


/*
 * add a method convertToMat to UIImage class
 */
@interface UIImage (OpenCVWrapper)
- (void)convertToMat: (cv::Mat *)pMat: (bool)alphaExists;
@end

@implementation UIImage (OpenCVWrapper)

- (void)convertToMat: (cv::Mat *)pMat: (bool)alphaExists {
    return;
}
@end

@implementation OpenCVWrapper

+ (NSString *)getOpenCVVersion {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

+ (UIImage *)grayscaleImg:(UIImage *)image {
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    cv::Mat gray;

    if (mat.channels() > 1 && !mat.empty()) {
        cv::cvtColor(mat, gray, cv::COLOR_RGB2GRAY);
    } else {
        mat.copyTo(gray);
    }

    UIImage *grayImg = MatToUIImage(gray);
    return grayImg;
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
        cv::resize(routeImageMatrix, resizedRouteImageMatrix, cv::Size(), DROP_RESOLUTION_FACTOR, DROP_RESOLUTION_FACTOR);
        
        UIImageToMat(samples.samples[i].path, pathImageMatrix);
        cv::resize(pathImageMatrix, resizedPathImageMatrix, cv::Size(), DROP_RESOLUTION_FACTOR, DROP_RESOLUTION_FACTOR);
    
        routeImageMatrix.release();
        pathImageMatrix.release();
        
        
        std::vector<cv::KeyPoint> routeKeypoints;
        cv::Mat routeDescriptors;
        
        // Potentially would be usefully to mask only around the line
        siftPtr->detectAndCompute(resizedRouteImageMatrix, cv::noArray(), routeKeypoints, routeDescriptors);
        
        unsigned long keypointsCount = routeKeypoints.size();
        NSMutableArray *keypointsArray = [NSMutableArray arrayWithCapacity:keypointsCount];
        for (int j = 0; j < keypointsCount; ++j) {
            KeyPoint *keypoint = [[KeyPoint alloc] initWithX:routeKeypoints[j].pt.x y:routeKeypoints[j].pt.y size:routeKeypoints[j].size angle:routeKeypoints[j].angle response:routeKeypoints[j].response octave:routeKeypoints[j].octave class_id:routeKeypoints[j].class_id];
            [keypointsArray insertObject:keypoint atIndex:j];
        }
        
        NSData *data = [[NSData alloc] initWithBytes:routeDescriptors.data length:routeDescriptors.u->size];
        CVMap *cv_map = [[CVMap alloc] initWithRows:routeDescriptors.rows cols:routeDescriptors.cols type:routeDescriptors.type() data:data step:routeDescriptors.step];
        
        if (keypointsCount == 0 || routeDescriptors.empty()) {
            NSLog(@"keypoints or descriptor empty");
            continue;
        }
        
        ProcessedSample *processedSample = [[ProcessedSample alloc] initWithReferenceKP:keypointsArray referenceDES:cv_map routeReference:MatToUIImage(resizedPathImageMatrix) routeId:samples.samples[i].routeId];
        
        [array insertObject:processedSample atIndex:i];
    }
    
    return [[ProcessedSamplesSwift alloc] initWithProcessedSamples:array];
}

+ (UIImage *) detectRoutesAndAddOverlay:(ProcessedSamplesSwift*)processedSamples inputFrame:(UIImage *) inputFrame {
    cv::Ptr<cv::SIFT> siftPtr = cv::SIFT::create();
    
    cv::Mat frameMatrix;
    
    UIImageToMat(inputFrame, frameMatrix);
    
    cv::Mat resizedframeMatrix;
    cv::resize(frameMatrix, resizedframeMatrix, cv::Size(), 0.1f, 0.1f);
    
    std::vector<cv::KeyPoint> frameKeypoints;
    cv::Mat frameDescriptors;
    
    // Potentially would be usefully to mask only around the line
    siftPtr->detectAndCompute(resizedframeMatrix, cv::noArray(), frameKeypoints, frameDescriptors);
    
    int frameRows = resizedframeMatrix.rows;
    int frameCols = resizedframeMatrix.cols;
    
    resizedframeMatrix.release();
    
    if (frameKeypoints.size() < 3 || frameDescriptors.empty()) return inputFrame;
    
    // would potentially be usefull to use flann based explicitly
    // cv::Ptr<cv::DescriptorMatcher> matcher = cv::DescriptorMatcher::create(cv::DescriptorMatcher::FLANNBASED);
    cv::Ptr<cv::FlannBasedMatcher> matcher = cv::FlannBasedMatcher::create();
    
    // there is an add method for the matcher which could be usefull for something, check later
    
    int bestRouteIndex = -1;
    unsigned long mostMatches = 0;
    std::vector<cv::DMatch> best;
    
    for (int i = 0; i<processedSamples.processedSamples.count; i++) {
        unsigned char *bytes = (unsigned char *) processedSamples.processedSamples[i].referenceDES.data.bytes;
        
        cv::Mat *descriptor = new cv::Mat(processedSamples.processedSamples[i].referenceDES.rows, processedSamples.processedSamples[i].referenceDES.cols, processedSamples.processedSamples[i].referenceDES.type, bytes);
        std::vector< std::vector<cv::DMatch> > knn_matches;
        
        matcher->knnMatch(*descriptor, frameDescriptors, knn_matches, 2);
        
        descriptor->release();
        
        std::vector<cv::DMatch> good_matches;
        for (size_t j = 0; j < knn_matches.size(); j++) {
            if (knn_matches[j][0].distance < LOWES_RATIO_LAW * knn_matches[j][1].distance) {
                good_matches.push_back(knn_matches[j][0]);
            }
        }
        
        knn_matches.clear();
        
        if (good_matches.size() > mostMatches) {
            mostMatches = good_matches.size();
            bestRouteIndex = i;
            best = good_matches;
        }
    }
    
    frameDescriptors.release();
    matcher.release();
    siftPtr.release();
    
    if (mostMatches > MIN_MATCH_COUNT) {
        std::vector<cv::Point2f> srcPts, dstPts;
        for (const auto& m : best) {
            cv::Point2f *bestPoint = new cv::Point2f(processedSamples.processedSamples[bestRouteIndex].referenceKP[m.queryIdx].pt.x, processedSamples.processedSamples[bestRouteIndex].referenceKP[m.queryIdx].pt.y);
            srcPts.push_back(*bestPoint);
            dstPts.push_back(frameKeypoints[m.trainIdx].pt);
        }
        
        cv::Mat srcMat = cv::Mat(srcPts);
        cv::Mat dstMat = cv::Mat(dstPts);
        cv::Mat H = cv::findHomography(srcMat, dstMat, cv::RANSAC, 5.0);
        
        srcMat.release();
        dstMat.release();
        srcPts.clear();
        dstPts.clear();
        best.clear();
        frameKeypoints.clear();
        
        if (H.rows != 3 || H.cols != 3) return inputFrame;
        
        cv::Mat bestRoute;
        UIImageToMat(processedSamples.processedSamples[bestRouteIndex].routeReference, bestRoute);

        cv::Mat overlay;
        cv::warpPerspective(bestRoute, overlay, H, cv::Size(frameCols, frameRows));
        cv::resize(overlay, overlay, cv::Size(frameMatrix.cols, frameMatrix.rows), 0, 0, cv::INTER_CUBIC);
        
        bestRoute.release();
        H.release();

        cv::Mat frameOutput;
        cv::addWeighted(frameMatrix, 1, overlay, 1, 0, frameOutput);
        
        UIImage *returnImage = MatToUIImage(frameOutput);
        
        frameOutput.release();
        frameMatrix.release();
        overlay.release();
        
        return returnImage;
    }
    
    frameMatrix.release();
    best.clear();
    frameKeypoints.clear();
    
    
    return inputFrame;
    
}

@end

#endif
