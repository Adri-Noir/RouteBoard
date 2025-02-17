//
//  OpenCVWrapper.hpp
//  RouteBoard
//
//  Created with <3 on 29.06.2024..
//

#ifndef OpenCVWrapper_hpp
#define OpenCVWrapper_hpp


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@class ImportSamplesSwift;
@class ProcessedSamplesSwift;
@class CVMap;
@class RoutePoints;
@class OverlayAndRouteId;

@interface OpenCVWrapper : NSObject
+ (NSString *)getOpenCVVersion;
+ (ProcessedSamplesSwift*)processInputSamples:(ImportSamplesSwift*)samples;
+ (OverlayAndRouteId *)detectRoutesAndAddOverlay:(ProcessedSamplesSwift*)processedSamples inputFrame:(UIImage *) inputFrame;
+ (UIImage *)addOverlayToFrame:(UIImage *)inputFrame overlay:(CVMap *) overlay;
+ (UIImage *)createRouteLineImage:(RoutePoints *)points picture:(CVMap *) picture;
+ (CVMap *)convertImageToMat:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END


#endif /* OpenCVWrapper_hpp */
