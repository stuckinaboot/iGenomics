//
//  CoverageHistogram.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 7/2/14.
//
//

#import "CoverageHistogram.h"

@implementation CoverageHistogram

- (void)createHistogramWithMaxCovVal:(int)maxCovVal {
    self.view.backgroundColor = [UIColor whiteColor];
    imgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:imgView];
    
    dnaColors = [[DNAColors alloc] init];
    [dnaColors setUp];
    
    maxCoverageVal = maxCovVal;
    
    imgView.image = NULL;
    CGRect rect = CGRectMake(0, 0, imgView.bounds.size.width, imgView.bounds.size.height);
    UIGraphicsBeginImageContext(rect.size);
    [imgView.image drawInRect:rect];
    [self drawPlotInRect:rect];
    [self drawAxisesInRect:rect];
    imgView.image = UIGraphicsGetImageFromCurrentImageContext();//Might need to use drawRect for setting the img, depending on performance
    UIGraphicsEndImageContext();
}

- (void)drawAxisesInRect:(CGRect)rect {
    [self drawRectangle:CGRectMake(kCoverageHistogramXAxisDistFromScreenLeft, 0, kCoverageHistogramAxisWidth, rect.size.height) withRGB:(double[3]){dnaColors.black.r,dnaColors.black.g,dnaColors.black.b}];
    [self drawRectangle:CGRectMake(0, rect.size.height-kCoverageHistogramYAxisDistFromScreenBottom, rect.size.width, kCoverageHistogramAxisWidth) withRGB:(double[3]){dnaColors.black.r,dnaColors.black.g,dnaColors.black.b}];
    [self drawAxisLblsInRect:rect];
}

- (void)drawAxisLblsInRect:(CGRect)rect {
    //Easier to use UILabels
    CGRect titleFrame = CGRectMake(0, 0, kCoverageHistogramLblWidth, kCoverageHistogramLblHeight);
    UIFont *axisLblFont = [UIFont systemFontOfSize:kCoverageHistogramAxisFontSize];
    
    UILabel *xTitle = [[UILabel alloc] initWithFrame:titleFrame];
    xTitle.center = CGPointMake(kCoverageHistogramXAxisDistFromScreenLeft+((rect.size.width-kCoverageHistogramXAxisDistFromScreenLeft)/2)+xTitle.bounds.size.width/2,rect.size.height-kCoverageHistogramAxisTitleDistFromScreenEdge);
    [xTitle setFont:axisLblFont];
    [xTitle setText:kCoverageHistogramAxisXTitle];
    [self.view addSubview:xTitle];
    
    UILabel *yTitle = [[UILabel alloc] initWithFrame:titleFrame];
    yTitle.center = CGPointMake(kCoverageHistogramAxisTitleDistFromScreenEdge, ((rect.size.height)/2)-kCoverageHistogramYAxisDistFromScreenBottom);
    [yTitle setFont:axisLblFont];
    [yTitle setText:kCoverageHistogramAxisYTitle];
    [yTitle setTransform:CGAffineTransformMakeRotation(-(M_PI)/2)];
    [self.view addSubview:yTitle];
    
    UILabel *maxYLbl = [[UILabel alloc] initWithFrame:CGRectMake(kCoverageHistogramXAxisDistFromScreenLeft-kCoverageHistogramIntervalLblWidth, 0, kCoverageHistogramIntervalLblWidth, kCoverageHistogramIntervalLblHeight)];
    [maxYLbl setText:[NSString stringWithFormat:@"%i",highestFrequency]];
    [maxYLbl setAdjustsFontSizeToFitWidth:YES];
    [self.view addSubview:maxYLbl];
    
    UILabel *correspondingXLbl = [[UILabel alloc] initWithFrame:CGRectMake(xValOfPosOfHighestFrequency+kCoverageHistogramAxisWidth, rect.size.height-kCoverageHistogramYAxisDistFromScreenBottom+kCoverageHistogramAxisWidth, kCoverageHistogramIntervalLblWidth, kCoverageHistogramIntervalLblHeight)];//Corresponds to the maxYLbl
    [correspondingXLbl setText:[NSString stringWithFormat:@"%i",posOfHighestFrequency]];
    [correspondingXLbl setAdjustsFontSizeToFitWidth:YES];
    [self.view addSubview:correspondingXLbl];
    
    /*float displayedDistBtwYIntervals = highestFrequency/kCoverageHistogramNumOfIntervalLblsPerAxis;
    float displayedDistBtwXIntervals = maxCoverageVal/kCoverageHistogramNumOfIntervalLblsPerAxis;
    
    float distBtwYIntervals = (rect.size.height-kCoverageHistogramYAxisDistFromScreenBottom)/(kCoverageHistogramNumOfIntervalLblsPerAxis);
    float distBtwXIntervals = (rect.size.width-kCoverageHistogramXAxisDistFromScreenLeft)/(kCoverageHistogramNumOfIntervalLblsPerAxis);
    
    int x = kCoverageHistogramXAxisDistFromScreenLeft-kCoverageHistogramIntervalLblWidth;
    int y = rect.size.height-kCoverageHistogramYAxisDistFromScreenBottom-distBtwYIntervals;
    
    int displayedYValue = displayedDistBtwYIntervals;
    int displayedXValue = displayedDistBtwXIntervals;
    
    for (y = y; y >= 0; y -= distBtwYIntervals, displayedYValue += displayedDistBtwYIntervals) {
        UILabel *intervalLbl = [[UILabel alloc] initWithFrame:CGRectMake(x, y, kCoverageHistogramIntervalLblWidth, kCoverageHistogramIntervalLblHeight)];
        [intervalLbl setText:[NSString stringWithFormat:@"%i",displayedYValue]];
        [self addSubview:intervalLbl];
    }
    
    y = rect.size.height-kCoverageHistogramYAxisDistFromScreenBottom;
    x += distBtwXIntervals;
    
    for (x = x; x <= rect.size.width; x += distBtwXIntervals, displayedXValue += displayedDistBtwXIntervals) {
        UILabel *intervalLbl = [[UILabel alloc] initWithFrame:CGRectMake(x, y, kCoverageHistogramIntervalLblWidth, kCoverageHistogramIntervalLblHeight)];
        [intervalLbl setText:[NSString stringWithFormat:@"%i",displayedXValue]];
        [self addSubview:intervalLbl];
    }*/
}

- (void)drawPlotInRect:(CGRect)rect {
    int covFrequencyArr[maxCoverageVal+1];
    
    for (int i = 0; i <= maxCoverageVal; i++) {
        covFrequencyArr[i] = 0;
    }
    
    for (int i = 0; i < dgenomeLen; i++) {
        int k = coverageArray[i]-posOccArray[kACGTLen+1][i];//Don't count insertions
        covFrequencyArr[k]++;
    }
    
    highestFrequency = 0;
    for (int i = 0; i <= maxCoverageVal; i++)
        if (highestFrequency < covFrequencyArr[i]) {
            highestFrequency = covFrequencyArr[i];
            posOfHighestFrequency = i;
        }
    
    int boxWidth = (rect.size.width-kCoverageHistogramXAxisDistFromScreenLeft)/(maxCoverageVal+1);
    for (int i = 0, x = kCoverageHistogramXAxisDistFromScreenLeft; i <= maxCoverageVal; i++, x += boxWidth) {
        float ratio = ((float)covFrequencyArr[i]/highestFrequency);
        int height = ratio*(rect.size.height-kCoverageHistogramYAxisDistFromScreenBottom);
        [self drawRectangle:CGRectMake(x, rect.size.height-kCoverageHistogramYAxisDistFromScreenBottom-height, boxWidth, height) withRGB:(double[3]){dnaColors.mutHighlight.r,dnaColors.mutHighlight.g,dnaColors.mutHighlight.b}];
        if (ratio == 1)
            xValOfPosOfHighestFrequency = x;
    }
}

- (void)drawRectangle:(CGRect)rect withRGB:(double[3])rgb {
    CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), rgb[0], rgb[1], rgb[2], 1.0f);
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
}

@end
