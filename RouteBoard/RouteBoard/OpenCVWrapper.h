//
//  OpenCVWrapper.hpp
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 29.06.2024..
//

#ifndef OpenCVWrapper_hpp
#define OpenCVWrapper_hpp


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@class ImportSamplesSwift;
@class ProcessedSamplesSwift;

@interface OpenCVWrapper : NSObject
+ (NSString *)getOpenCVVersion;
+ (UIImage *)grayscaleImg:(UIImage *)image;
+ (ProcessedSamplesSwift*)processInputSamples:(ImportSamplesSwift*)samples;
+ (UIImage *)detectRoutesAndAddOverlay:(ProcessedSamplesSwift*)processedSamples inputFrame:(UIImage *) inputFrame;
@end

NS_ASSUME_NONNULL_END


#endif /* OpenCVWrapper_hpp */
