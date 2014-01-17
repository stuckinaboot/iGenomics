//
//  GridView.m
//  CompletelyCustomDNAGrid
//
//  Created by Stuckinaboot Inc. on 2/26/13.
//  Copyright (c) 2013 Stuckinaboot Inc. All rights reserved.
//

#import "QuickGridView.h"

@implementation QuickGridView

@synthesize boxHeight, kIpadBoxWidth, delegate, refSeq, currOffset, totalRows, totalCols, scrollingView, kTxtFontSize, graphBoxHeight;

- (void)firstSetUp {
    prevOffset = -1;
    
    dnaColors = [[DNAColors alloc] init];
    [dnaColors setUp];
    
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    scrollingView = [[UIScrollView alloc] initWithFrame:rect];
    [scrollingView setDelegate:self];
    [scrollingView setBackgroundColor:[UIColor clearColor]];
    
    drawingView = [[UIImageView alloc] initWithFrame:rect];
    
    maxCovLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kMaxCovValLblW, kMaxCovValLblH)];
    [maxCovLbl setBackgroundColor:[UIColor clearColor]];
    [maxCovLbl setTextColor:[UIColor blackColor]];
    
    tickMarkConnectingLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, kPosLblHeight-(kPosLblTickMarkHeight/2), self.frame.size.width, kPosLblTickMarkHeight/4)];
    tickMarkConnectingLine.center = CGPointMake(tickMarkConnectingLine.center.x, kPosLblHeight-kPosLblTickMarkHeight/2);
    [tickMarkConnectingLine setBackgroundColor:[UIColor blackColor]];
    
    kPosLblInterval = kDefPosLblInterval;
}

- (void)setUpWithNumOfRows:(int)rows andCols:(int)cols andGraphBoxHeight:(double)gbHeight {
    totalRows = rows;
    totalCols = cols;
    
    kIpadBoxWidth = kDefaultIpadBoxWidth;
    kTxtFontSize = kDefaultTxtFontSize;
                                      
    [self resetScrollViewContentSize];
    [self addSubview:drawingView];
    [self addSubview:scrollingView];
    [self addSubview:maxCovLbl];
    [self addSubview:tickMarkConnectingLine];
//    [self addSubview:pxlOffsetSlider];
    
    graphBoxHeight = gbHeight;
    boxHeight = (double)((self.frame.size.height)-graphBoxHeight-kPosLblHeight-((rows-1)*kGridLineWidthRow))/(rows-1);//Finds the boxHeight for the remaining rows
    
    //For the graph find the maxCoverageVal
    //First find highest value to make the max scale
    
    for (int i = 0; i<totalCols; i++) {//This is totalCols because that is the len of the seq, if this is no longer the len of the seq, then this needs to be changed
        if (coverageArray[i]-posOccArray[kACGTLen+1][i]>maxCoverageVal) {//Don't count insertions
            maxCoverageVal = coverageArray[i];
        }
    }
    
    maxCovLbl.text = [NSString stringWithFormat:@"[0,%i]",maxCoverageVal];
    
    [self setUpGridViewForPixelOffset:0];
    [self initialMutationFind];
}

- (void)setUpGridViewForPixelOffset:(double)offSet {
//    NSLog(@"\nPrev: %f Curr: %f Width: %f",prevOffset,offSet, self.frame.size.width);
    prevOffset = offSet;
    currOffset = offSet;
    drawingView.image = NULL;
    
    UIGraphicsBeginImageContext(self.frame.size);

    [drawingView.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    if (kTxtFontSize >= kMinTxtFontSize)
        [self drawDefaultBoxColors];
    
    int firstPtToDraw = [self firstPtToDrawForOffset:offSet];
    double firstPtOffset = [self firstPtToDrawOffset:offSet];//Will be 0 or negative
    
//    NSLog(@"\nFirst Pt To Draw: %f First pt offset: %f",firstPtOffset, firstPtOffset);
    
    if (kTxtFontSize > kMinTxtFontSize) //If it is 0, there is no need for them
        [self drawGridLinesForOffset:firstPtOffset];
    
    
    float x = firstPtOffset+kGridLineWidthCol;//If this passes the self.frame.size.width, stop drawing (break)
    float y = kPosLblHeight;
    
    for (int i = 0; i<totalRows; i++) {
        for (int j = firstPtToDraw; j<totalCols && x<= self.frame.size.width; j++, x += kGridLineWidthCol+kIpadBoxWidth) {
            if (i > 0) {//Not Graph Row
                //Depending on the value of i, draw foundGenome, refGenome, etc.
                if (i == 1) {//ref
                    [self drawText:[NSString stringWithFormat:@"%c",refSeq[j]] atPoint:CGPointMake(x, y) withRGB:(double[3]){dnaColors.white.r, dnaColors.white.g, dnaColors.white.b}];
                }
                else if (i == 2) {//found genome
                    if (refSeq[j] != foundGenome[0][j]) {//Mutation
                        RGB *rgb;
                        for (int t = 0; t<kACGTLen; t++) {
                            if (kACGTStr[t] == foundGenome[0][j]) {
                                //v = t;
                                switch (t) {
                                    case 0:
                                        rgb = dnaColors.aLbl;
                                        break;
                                    case 1:
                                        rgb = dnaColors.cLbl;
                                        break;
                                    case 2:
                                        rgb = dnaColors.gLbl;
                                        break;
                                    case 3:
                                        rgb = dnaColors.tLbl;
                                        break;
                                }
                                break;
                            }
                            else if (kDelMarker == foundGenome[0][j]) {
                                //v = kACGTLen;
                                rgb = dnaColors.delLbl;
                                break;
                            }
                            else if (kInsMarker == foundGenome[0][j]) {
                                //v = kACGTLen+1;
                                rgb = dnaColors.insLbl;
                                break;
                            }
                        }
                        double rgbVal[3] = {rgb.r, rgb.g, rgb.b};
                        [self drawText:[NSString stringWithFormat:@"%c",foundGenome[0][j]] atPoint:CGPointMake(x, y) withRGB:rgbVal];
                        
                        CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), dnaColors.mutHighlight.r, dnaColors.mutHighlight.g, dnaColors.mutHighlight.b, kMutHighlightOpacity);
                        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(x+kGridLineWidthCol, kPosLblHeight, kIpadBoxWidth, self.frame.size.height-kPosLblHeight));
//                        [delegate mutationFoundAtPos:j];
                    }
                    else {//No mutation
                        [self drawText:[NSString stringWithFormat:@"%c",foundGenome[0][j]] atPoint:CGPointMake(x, y) withRGB:(double[3]){dnaColors.black.r,dnaColors.black.g,dnaColors.black.b}];
                    }
                }
                else {//A through insertion
                    if (posOccArray[i-3][j] > 0) {
                        RGB *rgb;
                        switch (i-3) {
                            case 0:
                                rgb = dnaColors.aLbl;
                                break;
                            case 1:
                                rgb = dnaColors.cLbl;
                                break;
                            case 2:
                                rgb = dnaColors.gLbl;
                                break;
                            case 3:
                                rgb = dnaColors.tLbl;
                                break;
                            case 4:
                                rgb = dnaColors.delLbl;
                                break;
                            case 5:
                                rgb = dnaColors.insLbl;
                                break;
                        }
                        [self drawText:[NSString stringWithFormat:@"%i",posOccArray[i-3][j]] atPoint:CGPointMake(x, y) withRGB:(double[3]){rgb.r,rgb.g,rgb.b}];
                    }
                    else
                        [self drawText:[NSString stringWithFormat:@"%i",posOccArray[i-3][j]] atPoint:CGPointMake(x, y) withRGB:(double[3]){dnaColors.defaultLbl.r, dnaColors.defaultLbl.g, dnaColors.defaultLbl.b}];
                }
            }
            else {//Graph Row
                CGRect rect;
                if (kTxtFontSize >= kMinTxtFontSize) {
                    //Set up the graph
                    rect = CGRectMake(x, y, kIpadBoxWidth, graphBoxHeight);
                }
                else {
                    rect = CGRectMake(x, y, kIpadBoxWidth, self.bounds.size.height-kPosLblHeight);
                }
                
                int currCoverage = coverageArray[j]-posOccArray[kACGTLen+1][j];//Don't count insertions
                float newHeight = (currCoverage*rect.size.height)/maxCoverageVal;
                /* That kinda formula thing comes from this:
                 Coverage                X Height
                 ________       =     _________
                 Max Val		       Max Height
                 
                 X = (Coverage*Max Height)/ Max Val
                 */
                
                CGRect newRect = CGRectMake(x, y+(rect.size.height-newHeight), rect.size.width, newHeight);
                
                [self drawRectangle:newRect withRGB:(double[3]){0.2,0.3,0.4}];
                //Put a position label above the graph
                if ((j+1) % kPosLblInterval == 0) {//Multiple of kPosLblInterval
                    NSNumberFormatter *num = [[NSNumberFormatter alloc] init];
                    [num setNumberStyle: NSNumberFormatterDecimalStyle];
                    
                    CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 1.0f);
                    [[num stringFromNumber:[NSNumber numberWithInt:j+1]] drawAtPoint:CGPointMake(x+(kIpadBoxWidth/2), 0) withFont:[UIFont systemFontOfSize:kPosLblFontSize]];
                    
                    [self drawRectangle:CGRectMake(x+(kIpadBoxWidth/2), kPosLblHeight-kPosLblTickMarkHeight, kGridLineWidthCol, kPosLblTickMarkHeight) withRGB:(double[]){0,0,0}];
                }
            }
        }
        x = firstPtOffset;
        if (i > 0)
            y += kGridLineWidthRow+boxHeight;
        else
            y += kGridLineWidthRow+graphBoxHeight;
    }
    
    [drawingView performSelectorInBackground:@selector(setImage:) withObject:UIGraphicsGetImageFromCurrentImageContext()];
//    drawingView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [delegate gridFinishedUpdatingWithOffset:currOffset];
}

- (void)resetScrollViewContentSize {
    [scrollingView setContentSize:CGSizeMake(totalCols*(kGridLineWidthCol+kIpadBoxWidth), scrollingView.frame.size.height)];
}

- (int)firstPtToDrawForOffset:(double)offset {
    return (offset)/(kGridLineWidthCol+kIpadBoxWidth);
}

- (double)firstPtToDrawOffset:(double)offset {
    return -((int)offset) % ((int)kGridLineWidthCol+(int)kIpadBoxWidth);
}

- (double)offsetOfPt:(double)point {
    return (point*(kGridLineWidthCol+kIpadBoxWidth));
}

- (void)initialMutationFind {
    for (int i = 0; i<totalCols; i++) {
        if (foundGenome[0][i] != refSeq[i] || (foundGenome[1][i] != refSeq[i] && foundGenome[1][i] != kFoundGenomeDefaultChar)) {//If the found genome doesn't match, then report as a potential mutation, but also if the next possible spot in the found genome doesn't match report it as a potential mutation because it could be heterozygous
            [delegate mutationFoundAtPos:i];
        }
    }
}

//Draw Tick Marks
- (void)drawTickMarksForStartingPos:(int)pos {
    int zeroes = 0;
    int colsOnScreen = (self.frame.size.width/(kIpadBoxWidth+kGridLineWidthCol));
    double interval = colsOnScreen/kPosLblNum;
    
    for (zeroes = 0; pos>10; zeroes++)
        pos = floorf(pos/10);
    for (int i = 0; i<zeroes; i++)
        pos *= 10;
    
    NSNumberFormatter *num = [[NSNumberFormatter alloc] init];
    [num setNumberStyle: NSNumberFormatterDecimalStyle];
    
    for (int i = 0; i<kPosLblNum; i++) {
            CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), dnaColors.black.r, dnaColors.black.g, dnaColors.black.b, 1.0f);
            [[num stringFromNumber:[NSNumber numberWithInt:pos]] drawAtPoint:CGPointMake(pos*(kIpadBoxWidth+kGridLineWidthCol)+(kIpadBoxWidth/2), 0) withFont:[UIFont systemFontOfSize:kPosLblFontSize]];
            
            [self drawRectangle:CGRectMake(pos*(kIpadBoxWidth+kGridLineWidthCol)+(kIpadBoxWidth/2), kPosLblHeight-kPosLblTickMarkHeight, kGridLineWidthCol, kPosLblTickMarkHeight) withRGB:(double[]){0,0,0}];
        
        pos += interval;
    }
    //FOR THEH INTERVAL ON ZOOM IN/OUT ON THE FLY SHOW FIVE TICK MARKS (THE NUM OF COLUMNS ON THE SCREEN/4) ON THE SCREEN AT ALL TIMES (UNLESS THE FIFTH IS OFF THE SCREEN, THEN DO FOUR). Only show to one sig fig
    /*
     zeros = 0;  do while num>10 zeroes++ num = floorf(num/10), then do for x = 0, x<zeroes x++) num *= 10
     num = 3123;
     */
}

- (void)resetTickMarkInterval {
    //First find num of cols on screen
    int numOfColsOnScreen = 0;
    
    int x = 0;
    for (int i = 0; i<totalCols; i++, x += kIpadBoxWidth, numOfColsOnScreen++) {
        if (x>self.frame.size.width)
            break;
    }
    
    kPosLblInterval = numOfColsOnScreen/kPosLblNum;
    
    if (kPosLblInterval<5)
        kPosLblInterval = 5;
    else if (kPosLblInterval<10)
        kPosLblInterval = 10;
    
    //Now make the interval nicer
    int zeroes;
    for (zeroes = 0; kPosLblInterval>10; zeroes++)
        kPosLblInterval = floorf(kPosLblInterval/10);
    for (int i = 0; i<zeroes; i++)
        kPosLblInterval *= 10;
}

//Create Grid Lines
- (void)drawGridLinesForOffset:(double)offset {
    double rgb[3] = {1,1,1};
    
    float x = offset;
    float y = kPosLblHeight+graphBoxHeight;
    
    for (int i = 1; i<totalRows; i++) {
        [self drawRectangle:CGRectMake(x, y, self.frame.size.width+(abs(offset)), kGridLineWidthRow) withRGB:rgb];
        y += kGridLineWidthRow+boxHeight;
    }
    
    y = kPosLblHeight;
    
    for (int i = 0; i<totalCols; i++) {
        [self drawRectangle:CGRectMake(x, y, kGridLineWidthCol, self.frame.size.height) withRGB:rgb];
        x += kGridLineWidthCol+kIpadBoxWidth;
        
        if (x > self.frame.size.width)
            break;
    }
}

//Create Default Colors
- (void)drawDefaultBoxColors {
    float y = kPosLblHeight+graphBoxHeight+kGridLineWidthRow;
    
    for (int i = 1; i<totalRows; i++) {
        
        if (i == 1) //Ref
            [self drawRectangle:CGRectMake(0, y, self.frame.size.width, boxHeight) withRGB:(double[3]){dnaColors.refLbl.r, dnaColors.refLbl.g, dnaColors.refLbl.b}];
        else if (i == 2) //Found
            [self drawRectangle:CGRectMake(0, y, self.frame.size.width, boxHeight) withRGB:(double[3]){dnaColors.foundLbl.r, dnaColors.foundLbl.g, dnaColors.foundLbl.b}];
        else {
            [self drawRectangle:CGRectMake(0, y, self.frame.size.width, (boxHeight+kGridLineWidthRow)*(kACGTLen+2)) withRGB:(double[3]){dnaColors.defaultBackground.r, dnaColors.defaultBackground.g, dnaColors.defaultBackground.b}];//+2 because of dels and ins
            break;
        }
        y += kGridLineWidthRow+boxHeight;
    }
}

//Scroll To Position
- (void)scrollToPos:(double)p {
    [self setUpGridViewForPixelOffset:p*(kIpadBoxWidth+kGridLineWidthCol)];
    [scrollingView setContentOffset:CGPointMake(currOffset, 0)];
}

//Actual Drawing Code
- (void)drawText:(NSString*)txt atPoint:(CGPoint)point withRGB:(double[3])rgb {
    //point is the center of where the txt is to be drawn
    if (kTxtFontSize >= kMinTxtFontSize) {
        CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), rgb[0], rgb[1], rgb[2], 1.0f);
        UIFont *font = [UIFont systemFontOfSize:kTxtFontSize];
        float yOffset = ((boxHeight+font.pointSize)/2.0f)-font.pointSize;
        CGSize txtSize = [txt sizeWithFont:font];
    //    [txt drawAtPoint:point withFont:[UIFont systemFontOfSize:kTxtFontSize]];
            if (txtSize.width > kIpadBoxWidth) {
                for (int i = kTxtFontSize; i > 0; i--) {
                    if (txtSize.width < kIpadBoxWidth) {
                        yOffset = ((boxHeight+font.pointSize)/2.0f)-font.pointSize;
                        break;
                    }
                    font = [UIFont systemFontOfSize:i];
                    txtSize = [txt sizeWithFont:font];
                }
            }
            [txt drawInRect:CGRectMake(point.x, point.y+yOffset, kIpadBoxWidth, font.pointSize) withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    }
}

- (void)drawRectangle:(CGRect)rect withRGB:(double[3])rgb {
    CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), rgb[0], rgb[1], rgb[2], 1.0f);
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
}

//ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self setUpGridViewForPixelOffset:scrollingView.contentOffset.x];
}

- (IBAction)pxlOffsetSliderValChanged:(id)sender {
    UISlider* s = (UISlider*)sender;
    [scrollingView setContentOffset:scrollingView.contentOffset animated:NO];
    [self performSelector:@selector(updateScrollView:) withObject:s afterDelay:kScrollViewSliderUpdateInterval];
//    [scrollingView setContentOffset:CGPointMake(s.value, 0)];
}

- (void)updateScrollView:(UISlider*)s {
    [scrollingView setContentOffset:CGPointMake(s.value, 0)];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
