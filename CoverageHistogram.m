//
//  CoverageHistogram.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 7/2/14.
//
//

#import "CoverageHistogram.h"

@implementation CoverageHistogram

- (void)createHistogramWithMaxCovVal:(int)maxCovVal andNumOfReads:(int)numOfReads andReadLen:(int)readLen andGenomeLen:(int)genomeLen {
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
    
    [self drawSideInformationWithNumOfReads:numOfReads andReadLen:readLen andGenomeLen:genomeLen];
}

- (void)drawSideInformationWithNumOfReads:(int)numOfReads andReadLen:(int)readLen andGenomeLen:(int)genomeLen {
    NSArray *startStrings = [NSArray arrayWithObjects:kNumOfReadsLblStart, kReadLengthLblStart, kGenomeLengthLblStart, nil];
    NSArray *numVals = [NSArray arrayWithObjects:[NSNumber numberWithInt:numOfReads], [NSNumber numberWithInt:readLen], [NSNumber numberWithInt:genomeLen], nil];
    
    float y = 0;
    for (int i = 0; i < [startStrings count]; i++) {
        UILabel *lbl = [[UILabel alloc] init];
        lbl.text = [NSString stringWithFormat:@"%@%i",[startStrings objectAtIndex:i],[[numVals objectAtIndex:i] intValue]];
        lbl.font = [UIFont systemFontOfSize:kCoverageHistogramAxisFontSize];
        CGSize size = [lbl.text sizeWithFont:lbl.font];
        lbl.frame = CGRectMake(self.view.frame.size.width-size.width, y, size.width, size.height);
        [self.view addSubview:lbl];
        y += size.height;
    }
}

- (void)drawNormalCurveInRect:(CGRect)rect {
    float maxNormVal = [self normalCurveFormulaValueForPos:posOfHighestFrequency];
    float x = kCoverageHistogramYAxisDistFromScreenLeft+kCoverageHistogramAxisWidth+boxWidth/2;
    float y = rect.size.height-kCoverageHistogramXAxisDistFromScreenBottom-kCoverageHistogramAxisWidth;
    float i = 0;
    float step = 1.0f/kCoverageHistogramNormalCurveLinesPerBox;
    
    float bw = (rect.size.width-kCoverageHistogramYAxisDistFromScreenLeft)/(maxCoverageVal+1);
    boxWidth = bw;
    
    int addFactor = 1;
    if (bw < 1) {
        addFactor = (1.0f/bw);
        boxWidth = 1;
    }
    
    while (i*addFactor < rect.size.width) {
        float normalVal = [self normalCurveFormulaValueForPos:i*addFactor];
        float actualYVal = rect.size.height-kCoverageHistogramXAxisDistFromScreenBottom-(normalVal/maxNormVal)*(rect.size.height-kCoverageHistogramXAxisDistFromScreenBottom);
       
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), kCoverageHistogramThinLineWidth);
        CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [[UIColor blackColor] CGColor]);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), x, y);
        if (i > 0)
            CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), kCoverageHistogramYAxisDistFromScreenLeft+i*addFactor+addFactor/2, actualYVal);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        x = kCoverageHistogramYAxisDistFromScreenLeft+i*addFactor+addFactor/2;
        y = actualYVal;
//        [self drawRectangle:CGRectMake(kCoverageHistogramYAxisDistFromScreenLeft+i*boxWidth, actualYVal, 1.0f, 1.0f) withRGB:(double[3]){dnaColors.black.r, dnaColors.black.g, dnaColors.black.b}];
        i += step;
    }
}

- (float)normalCurveFormulaValueForPos:(float)x {
    //Everything in here is following the normal distribution formula as defined here: http://upload.wikimedia.org/math/7/3/a/73ad15f79b11af99bd2477ff3ffc5a35.png

    float sd = sqrtf(posOfHighestFrequency);
    if (sd == 0)
        sd = kCoverageHistogramSDDefault;
    float mean = posOfHighestFrequency;
    
    float formulaPart1 = 1/(sd*sqrtf(2*M_PI));//Formula 1st part
    float formualaPart2 = pow(x-mean,2); //Formula 2nd part
    float formulaPart3 = -1/(2*sd*sd);
    
    return formulaPart1*exp(formualaPart2*formulaPart3);
}

- (void)drawAxisesInRect:(CGRect)rect {
    [self drawRectangle:CGRectMake(kCoverageHistogramYAxisDistFromScreenLeft, 0, kCoverageHistogramAxisWidth, rect.size.height) withRGB:(double[3]){dnaColors.black.r,dnaColors.black.g,dnaColors.black.b}];
    [self drawRectangle:CGRectMake(0, rect.size.height-kCoverageHistogramXAxisDistFromScreenBottom, rect.size.width, kCoverageHistogramAxisWidth) withRGB:(double[3]){dnaColors.black.r,dnaColors.black.g,dnaColors.black.b}];
}

- (void)drawAxisLblsInRect:(CGRect)rect withCovFreqArr:(int[])covFreqArr andCovFreqArrMax:(int)covFreqArrMax {
    //Easier to use UILabels
    CGRect titleFrame = CGRectMake(0, 0, kCoverageHistogramLblWidth, kCoverageHistogramLblHeight);
    UIFont *axisLblFont = [UIFont systemFontOfSize:kCoverageHistogramAxisFontSize];
    
    UILabel *xTitle = [[UILabel alloc] initWithFrame:titleFrame];
    xTitle.center = CGPointMake(kCoverageHistogramYAxisDistFromScreenLeft+((rect.size.width-kCoverageHistogramYAxisDistFromScreenLeft)/2)+xTitle.bounds.size.width/2,rect.size.height-kCoverageHistogramXAxisTitleDistFromScreenEdge);
    [xTitle setFont:axisLblFont];
    [xTitle setText:kCoverageHistogramAxisXTitle];
    [self.view addSubview:xTitle];
    
    UILabel *yTitle = [[UILabel alloc] initWithFrame:titleFrame];
    yTitle.center = CGPointMake(kCoverageHistogramYAxisTitleDistFromScreenEdge, ((rect.size.height)/2)-kCoverageHistogramXAxisDistFromScreenBottom);
    [yTitle setFont:axisLblFont];
    [yTitle setText:kCoverageHistogramAxisYTitle];
    [yTitle setTransform:CGAffineTransformMakeRotation(-(M_PI)/2)];
    [self.view addSubview:yTitle];
    
    if (posOfHighestFrequency > 0) {
        UILabel *x0Lbl = [[UILabel alloc] initWithFrame:CGRectMake(kCoverageHistogramYAxisDistFromScreenLeft+kCoverageHistogramAxisWidth, rect.size.height-kCoverageHistogramXAxisDistFromScreenBottom+kCoverageHistogramAxisWidth, kCoverageHistogramIntervalLblWidth, kCoverageHistogramIntervalLblHeight)];//Corresponds to the maxYLbl
        
        [x0Lbl setText:[NSString stringWithFormat:kCoverageHistogram0IntervalTxt]];
        [x0Lbl setAdjustsFontSizeToFitWidth:YES];
        [self.view addSubview:x0Lbl];
    }
    
//    CGSize lblTxtSize = [kCoverageHistogram0IntervalTxt sizeWithFont:x0Lbl.font];
    
//    UILabel *y0Lbl = [[UILabel alloc] initWithFrame:CGRectMake(kCoverageHistogramYAxisDistFromScreenLeft-kCoverageHistogramIntervalLblWidth, rect.size.height-kCoverageHistogramXAxisDistFromScreenBottom-lblTxtSize.height, kCoverageHistogramIntervalLblWidth, kCoverageHistogramIntervalLblHeight)];//x0Lbl has same font so might as well just do it in the same line
//    [y0Lbl setTextAlignment:NSTextAlignmentRight];
//    [y0Lbl setText:[NSString stringWithFormat:kCoverageHistogram0IntervalTxt]];
//    [y0Lbl setAdjustsFontSizeToFitWidth:YES];
//    [self.view addSubview:y0Lbl];
    
    float standardDeviation = sqrtf(posOfHighestFrequency);
    BOOL usingDefaultSD = NO;
    
    if (standardDeviation == 0) {
        standardDeviation = kCoverageHistogramSDDefault;
        usingDefaultSD = YES;
    }
    
    UILabel *xLbls[kCoverageHistogramNumOfIntervalLblsPerAxis];
    UILabel *yLbls[kCoverageHistogramNumOfIntervalLblsPerAxis];
    
    int currNumOfSD = -kCoverageHistogramNumOfIntervalLblsPerAxis/2.0f;
    
    int x = xValOfPosOfHighestFrequency+(standardDeviation*currNumOfSD)*boxWidth+kCoverageHistogramAxisWidth;
    
    for (int i = 0; i < kCoverageHistogramNumOfIntervalLblsPerAxis; i++, x += standardDeviation*boxWidth, currNumOfSD++) {
        xLbls[i] = [[UILabel alloc] initWithFrame:CGRectMake(x, rect.size.height-kCoverageHistogramXAxisDistFromScreenBottom+kCoverageHistogramAxisWidth, kCoverageHistogramIntervalLblWidth, kCoverageHistogramIntervalLblHeight)];//Corresponds to the maxYLbl
        xLbls[i].center = CGPointMake(x, xLbls[i].center.y);
        [xLbls[i] setTextAlignment:NSTextAlignmentCenter];
        
        int pos = round(posOfHighestFrequency+standardDeviation*currNumOfSD);
        
        [xLbls[i] setText:[NSString stringWithFormat:@"%i",pos]];
        [xLbls[i] setAdjustsFontSizeToFitWidth:YES];
        
        BOOL shouldAddX = YES;
        if (i > 0) {
            for (int j = 0; j < i; j++)
                if (CGRectIntersectsRect(xLbls[j].frame, xLbls[i].frame)) {
                    shouldAddX = NO;
                    if (currNumOfSD == 0) {
                        shouldAddX = YES;
                        for (int l = 0; l < i; l++)
                            [xLbls[l] removeFromSuperview];
                    }
                    break;
                }
        }
        if (shouldAddX) {
            if (posOfHighestFrequency > 0)
                [self.view addSubview:xLbls[i]];
            else if (usingDefaultSD && maxCoverageVal != 0 && currNumOfSD >= 0)
                [self.view addSubview:xLbls[i]];
        }
        
        UIFont *font = xLbls[i].font;
        
        if (i <= ceilf(kCoverageHistogramNumOfIntervalLblsPerAxis/2.0f) && pos <= maxCoverageVal && pos >= 0) {//This if is here because at the same SD, there will probably/usually be different frequencies. Also, can't make labels for out of bounds positions
            yLbls[i] = [[UILabel alloc] initWithFrame:CGRectMake(0, rect.size.height-kCoverageHistogramXAxisDistFromScreenBottom-((covFreqArr[pos]/(float)highestFrequency)*(rect.size.height-kCoverageHistogramXAxisDistFromScreenBottom)), kCoverageHistogramIntervalLblWidth, kCoverageHistogramIntervalLblHeight)];
            
            if (yLbls[i].frame.origin.y > 0)
                yLbls[i].frame = CGRectMake(yLbls[i].frame.origin.x, yLbls[i].frame.origin.y-kCoverageHistogramIntervalLblHeight/2, yLbls[i].frame.size.width, yLbls[i].frame.size.height);
            [yLbls[i] setText:[NSString stringWithFormat:@"%i",covFreqArr[pos]]];
            
            CGSize size = [yLbls[i].text sizeWithFont:font];
            yLbls[i].frame = CGRectMake(kCoverageHistogramYAxisDistFromScreenLeft-size.width, yLbls[i].frame.origin.y, size.width, size.height);
            
            BOOL shouldAddY = YES;
            if (i > 0) {
                for (int j = 0; j < i; j++)
                    if (CGRectIntersectsRect(yLbls[j].frame, yLbls[i].frame)) {
                        shouldAddY = NO;
                        break;
                    }
            }
            
            if (shouldAddY) {
                [yLbls[i] setTextAlignment:NSTextAlignmentLeft];
                [yLbls[i] setAdjustsFontSizeToFitWidth:YES];
                [self.view addSubview:yLbls[i]];
            }
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
    
    float bw = (rect.size.width-kCoverageHistogramYAxisDistFromScreenLeft)/(maxCoverageVal+1);
    boxWidth = bw;
    
    int addFactor = 1;
    if (bw < 1) {
        addFactor = (1.0f/bw);
        boxWidth = 1;
    }
    
    for (int i = 0, x = kCoverageHistogramYAxisDistFromScreenLeft; i <= maxCoverageVal; i += addFactor, x += boxWidth) {
        float ratio = ((float)covFrequencyArr[i]/highestFrequency);
        int height = ratio*(rect.size.height-kCoverageHistogramXAxisDistFromScreenBottom);
        [self drawRectangle:CGRectMake(x, rect.size.height-kCoverageHistogramXAxisDistFromScreenBottom-height, boxWidth, height) withRGB:(double[3]){dnaColors.mutHighlight.r,dnaColors.mutHighlight.g,dnaColors.mutHighlight.b}];
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
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), kCoverageHistogramYAxisDistFromScreenLeft+boxWidth*posOfHighestFrequency+boxWidth/2, 0);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), kCoverageHistogramYAxisDistFromScreenLeft+boxWidth*posOfHighestFrequency+boxWidth/2, rect.size.height-kCoverageHistogramAxisWidth-kCoverageHistogramXAxisDistFromScreenBottom);
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
