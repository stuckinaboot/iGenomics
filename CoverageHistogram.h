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

#define kCoverageHistogram0IntervalTxt @"0"

#define kCoverageHistogramLblWidth 250
#define kCoverageHistogramLblHeight 30
#define kCoverageHistogramNumOfIntervalLblsPerAxis 3
#define kCoverageHistogramIntervalLblWidth 50
#define kCoverageHistogramIntervalLblHeight 20
#define kCoverageHistogramIntervalLblFontSize 13

#define kCoverageHistogramSDDefault 2.0f //Set to this when the mean is 0
#define kCoverageHistogramNumOfSDDecreaseFactor 2.0f

#define kCoverageHistogramThinLineWidth 2.0f
#define kCoverageHistogramDashLength 10.0f

#define kCoverageHistogramYAxisDistFromScreenBottom 60
#define kCoverageHistogramXAxisDistFromScreenLeft 60
#define kCoverageHistogramXAxisTitleDistFromScreenEdge 20
#define kCoverageHistogramYAxisTitleDistFromScreenEdge 15

@interface CoverageHistogram : IPhonePopoverHandler {
    UIImageView *imgView;
    
    DNAColors *dnaColors;
    int maxCoverageVal;
    int highestFrequency;
    int posOfHighestFrequency;
    float xValOfPosOfHighestFrequency;
    int boxWidth;
}
- (void)createHistogramWithMaxCovVal:(int)maxCovVal;
- (void)drawNormalCurveInRect:(CGRect)rect;
- (float)normalCurveFormulaValueForPos:(int)x;
- (void)drawAxisesInRect:(CGRect)rect;
- (void)drawPlotInRect:(CGRect)rect;
- (void)drawAxisLblsInRect:(CGRect)rect withCovFreqArr:(int[])covFreqArr andCovFreqArrMax:(int)covFreqArrMax;
- (void)drawDashedLineOnHighestFreqOccInRect:(CGRect)rect;

- (void)drawRectangle:(CGRect)rect withRGB:(double[3])rgb;
@end