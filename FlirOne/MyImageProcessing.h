//
//  ImageProcessing.h
//  FlirOne
//
//  Created by Altitude Labs on 21/11/15.
//  Copyright © 2015 Victor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyImageProcessing : NSObject

+ (NSArray*)getRGBAsFromImage:(UIImage*)image atX:(int)x andY:(int)y count:(int)count;


+ (uint32_t *) getPixelsFromUIImage:(UIImage *)uiimage withSize:(CGSize)imgSize;
+ (UIImage *) getUIImageFromPixels:(uint32_t *)pixels size:(CGSize)imgSize;

+ (UIImage *) toGrayScaleWithUIImage:(UIImage *)inputImage;
//+ (UIImage *) adjustContrast:(UIImage *)inputImage contrast:(int)level;
//+ (uint32_t) adjustContrastFunctionWithLevel:(uint32_t) value inputColor:(uint8_t *)rgb;
+ (uint32_t) adjustContrastWithGrayPixel:(uint32_t) rgb andValue:(int)value;

+ (UIImage *)scaledImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
