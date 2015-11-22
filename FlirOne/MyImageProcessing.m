//
//  ImageProcessing.m
//  FlirOne
//
//  Created by Altitude Labs on 21/11/15.
//  Copyright © 2015 Victor. All rights reserved.
//

#import "MyImageProcessing.h"
@import QuartzCore;
@import CoreImage;

@implementation MyImageProcessing

+ (NSArray*)getRGBAsFromImage:(UIImage*)image atX:(int)x andY:(int)y count:(int)count {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
    
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
    for (int i = 0 ; i < count ; ++i)
    {
        CGFloat alpha = ((CGFloat) rawData[byteIndex + 3] ) / 255.0f;
        CGFloat red   = ((CGFloat) rawData[byteIndex]     ) / alpha;
        CGFloat green = ((CGFloat) rawData[byteIndex + 1] ) / alpha;
        CGFloat blue  = ((CGFloat) rawData[byteIndex + 2] ) / alpha;
        byteIndex += bytesPerPixel;
        
        UIColor *acolor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        [result addObject:acolor];
    }
    
    free(rawData);
    
    return result;
}






typedef enum {
    ALPHA = 0,
    BLUE = 3,
    GREEN = 2,
    RED = 1
} PIXELS;

+(uint32_t *) getPixelsFromUIImage:(UIImage *)uiimage withSize:(CGSize)imgSize
{
    if (uiimage == nil) NSLog(@"ImageBasicProcessing getPixelsFromUIImage : uiimage cannot be nil");
    int width = imgSize.width;
    int height = imgSize.height;
    if (imgSize.width == 0 || imgSize.height == 0) NSLog(@"ImageBasicProcessing getPixelsFromUIImage : imgSize cannot be 0");
    
    uint32_t *pixels = (uint32_t *) calloc(width * height, sizeof(uint32_t));
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), space, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Little | kCGInterpolationNone);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), uiimage.CGImage);
    
    CGColorSpaceRelease(space);
    CGContextRelease(context);
    
    return pixels;
}

+(UIImage *) getUIImageFromPixels:(uint32_t *)pixels size:(CGSize)imgSize
{
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
    if (pixels == nil) {
        NSLog(@"ImageBasicProcessing: getUIImageFromPixels pixels is nil");
        return nil;
    }
    if (imgSize.width == 0) {
        NSLog(@"ImageBasicProcessing: getUIImageFromPixels imgSize is 0");
        return nil;
    }
    
    CGContextRef context = CGBitmapContextCreateWithData(pixels, imgSize.width, imgSize.height, 8, ((int)imgSize.width) * sizeof(int32_t), space, (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast), NULL, nil);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    
    CGColorSpaceRelease(space);
    CGContextRelease(context);
    CGImageRelease(imageRef);
    //free(pixels);
    
    return image;
}

+ (UIImage *) toGrayScaleWithUIImage:(UIImage *)inputImage
{
    CGSize outSize = inputImage.size;
    int width = outSize.width;
    int height = outSize.height;
    
    uint32_t *pixels = (uint32_t *) calloc(width * height, sizeof(uint32_t));
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
    //create blank pixel context for printing of CGImage
    CGContextRef contextRef = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), space, kCGBitmapByteOrder32Little|kCGImageAlphaPremultipliedLast);
    //extract the pixels inside CGImage
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), inputImage.CGImage);
    
    //processing pixels
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            uint8_t *pixel = (uint8_t *) &pixels[y * width + x];
            uint8_t r = pixel[RED];
            uint8_t g = pixel[GREEN];
            uint8_t b = pixel[BLUE];
            
            uint8_t gray = (r + g + b) / 3;
            pixel[RED] = gray;
            pixel[GREEN] = gray;
            pixel[BLUE] = gray;
        }
    }
    //Create image from modified pixel
    
    CGImageRef resultRef = CGBitmapContextCreateImage(contextRef);
    
    //recycle
    CGContextRelease(contextRef);
    CGColorSpaceRelease(space);
    free(pixels);
    
    UIImage *uiimage = [UIImage imageWithCGImage:resultRef];
    
    //recycle
    CGImageRelease(resultRef);
    
    return uiimage;
}

//+ (UIImage *) adjustContrast:(UIImage *)inputImage contrast:(int)level
//{
//    int width = inputImage.size.width;
//    int height = inputImage.size.height;
//
//    uint32_t *pixels = (uint32_t *) calloc(width * height, sizeof(uint32_t));
//    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
//
//    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), space, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Little);
//
//    CGContextDrawImage(context, CGRectMake(0, 0, width, height), inputImage.CGImage);
//
//    for (int y = 0; y < height; y++) {
//        for (int x = 0; x < width; x++) {
//            int pos = y * width + x;
//            uint8_t *pixel = (uint8_t *)&pixels[pos];
//            pixels[pos] = [self adjustContrastFunctionWithLevel:level inputColor:pixel];
//        }
//    }
//
//    CGImageRef resultImg = CGBitmapContextCreateImage(context);
//
//    free(pixels);
//    CGContextRelease(context);
//    CGColorSpaceRelease(space);
//
//    UIImage *img = [UIImage imageWithCGImage:resultImg];
//
//    CGImageRelease(resultImg);
//
//    return img;
//}

//+ (uint32_t) adjustContrastFunctionWithLevel:(uint32_t) value inputColor:(uint8_t *)rgb
//{
//    float valueF = (100.0f + value) / 100.0f;
//    valueF = valueF * valueF;
//
//    uint8_t a = rgb[0];
//    uint8_t rr = rgb[1];
//    uint8_t gg = rgb[2];
//    uint8_t bb = rgb[3];
//
//    float r = rr / 255.0f;
//    float g = gg / 255.0f;
//    float b = bb / 255.0f;
//
//    r = ((r -0.5f) * valueF + 0.5f) * 255.0f;
//    g = ((g -0.5f) * valueF + 0.5f) * 255.0f;
//    b = ((b -0.5f) * valueF + 0.5f) * 255.0f;
//
//    r = [ImageMath clippingWithRgb:r];
//    g = [ImageMath clippingWithRgb:g];
//    b = [ImageMath clippingWithRgb:b];
//
//    return  (bb << 24) | (gg << 16) | (rr << 8) | (a << 0);
//}

+ (uint32_t) adjustContrastWithGrayPixel:(uint32_t) rgb andValue:(int)value {
    value = (100.0f + value) / 100.0f;
    value = value * value;
    
    uint32_t grayPixel = (rgb >> 24) & 0xff;
    CGFloat grayPixelFloat = grayPixel / 255.0f;
    grayPixelFloat = (((grayPixelFloat - 0.5f) * value) + 0.5f) * 255.0f;
    grayPixel = MAX(0, MIN(255, grayPixelFloat));
    
    uint32_t result = (grayPixel << 24) | (grayPixel << 16) | (grayPixel << 8) | 255;
    return result;
}

+ (UIImage *)scaledImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, YES, 0.0);
    
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



@end
