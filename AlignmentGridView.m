//
//  AlignmentGridView.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 7/10/14.
//
//

#import "AlignmentGridView.h"

@implementation AlignmentGridView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)firstSetUp {
    [super firstSetUp];
    longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(readLongPressed:)];
    longPressRecognizer.minimumPressDuration = kReadLongPressRecognizerMinDuration;
    [self addGestureRecognizer:longPressRecognizer];
    if ([readAlignmentsArr count] > 1) //No need to sort if count is 0 or 1
        [GlobalVars sortArrayUsingQuicksort:readAlignmentsArr withStartPos:0 andEndPos:[readAlignmentsArr count]-1];
//    [self setUpPositionMatchedCharsArr];
    [self setMaxCovValWithNumOfCols:dgenomeLen-1];
    [self setUpAlignmentGridPositionsArr];
}

- (void)setUpAlignmentGridPositionsArr {
    alignmentGridPositionsArr = (AlignmentGridPosition*__strong*)calloc(dgenomeLen,sizeof(AlignmentGridPosition*));//Ask about why sizeof(a pointer) works here
    NSString *noCharStr = [NSString stringWithFormat:@"%c",kAlignmentGridViewCharColumnNoChar];
    NSMutableString *noCharLongStr = [[NSMutableString alloc] init];
    for (int i = 0; i < maxCoverageVal; i++)
        [noCharLongStr appendString:noCharStr];
    
    for (int i = 0; i < dgenomeLen; i++) {
        AlignmentGridPosition *gridPos = [[AlignmentGridPosition alloc] init];
        gridPos.str = strdup([noCharLongStr UTF8String]);
        gridPos.readInfoStr = calloc(noCharLongStr.length, sizeof(int));
        gridPos.readIndexStr = calloc(noCharLongStr.length, sizeof(int));//+1 rather than initialize the whole array to -1, I will just later on subtract 1
        for (int j = 0; j < maxCoverageVal; j++) {
            gridPos.readIndexStr[j] = -1;
        }
        alignmentGridPositionsArr[i] = gridPos;
    }
    
    int counter = 0;
    for (int i = 0; i < [readAlignmentsArr count]; i++) {
        ED_Info *read = [readAlignmentsArr objectAtIndex:i];
        int lenA = (int)strlen(read.gappedA);
        int placeToInsertChar = -1;
        int insCount = 0;
        for (int x = 0; x < lenA; x++) {
            
            AlignmentGridPosition *gridPos = alignmentGridPositionsArr[read.position+x];
            if (!gridPos) {
                gridPos = [[AlignmentGridPosition alloc] init];
                alignmentGridPositionsArr[read.position+x] = gridPos;
            }
            
            gridPos.startIndexInreadAlignmentsArr = read.position;
            gridPos.positionRelativeToReadStart = x;
            gridPos.readLen = lenA;
            
            int readInfoNum = [self readInfoNumForX:x len:lenA andInsCount:insCount];
            
            if (readInfoNum == kReadInfoReadStart) {
                counter = 0;
                placeToInsertChar = 0;
                
                while (placeToInsertChar < maxCoverageVal && gridPos.str[placeToInsertChar] != kAlignmentGridViewCharColumnNoChar)
                    placeToInsertChar++;
            }
            
            gridPos.readIndexStr[placeToInsertChar] = i;
            
            if (placeToInsertChar+1 > gridPos.highestChar)
                gridPos.highestChar = placeToInsertChar+1;//+1 because is basically counting the row in normal numbers for math purposes
            
            if (read.insertion) {
                if (placeToInsertChar >= maxCoverageVal)
                    break;
                int temp = x+insCount;
                int prevX = x+insCount;
                while (temp < lenA && read.gappedB[temp] == kDelMarker) {
                    insCount++;
                    temp++;
                }
                if (prevX != temp) {
                    readInfoNum = [self readInfoNumForX:x len:lenA andInsCount:insCount];
                    if (readInfoNum == kReadInfoReadEnd)
                        alignmentGridPositionsArr[read.position+prevX].readInfoStr[placeToInsertChar] = kReadInfoReadPosBeforeEnd;
                }
                if (x + insCount >= lenA)
                    break;
                gridPos.str[placeToInsertChar] = read.gappedA[x+insCount];
                gridPos.readInfoStr[placeToInsertChar] = readInfoNum;
                    counter++;
            }
            else {
                if (placeToInsertChar < maxCoverageVal) {//gridPos.str.length) {
                    gridPos.str[placeToInsertChar] = read.gappedA[x];
                    gridPos.readInfoStr[placeToInsertChar] = readInfoNum;
                }
            }
        }
    }
}

- (int)readInfoNumForX:(int)x len:(int)len andInsCount:(int)insCount {
    if (x+insCount == 0)
         return kReadInfoReadStart;
    else if (x+insCount == len-1)
        return kReadInfoReadEnd;
    else if (x+insCount == 1)
         return kReadInfoReadPosAfterStart;
    else if (x+insCount == len-2)
         return kReadInfoReadPosBeforeEnd;
    else
         return kReadInfoReadMiddle;
}

- (void)setUpGridViewForPixelOffset:(double)offSet {
    currOffset = offSet;
    drawingView.image = NULL;
    
    CGSize drawingSize = self.frame.size;
    
    //Prevents pixelation of text on retina display
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(drawingSize, NO, 0.0);//0.0 sets the scale factor to the scale of the device's main screen
    else
        UIGraphicsBeginImageContext(drawingSize);
    
    [drawingView.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    [self drawSegmentDividers];
    
    if (kTxtFontSize >= kMinTxtFontSize && boxWidth >= kThresholdBoxWidth)
        [self drawDefaultBoxColors];
    
    int firstPtToDraw = round([self firstPtToDrawForOffset:offSet]/numOfBoxesPerPixel)*numOfBoxesPerPixel;//Rounds to nearest multiple of numOfBoxesPerPixel
    double firstPtOffset = [self firstPtToDrawOffset:offSet];//Will be 0 or negative
    
    if (kTxtFontSize >= kMinTxtFontSize && boxWidth >= kThresholdBoxWidth) {//If it is 0, there is no need for them
        self.kGridLineWidthCol = kGridLineWidthColDefault;
        [self drawGridLinesForOffset:firstPtOffset];
    }
    else
        self.kGridLineWidthCol = kGridLineWidthColDefaultMin;
    
    float x = firstPtOffset+self.kGridLineWidthCol;//If this passes the self.frame.size.width, stop drawing (break)
    float y = kPosLblHeight;

    float maxAlignmentStrLen = 0;
    
    BOOL mutationPresentArr[(int)ceilf((totalCols-firstPtToDraw)/(float)numOfBoxesPerPixel)];
    
    
    for (int i = 0; i<kAlignmentGridViewNumOfGridSections; i++) {
        int indexInMutPresentArr = 0;
        for (int j = firstPtToDraw; j<totalCols && x <= self.frame.size.width; j += numOfBoxesPerPixel, x += self.kGridLineWidthCol+boxWidth) {
            float graphCurrY = 0;
            if (i > GraphRow) {//Not Graph Row
                //Depending on the value of i, draw foundGenome, refGenome, etc.
                if (i == RefRow) {//ref
                    [self drawText:[NSString stringWithFormat:@"%c",self.refSeq[j]] atPoint:CGPointMake(x, y) withRGB:(double[3]){dnaColors.white.r, dnaColors.white.g, dnaColors.white.b}];
                }
                else if (i == FoundRow) {//found genome
                    if ((self.refSeq[j] != foundGenome[0][j]) && boxWidth >= kThresholdBoxWidth) {//Mutation present - highlights the view. If the graph is taking up the whole view, the mutation is checked and dealt with properly when the graph is created
                        RGB *rgb;
                        for (int t = 0; t<kACGTLen; t++) {
                            if (kACGTStr[t] == foundGenome[0][j]) {
                                //v = t;
                                rgb = [self colorForIndexInACGTWithInDelsStr:t orChar:' ' usingIndex:YES];
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
//                        float opacity = (boxWidth < kThresholdBoxWidth) ? kMutHighlightOpacityZoomedFarOut : kMutHighlightOpacity;
//                        CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), dnaColors.mutHighlight.r, dnaColors.mutHighlight.g, dnaColors.mutHighlight.b, opacity);
//                        int highlightWidth = (boxWidth < kMutHighlightMinWidth) ? kMutHighlightMinWidth : boxWidth;
//                        
//                        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(x+self.kGridLineWidthCol, kPosLblHeight, highlightWidth, self.frame.size.height-kPosLblHeight));
                        //                        [delegate mutationFoundAtPos:j];
                    }
                    else {//No mutation
                        [self drawText:[NSString stringWithFormat:@"%c",foundGenome[0][j]] atPoint:CGPointMake(x, y) withRGB:(double[3]){dnaColors.black.r,dnaColors.black.g,dnaColors.black.b}];
                    }
                }
                else {//A through insertion
                    AlignmentGridPosition *gridPos = alignmentGridPositionsArr[j];

                    if (gridPos.highestChar > maxAlignmentStrLen)
                        maxAlignmentStrLen = gridPos.highestChar;
                    [self drawCharColumnWithAlignmentGridPos:gridPos withGridPosIndexInGridPosArr:j atX:x andY:y-currYOffset andYToNotCross:y];
//                    [self drawCharColumnWithTxt:[positionMatchedCharsArr objectAtIndex:j] atX:x andY:y];
                }
            }
            else if (i == GraphRow) {
                if (posOccArray[kACGTLen+1][j] > 0 && numOfBoxesPerPixel == kPixelWidth) {
                    NSString *strToDraw = [NSString stringWithFormat:@"%c",kInsMarker];
                    CGSize size = [strToDraw sizeWithFont:[UIFont systemFontOfSize:kTxtFontSize]];
                    [self drawText:strToDraw atPoint:CGPointMake(x, kPosLblHeight-size.height-kPosLblTickMarkHeight/2+kGridLineWidthRow) withRGB:(double[3]){dnaColors.insertionIcon.r ,dnaColors.insertionIcon.g, dnaColors.insertionIcon.b}];
                }
                CGRect rect;
                if (kTxtFontSize >= kMinTxtFontSize && boxWidth >= kThresholdBoxWidth) {
                    //Set up the graph
                    rect = CGRectMake(x, y, boxWidth, graphBoxHeight);
                }
                else {
                    rect = CGRectMake(x, y, boxWidth, kPosLblHeight+graphBoxHeight);
                }
                
                int currCoverage = coverageArray[j]-posOccArray[kACGTLen+1][j];//Don't count insertions
                float newHeight = (currCoverage*rect.size.height)/maxCoverageVal;
                /* That kinda formula thing comes from this:
                 Coverage                X Height
                 ________       =     _________
                 Max Val		       Max Height
                 
                 X = (Coverage*Max Height)/ Max Val
                 */
                
                graphCurrY = y+(rect.size.height-newHeight);
                CGRect newRect = CGRectMake(x, graphCurrY, rect.size.width, newHeight);
                BOOL mutationPresent = [self mutationPresentWithinInterval:j andEndIndex:j+numOfBoxesPerPixel-1];//Highlights the bar of the graph
                mutationPresentArr[indexInMutPresentArr] = mutationPresent;
                indexInMutPresentArr++;
                RGB *color = (mutationPresent) ? dnaColors.mutHighlight : dnaColors.graph;
                [self drawRectangle:newRect withRGB:(double[3]){color.r,color.g,color.b}];
                
                //Put a position label above the graph
                [self drawTickMarksForPoint:j andX:x];
            }
            if (i == ARow) {
                BOOL mutPresent = mutationPresentArr[indexInMutPresentArr];
                if (mutPresent && boxWidth >= kThresholdBoxWidth) {
                    float opacity = (boxWidth < kThresholdBoxWidth) ? kMutHighlightOpacityZoomedFarOut : kMutHighlightOpacity;
                    CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), dnaColors.mutHighlight.r, dnaColors.mutHighlight.g, dnaColors.mutHighlight.b, opacity);
                    int highlightWidth = (boxWidth < kMutHighlightMinWidth) ? kMutHighlightMinWidth : boxWidth;
                   
                    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(x+self.kGridLineWidthCol, kPosLblHeight, highlightWidth, FoundRow*(boxHeight+kGridLineWidthRow)+graphBoxHeight));
//                    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(x+self.kGridLineWidthCol, kPosLblHeight, highlightWidth, self.frame.size.height-kPosLblHeight));
                }
                if  (mutPresent && boxWidth < kThresholdBoxWidth && numOfBoxesPerPixel > kPixelWidth) {
                    float opacity = (boxWidth < kThresholdBoxWidth) ? kMutHighlightOpacityZoomedFarOut : kMutHighlightOpacity;
                    CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), dnaColors.mutHighlight.r, dnaColors.mutHighlight.g, dnaColors.mutHighlight.b, opacity);
                    int highlightWidth = (boxWidth < kMutHighlightMinWidth) ? kMutHighlightMinWidth : boxWidth;
                    
                    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(x+self.kGridLineWidthCol, y, highlightWidth, self.frame.size.height-kPosLblHeight));
                }
                indexInMutPresentArr++;
            }
        }
        
        x = firstPtOffset;
        
        if (i > 0)
            y += kGridLineWidthRow+boxHeight;
        else
            y += kGridLineWidthRow+graphBoxHeight;
    }
    
    if (maxAlignmentStrLen > 0)
        [self fixScrollViewContentSizeWithMaxAlignmentStrLen:maxAlignmentStrLen];
    else if (maxAlignmentStrLen == 0 && scrollingView.contentSize.height > scrollingView.frame.size.height)
        [self fixScrollViewContentSizeWithMaxAlignmentStrLen:maxAlignmentStrLen];
    
    newDrawingViewImg = UIGraphicsGetImageFromCurrentImageContext();
    [self setNeedsDisplay];

    UIGraphicsEndImageContext();

    [delegate gridFinishedUpdatingWithOffset:currOffset andGridScrollViewContentSizeChanged:scrollViewContentSizeChangedOnLastUpdate];
    scrollViewContentSizeChangedOnLastUpdate = NO;
    
}

- (void)fixScrollViewContentSizeWithMaxAlignmentStrLen:(int)maxAlignmentStrLen {
    float maxY = kPosLblHeight+(maxAlignmentStrLen+ARow)*(kGridLineWidthRow+boxHeight);
    if (maxY != scrollingView.contentSize.height)
        scrollingView.contentSize = CGSizeMake(scrollingView.contentSize.width, maxY);
    else if (maxY < self.bounds.size.height && scrollingView.contentSize.height >= self.bounds.size.height)
        scrollingView.contentSize = CGSizeMake(scrollingView.contentSize.width, self.bounds.size.height);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    currYOffset = scrollView.contentOffset.y;
    [super scrollViewDidScroll:scrollView];
}

//Create Grid Lines
- (void)drawGridLinesForOffset:(double)offset {
    double rgb[3] = {1,1,1};
    
    float x = offset;
    float y = kPosLblHeight+graphBoxHeight;
    
    for (int i = 1; i<ARow; i++) {
        [self drawRectangle:CGRectMake(x, y, self.frame.size.width+(abs(offset)), kGridLineWidthRow) withRGB:rgb];
        y += kGridLineWidthRow+boxHeight;
    }
    y = kPosLblHeight-(kPosLblTickMarkHeight/2);//See tickMarkConnectingLine code and this makes sense
    
    for (int i = 0; i<totalCols; i++) {
        [self drawRectangle:CGRectMake(x, y, self.kGridLineWidthCol, (boxHeight+kGridLineWidthRow)*(kAlignmentGridViewNumOfGridSections-1)) withRGB:rgb];
        x += self.kGridLineWidthCol+boxWidth;
        
        if (x > self.frame.size.width)
            break;
    }
}

- (void)drawCharColumnWithAlignmentGridPos:(AlignmentGridPosition*)gridPos withGridPosIndexInGridPosArr:(int)j atX:(float)x andY:(float)y andYToNotCross:(int)yToNotCross {
    if (!gridPos.str)
        return;
    
    CGContextSaveGState(UIGraphicsGetCurrentContext());
    CGContextClipToRect(UIGraphicsGetCurrentContext(), CGRectMake(0, yToNotCross, self.bounds.size.width, self.bounds.size.height-yToNotCross));
    CGPoint point;
    
    NSString *gridPosStr = [NSString stringWithFormat:@"%s",gridPos.str];
    
    for (int i = 0; i < maxCoverageVal; i++) {
        
        BOOL isHiddenReadStart = NO;
        if (numOfBoxesPerPixel > kPixelWidth)
            if (j-numOfBoxesPerPixel >= 0 && gridPos.readIndexStr[i] != alignmentGridPositionsArr[j-numOfBoxesPerPixel].readIndexStr[i] && alignmentGridPositionsArr[j-numOfBoxesPerPixel].readInfoStr[i] != kReadInfoReadStart)
                isHiddenReadStart = YES;
        
        BOOL isHiddenReadEnd = NO;
        if (!isHiddenReadStart) {
            if (numOfBoxesPerPixel > kPixelWidth)
                if (j+numOfBoxesPerPixel<dgenomeLen && gridPos.readIndexStr[i] != alignmentGridPositionsArr[j+numOfBoxesPerPixel].readIndexStr[i])
                    isHiddenReadEnd = YES;
        }
        
        point = CGPointMake(x, y);
        if (gridPos.str[i] != kAlignmentGridViewCharColumnNoChar && y + kGridLineWidthRow+boxHeight > yToNotCross) {
            int readInfoNum = gridPos.readInfoStr[i];
            
            CGColorRef ref = [dnaColors.alignedRead rgbColorRef];
            
            //For adding outline
            if (isHiddenReadStart || isHiddenReadEnd)
                ref = [dnaColors.black rgbColorRef];
            //
            
            if (gridPos.str[i] != originalStr[j] && numOfBoxesPerPixel == kPixelWidth)
                ref = [dnaColors.mutHighlight rgbColorRef];
            
            if (numOfBoxesPerPixel > kPixelWidth)
                [self drawReadBodyAtPoint:point withColorRef:ref];
            else {
                if (readInfoNum == kReadInfoReadStart) {
                    [self drawReadStartAtPoint:point withColorRef:ref];
                }
                else if (readInfoNum == kReadInfoReadEnd) {
                    [self drawReadEndAtPoint:point withColorRef:ref];
                }
                else if (readInfoNum == kReadInfoReadMiddle) {
                    [self drawReadBodyAtPoint:point withColorRef:ref];
                }
                else if (readInfoNum == kReadInfoReadPosAfterStart) {
                    [self drawReadBodyAtPoint:point nextToAnEnd:kReadInfoReadPosAfterStart withColorRef:ref];
                }
                else if (readInfoNum == kReadInfoReadPosBeforeEnd) {
                    [self drawReadBodyAtPoint:point nextToAnEnd:kReadInfoReadPosBeforeEnd withColorRef:ref];
                }
            }
//            }
            if (kTxtFontSize >= kMinTxtFontSize && boxWidth >= kThresholdBoxWidth) {
//                char gridPosChar = [gridPos.str characterAtIndex:i];
                char gridPosChar = gridPos.str[i];
                RGB *rgb = [self colorForIndexInACGTWithInDelsStr:-1 orChar:gridPosChar usingIndex:NO];
                [self drawText:[gridPosStr substringWithRange:NSMakeRange(i, 1)] atPoint:point withRGB:(double[3]){rgb.r, rgb.g,rgb.b}];//May want to change the color for each read or something
            }
        }
        y += kGridLineWidthRow+boxHeight;
        if (y > self.bounds.size.height)
            break;
    }
    
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
}

- (void)drawReadStartAtPoint:(CGPoint)point withColorRef:(CGColorRef)colorRef {
    CGRect rect = CGRectMake(point.x, point.y, boxWidth+boxWidth/2, boxHeight);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:15.0];
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), colorRef);
    [bezierPath fill];
    
    //For adding outline
    CGContextSaveGState(UIGraphicsGetCurrentContext());
    CGContextClipToRect(UIGraphicsGetCurrentContext(), CGRectMake(rect.origin.x-kAlignmentGridPositionStartEndStrokeBorderWidth, rect.origin.y, boxWidth/2+kAlignmentGridPositionStartEndStrokeBorderWidth, rect.size.height));
    bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:15.0];
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [[UIColor blackColor] CGColor]);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), kAlignmentGridPositionStartEndStrokeBorderWidth);
    [bezierPath stroke];
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
}

- (void)drawReadEndAtPoint:(CGPoint)point withColorRef:(CGColorRef)colorRef {
    CGRect rect = CGRectMake(point.x, point.y, boxWidth, boxHeight);
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), colorRef);
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(rect.origin.x, rect.origin.y, rect.size.width/2, rect.size.height));
    CGContextSaveGState(UIGraphicsGetCurrentContext());
    CGContextClipToRect(UIGraphicsGetCurrentContext(), CGRectMake(rect.origin.x+boxWidth/2, rect.origin.y, rect.size.width, rect.size.height));
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:15.0];
    [bezierPath fill];
    
    //For adding outline
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
    CGContextSaveGState(UIGraphicsGetCurrentContext());
    CGContextClipToRect(UIGraphicsGetCurrentContext(), CGRectMake(rect.origin.x+boxWidth/2, rect.origin.y, rect.size.width, rect.size.height));
    bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:15.0];
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [[UIColor blackColor] CGColor]);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), kAlignmentGridPositionStartEndStrokeBorderWidth);
    [bezierPath stroke];
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
}
- (void)drawReadBodyAtPoint:(CGPoint)point withColorRef:(CGColorRef)colorRef {
    CGRect rect = CGRectMake(point.x, point.y, boxWidth+self.kGridLineWidthCol, boxHeight);
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), colorRef);
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
}

- (void)drawReadBodyAtPoint:(CGPoint)point nextToAnEnd:(int)end withColorRef:(CGColorRef)colorRef {
    CGRect rect = CGRectMake(point.x, point.y, boxWidth+self.kGridLineWidthCol, boxHeight);
    if (end == kReadInfoReadPosBeforeEnd)
        rect = CGRectMake(point.x, point.y, boxWidth+boxWidth/1.5, boxHeight);
    
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), colorRef);
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
}

//Read long pressed
- (IBAction)readLongPressed:(id)sender {
    if (numOfBoxesPerPixel > kPixelWidth)
        return;
    
    CGPoint touchLocInGrid = [sender locationInView:self];
    CGPoint touchLocInScrollView = [sender locationInView:scrollingView];
    CGPoint pt = CGPointMake(touchLocInGrid.x, touchLocInScrollView.y);
    
    //Get the xCoord in the scrollView
    double xCoord = self.currOffset+pt.x;
    
    //Find the box that was clicked
    CGPoint box = CGPointMake([self firstPtToDrawForOffset:xCoord],(int)((pt.y-(kPosLblHeight+graphBoxHeight))/(kGridLineWidthRow+self.boxHeight))-FoundRow);//Get the tapped box,... subtracts found row because is assuming box.y = 0 would mean the first row for displaying reads
    int index = alignmentGridPositionsArr[(int)box.x].readIndexStr[(int)box.y];
    if (index < 0 || alignmentGridPositionsArr[(int)box.x].str[(int)box.y] == kAlignmentGridViewCharColumnNoChar)
        return;
    ED_Info *read = [readAlignmentsArr objectAtIndex:index];
    [self displayReadPopoverForRead:read atPosInGenome:box.x atPointOnScreen:pt];
}

- (void)displayReadPopoverForRead:(ED_Info *)read atPosInGenome:(int)pos atPointOnScreen:(CGPoint)point {
    ReadPopoverController *controller = [[ReadPopoverController alloc] init];
    [controller setUpWithRead:read];
    [delegate displayPopoverWithViewController:controller atPoint:point];
}

@end
