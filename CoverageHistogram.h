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

#define kGenomeLengthLblStart @"Genome Len: "
#define kReadLengthLblStart @"First Read Len: "
#define kNumOfReadsLblStart @"Num Reads: "

#define kCoverageHistogramPopoverWidth 600
#define kCoverageHistogramPopoverHeight 600

#define kCoverageHistogramNoReadsAlignedAlertMsg @"No reads aligned"

#define kCoverageHistogramAxisWidth 2
#define kCoverageHistogramAxisFontSize 15
#define kCoverageHistogramAxisXTitle @"Coverage"
#define kCoverageHistogramAxisYTitle @"Frequency of Reads Aligned"

#define kCoverageHistogram0IntervalTxt @"0"

#define kCoverageHistogramLblWidth 250
#define kCoverageHistogramLblHeight 30
#define kCoverageHistogramNumOfIntervalLblsPerAxis 3
#define kCoverageHistogramIntervalLblWidth 80
#define kCoverageHistogramIntervalLblHeight 20
#define kCoverageHistogramIntervalLblFontSize 13

#define kCoverageHistogramSDDefault 2.0f //Set to this when the mean is 0
#define kCoverageHistogramNumOfSDDecreaseFactor 2.0f

#define kCoverageHistogramThinLineWidth 2.0f
#define kCoverageHistogramDashLength 10.0f

#define kCoverageHistogramXAxisDistFromScreenBottom 50
#define kCoverageHistogramYAxisDistFromScreenLeft 60
#define kCoverageHistogramXAxisTitleDistFromScreenEdge 20
#define kCoverageHistogramYAxisTitleDistFromScreenEdge 15

#define kCoverageHistogramNormalCurveLinesPerBox 4

#define kCoverageHistogramTitleInIPhoneHandlerPopover @"Coverage Histogram"

@interface CoverageHistogram : UIViewController {
    UIImageView *imgView;
    
    DNAColors *dnaColors;
    int maxCoverageVal;
    int highestFrequency;
    int posOfHighestFrequency;
    int freqAtPosOfHighestFrequency;
    float xValOfPosOfHighestFrequency;
    int boxWidth;
}
- (void)createHistogramWithMaxCovVal:(int)maxCovVal andNumOfReads:(int)numOfReads andReadLen:(int)readLen andGenomeLen:(int)genomeLen;
- (void)drawNormalCurveInRect:(CGRect)rect;
- (float)normalCurveFormulaValueForPos:(float)x;
- (void)drawAxisesInRect:(CGRect)rect;
- (void)drawPlotInRect:(CGRect)rect;
- (void)drawAxisLblsInRect:(CGRect)rect withCovFreqArr:(int[])covFreqArr andCovFreqArrMax:(int)covFreqArrMax;
- (void)drawDashedLineOnHighestFreqOccInRect:(CGRect)rect;

- (void)drawSideInformationWithNumOfReads:(int)numOfReads andReadLen:(int)readLen andGenomeLen:(int)genomeLen;

- (void)drawRectangle:(CGRect)rect withRGB:(double[3])rgb;
@end