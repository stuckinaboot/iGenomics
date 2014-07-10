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
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);//0.0 sets the scale factor to the scale of the device's main screen
    else
        UIGraphicsBeginImageContext(rect.size);
    [imgView.image drawInRect:rect];
    [self drawPlotInRect:rect];
    [self drawAxisesInRect:rect];
    [self drawNormalCurveInRect:rect];
    imgView.image = UIGraphicsGetImageFromCurrentImageContext();//Might need to use drawRect for setting the img, depending on performance
    UIGraphicsEndImageContext();
}

- (void)drawNormalCurveInRect:(CGRect)rect {
    float maxNormVal = [self normalCurveFormulaValueForPos:posOfHighestFrequency];
    float x = kCoverageHistogramXAxisDistFromScreenLeft+kCoverageHistogramAxisWidth;
    float y = rect.size.height-kCoverageHistogramYAxisDistFromScreenBottom-kCoverageHistogramAxisWidth;
    int i = 0;
    while (i*boxWidth < rect.size.width) {
        float normalVal = [self normalCurveFormulaValueForPos:i];
        float actualYVal = rect.size.height-kCoverageHistogramYAxisDistFromScreenBottom-(normalVal/maxNormVal)*(rect.size.height-kCoverageHistogramYAxisDistFromScreenBottom);
       
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), kCoverageHistogramThinLineWidth);
        CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [[UIColor blackColor] CGColor]);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), x, y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), kCoverageHistogramXAxisDistFromScreenLeft+i*boxWidth, actualYVal);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        x = kCoverageHistogramXAxisDistFromScreenLeft+i*boxWidth;
        y = actualYVal;
//        [self drawRectangle:CGRectMake(kCoverageHistogramXAxisDistFromScreenLeft+i*boxWidth, actualYVal, 1.0f, 1.0f) withRGB:(double[3]){dnaColors.black.r, dnaColors.black.g, dnaColors.black.b}];
        i++;
    }
}

- (float)normalCurveFormulaValueForPos:(int)x {
    //Everything in here is following the normal distribution formula as defined here: http://upload.wikimedia.org/math/7/3/a/73ad15f79b11af99bd2477ff3ffc5a35.png

    float sd = sqrtf(posOfHighestFrequency);
    float mean = posOfHighestFrequency;
    
    float formulaPart1 = 1/(sd*sqrtf(2*M_PI));//Formula 1st part
    float formualaPart2 = pow(x-mean,2); //Formula 2nd part
    float formulaPart3 = -1/(2*sd*sd);
    
    return formulaPart1*exp(formualaPart2*formulaPart3);
}

- (void)drawAxisesInRect:(CGRect)rect {
    [self drawRectangle:CGRectMake(kCoverageHistogramXAxisDistFromScreenLeft, 0, kCoverageHistogramAxisWidth, rect.size.height) withRGB:(double[3]){dnaColors.black.r,dnaColors.black.g,dnaColors.black.b}];
    [self drawRectangle:CGRectMake(0, rect.size.height-kCoverageHistogramYAxisDistFromScreenBottom, rect.size.width, kCoverageHistogramAxisWidth) withRGB:(double[3]){dnaColors.black.r,dnaColors.black.g,dnaColors.black.b}];
}

- (void)drawAxisLblsInRect:(CGRect)rect withCovFreqArr:(int[])covFreqArr andCovFreqArrMax:(int)covFreqArrMax {
    //Easier to use UILabels
    CGRect titleFrame = CGRectMake(0, 0, kCoverageHistogramLblWidth, kCoverageHistogramLblHeight);
    UIFont *axisLblFont = [UIFont systemFontOfSize:kCoverageHistogramAxisFontSize];
    
    UILabel *xTitle = [[UILabel alloc] initWithFrame:titleFrame];
    xTitle.center = CGPointMake(kCoverageHistogramXAxisDistFromScreenLeft+((rect.size.width-kCoverageHistogramXAxisDistFromScreenLeft)/2)+xTitle.bounds.size.width/2,rect.size.height-kCoverageHistogramXAxisTitleDistFromScreenEdge);
    [xTitle setFont:axisLblFont];
    [xTitle setText:kCoverageHistogramAxisXTitle];
    [self.view addSubview:xTitle];
    
    UILabel *yTitle = [[UILabel alloc] initWithFrame:titleFrame];
    yTitle.center = CGPointMake(kCoverageHistogramYAxisTitleDistFromScreenEdge, ((rect.size.height)/2)-kCoverageHistogramYAxisDistFromScreenBottom);
    [yTitle setFont:axisLblFont];
    [yTitle setText:kCoverageHistogramAxisYTitle];
    [yTitle setTransform:CGAffineTransformMakeRotation(-(M_PI)/2)];
    [self.view addSubview:yTitle];
    
    UILabel *x0Lbl = [[UILabel alloc] initWithFrame:CGRectMake(kCoverageHistogramXAxisDistFromScreenLeft+kCoverageHistogramAxisWidth, rect.size.height-kCoverageHistogramYAxisDistFromScreenBottom+kCoverageHistogramAxisWidth, kCoverageHistogramIntervalLblWidth, kCoverageHistogramIntervalLblHeight)];//Corresponds to the maxYLbl
    
    [x0Lbl setText:[NSString stringWithFormat:kCoverageHistogram0IntervalTxt]];
    [x0Lbl setAdjustsFontSizeToFitWidth:YES];
    [self.view addSubview:x0Lbl];
    
//    CGSize lblTxtSize = [kCoverageHistogram0IntervalTxt sizeWithFont:x0Lbl.font];
    
//    UILabel *y0Lbl = [[UILabel alloc] initWithFrame:CGRectMake(kCoverageHistogramXAxisDistFromScreenLeft-kCoverageHistogramIntervalLblWidth, rect.size.height-kCoverageHistogramYAxisDistFromScreenBottom-lblTxtSize.height, kCoverageHistogramIntervalLblWidth, kCoverageHistogramIntervalLblHeight)];//x0Lbl has same font so might as well just do it in the same line
//    [y0Lbl setTextAlignment:NSTextAlignmentRight];
//    [y0Lbl setText:[NSString stringWithFormat:kCoverageHistogram0IntervalTxt]];
//    [y0Lbl setAdjustsFontSizeToFitWidth:YES];
//    [self.view addSubview:y0Lbl];
    
    float standardDeviation = sqrtf(posOfHighestFrequency);
    
    UILabel *xLbls[kCoverageHistogramNumOfIntervalLblsPerAxis];
    UILabel *yLbls[kCoverageHistogramNumOfIntervalLblsPerAxis];
    
    int currNumOfSD = -kCoverageHistogramNumOfIntervalLblsPerAxis/2.0f;
    
    int x = xValOfPosOfHighestFrequency+(standardDeviation*currNumOfSD)*boxWidth+kCoverageHistogramAxisWidth;
    
    for (int i = 0; i < kCoverageHistogramNumOfIntervalLblsPerAxis; i++, x += standardDeviation*boxWidth, currNumOfSD++) {
        xLbls[i] = [[UILabel alloc] initWithFrame:CGRectMake(x, rect.size.height-kCoverageHistogramYAxisDistFromScreenBottom+kCoverageHistogramAxisWidth, kCoverageHistogramIntervalLblWidth, kCoverageHistogramIntervalLblHeight)];//Corresponds to the maxYLbl
        xLbls[i].center = CGPointMake(x, xLbls[i].center.y);
        [xLbls[i] setTextAlignment:NSTextAlignmentCenter];
        
        int pos = round(posOfHighestFrequency+standardDeviation*currNumOfSD);
        
        [xLbls[i] setText:[NSString stringWithFormat:@"%i",pos]];
        [xLbls[i] setAdjustsFontSizeToFitWidth:YES];
        [self.view addSubview:xLbls[i]];
        
        if (i < ceilf(kCoverageHistogramNumOfIntervalLblsPerAxis/2.0f) && pos <= maxCoverageVal && pos >= 0) {//This if is here because at the same SD, there will probably/usually be different frequencies. Also, can't make labels for out of bounds positions
            yLbls[i] = [[UILabel alloc] initWithFrame:CGRectMake(kCoverageHistogramXAxisDistFromScreenLeft-kCoverageHistogramIntervalLblWidth+kCoverageHistogramYAxisTitleDistFromScreenEdge, rect.size.height-kCoverageHistogramYAxisDistFromScreenBottom-((covFreqArr[pos]/(float)highestFrequency)*(rect.size.height-kCoverageHistogramYAxisDistFromScreenBottom)), kCoverageHistogramIntervalLblWidth, kCoverageHistogramIntervalLblHeight)];
            if (yLbls[i].frame.origin.y > 0)
                yLbls[i].frame = CGRectMake(yLbls[i].frame.origin.x, yLbls[i].frame.origin.y-kCoverageHistogramIntervalLblHeight/2, yLbls[i].frame.size.width, yLbls[i].frame.size.height);
            [yLbls[i] setText:[NSString stringWithFormat:@"%i",covFreqArr[pos]]];
            [yLbls[i] setAdjustsFontSizeToFitWidth:YES];
            [self.view addSubview:yLbls[i]];
        }
    }
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
    
    boxWidth = (rect.size.width-kCoverageHistogramXAxisDistFromScreenLeft)/(maxCoverageVal+1);
    for (int i = 0, x = kCoverageHistogramXAxisDistFromScreenLeft; i <= maxCoverageVal; i++, x += boxWidth) {
        float ratio = ((float)covFrequencyArr[i]/highestFrequency);
        int height = ratio*(rect.size.height-kCoverageHistogramYAxisDistFromScreenBottom);
        [self drawRectangle:CGRectMake(x, rect.size.height-kCoverageHistogramYAxisDistFromScreenBottom-height, boxWidth, height) withRGB:(double[3]){dnaColors.mutHighlight.r,dnaColors.mutHighlight.g,dnaColors.mutHighlight.b}];
        if (ratio == 1)
            xValOfPosOfHighestFrequency = x+boxWidth/2;
    }
    
    [self drawAxisLblsInRect:rect withCovFreqArr:covFrequencyArr andCovFreqArrMax:maxCoverageVal];
    [self drawDashedLineOnHighestFreqOccInRect:rect];
}

- (void)drawDashedLineOnHighestFreqOccInRect:(CGRect)rect {
//    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), kCoverageHistogramThinLineWidth);
    CGContextSaveGState(UIGraphicsGetCurrentContext());
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [[UIColor blackColor] CGColor]);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), kCoverageHistogramXAxisDistFromScreenLeft+boxWidth*posOfHighestFrequency+boxWidth/2, 0);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), kCoverageHistogramXAxisDistFromScreenLeft+boxWidth*posOfHighestFrequency+boxWidth/2, rect.size.height-kCoverageHistogramAxisWidth-kCoverageHistogramYAxisDistFromScreenBottom);
    CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0, (CGFloat[2]){kCoverageHistogramDashLength, kCoverageHistogramDashLength}, kCoverageHistogramThinLineWidth);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
}

- (void)drawRectangle:(CGRect)rect withRGB:(double[3])rgb {
    CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), rgb[0], rgb[1], rgb[2], 1.0f);
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

@end
