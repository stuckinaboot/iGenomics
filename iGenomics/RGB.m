//
//  RGB.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 3/26/13.
//
//

#import "RGB.h"

@implementation RGB

@synthesize r,g,b;

- (id)initWithVals:(double)myR : (double)myG : (double)myB {
    self = [super init];
    r = myR;
    g = myG;
    b = myB;
    return self;
}

- (CGColorRef)rgbColorRef {
    return [UIColor colorWithRed:r green:g blue:b alpha:kRGBDefaultAlpha].CGColor;
}
@end
