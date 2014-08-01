//
//  RGB.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 3/26/13.
//
//

#import <Foundation/Foundation.h>

#define kRGBDefaultAlpha 1.0f

@interface RGB : NSObject
@property (nonatomic) double r, g, b;
- (id)initWithVals:(double)myR : (double)myG : (double)myB;
- (CGColorRef)rgbColorRef;
- (UIColor*)UIColorObj;
@end
