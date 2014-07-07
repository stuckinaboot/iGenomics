//
//  CoverageHistogram.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 7/2/14.
//
//

#import <UIKit/UIKit.h>
#import "RGB.h"
#import "DNAColors.h"
#import "GlobalVars.h"
#import "BWT_MutationFilter.h"
#import "IPhonePopoverHandler.h"

#define kCoverageHistogramAxisWidth 2
#define kCoverageHistogramAxisFontSize 15
#define kCoverageHistogramAxisXTitle @"Coverage"
#define kCoverageHistogramAxisYTitle @"Frequency of Reads Aligned"

#define kCoverageHistogramLblWidth 250
#define kCoverageHistogramLblHeight 30
#define kCoverageHistogramNumOfIntervalLblsPerAxis 3
#define kCoverageHistogramIntervalLblWidth 50
#define kCoverageHistogramIntervalLblHeight 20
#define kCoverageHistgoramIntervalLblFontSize 13

#define kCoverageHistogramYAxisDistFromScreenBottom 60
#define kCoverageHistogramXAxisDistFromScreenLeft 60
#define kCoverageHistogramAxisTitleDistFromScreenEdge 20


@interface CoverageHistogram : IPhonePopoverHandler {
    UIImageView *imgView;
    
    DNAColors *dnaColors;
    int maxCoverageVal;
    int highestFrequency;
    int posOfHighestFrequency;
    float xValOfPosOfHighestFrequency;
}
- (void)createHistogramWithMaxCovVal:(int)maxCovVal;
- (void)drawAxisesInRect:(CGRect)rect;
- (void)drawPlotInRect:(CGRect)rect;
- (void)drawAxisLblsInRect:(CGRect)rect;

- (void)drawRectangle:(CGRect)rect withRGB:(double[3])rgb;
@end