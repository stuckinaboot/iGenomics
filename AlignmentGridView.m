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
    [GlobalVars sortArrayUsingQuicksort:readAlignmentsArr withStartPos:0 andEndPos:[readAlignmentsArr count]-1];
//    [self setUpPositionMatchedCharsArr];
    [self setUpAlignmentGridPositionsArr];
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
    
    int indexInReadAlignmentArr = 0;
    
    for (int i = 0; i<kAlignmentGridViewNumOfGridSections; i++) {
        for (int j = firstPtToDraw; j<totalCols && x <= self.frame.size.width; j += numOfBoxesPerPixel, x += self.kGridLineWidthCol+boxWidth) {
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
                        float opacity = (boxWidth < kThresholdBoxWidth) ? kMutHighlightOpacityZoomedFarOut : kMutHighlightOpacity;
                        CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), dnaColors.mutHighlight.r, dnaColors.mutHighlight.g, dnaColors.mutHighlight.b, opacity);
                        int highlightWidth = (boxWidth < kMutHighlightMinWidth) ? kMutHighlightMinWidth : boxWidth;
                        
                        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(x+self.kGridLineWidthCol, kPosLblHeight, highlightWidth, self.frame.size.height-kPosLblHeight));
                        //                        [delegate mutationFoundAtPos:j];
                    }
                    else {//No mutation
                        [self drawText:[NSString stringWithFormat:@"%c",foundGenome[0][j]] atPoint:CGPointMake(x, y) withRGB:(double[3]){dnaColors.black.r,dnaColors.black.g,dnaColors.black.b}];
                    }
                }
                else {//A through insertion
                    /*
                    if (readStartsIndexArr[j] != kAlignmentGridViewReadStartIndexNone) {
                        ED_Info *read = [readAlignmentsArr objectAtIndex:readStartsIndexArr[j]];
                        read.rowInAlignmentGrid = 0;
                        [self drawReadWithEDInfo:read atX:x andY:y];
                        int k = readStartsIndexArr[j]+1;
                        while (k < [readAlignmentsArr count] && read.position == j) {
                            read.rowInAlignmentGrid++;
                            [self drawReadWithEDInfo:read atX:x andY:y];
                            k++;
                            read = [readAlignmentsArr objectAtIndex:k];
                        }
                    }*/
                    [self drawCharColumnWithAlignmentGridPos:[alignmentGridPositionsArr objectAtIndex:j] atX:x+self.kGridLineWidthCol andY:y];
//                    [self drawCharColumnWithTxt:[positionMatchedCharsArr objectAtIndex:j] atX:x andY:y];
                    
                    //Put a position label above the graph
                    [self drawTickMarksForPoint:j andX:x];
                }
            }
        }
        x = firstPtOffset;
        
        if (i > 0)
            y += kGridLineWidthRow+boxHeight;
        else
            y += kGridLineWidthRow+graphBoxHeight;
    }
    
    newDrawingViewImg = UIGraphicsGetImageFromCurrentImageContext();
    [self setNeedsDisplay];

    UIGraphicsEndImageContext();
    
    [delegate gridFinishedUpdatingWithOffset:currOffset andGridScrollViewContentSizeChanged:scrollViewContentSizeChangedOnLastUpdate];
    scrollViewContentSizeChangedOnLastUpdate = NO;
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
    y = kPosLblHeight-(kPosLblTickMarkHeight/2);//See tickMarkConnectingLine code and this makes sense
    
    for (int i = 0; i<totalCols; i++) {
        [self drawRectangle:CGRectMake(x, y, self.kGridLineWidthCol, (boxHeight+kGridLineWidthRow)*(kAlignmentGridViewNumOfGridSections-1)) withRGB:rgb];
        x += self.kGridLineWidthCol+boxWidth;
        
        if (x > self.frame.size.width)
            break;
    }
}

- (void)drawCharColumnWithAlignmentGridPos:(AlignmentGridPosition*)gridPos atX:(float)x andY:(float)y {
    if (!gridPos.str)
        return;
    CGPoint point;
    for (int i = 0; i < gridPos.str.length; i++) {
        point = CGPointMake(x, y);

        char c = [gridPos.readInfoStr characterAtIndex:i];
        if (c != [kAlignmentGridViewCharColumnNoChar characterAtIndex:0]) {
        
            int readInfoNum = [[NSString stringWithFormat:@"%c",c] intValue];
            
            if (readInfoNum == kReadInfoReadStart) {
                [self drawReadStartAtPoint:point];
            }
            else if (readInfoNum == kReadInfoReadEnd) {
                [self drawReadEndAtPoint:point];
            }
            else if (readInfoNum == kReadInfoReadMiddle) {
                [self drawReadBodyAtPoint:point];
            }
            else if (readInfoNum == kReadInfoReadPosAfterStart) {
                [self drawReadBodyAtPoint:point nextToAnEnd:kReadInfoReadPosAfterStart];
            }
            else if (readInfoNum == kReadInfoReadPosBeforeEnd) {
                [self drawReadBodyAtPoint:point nextToAnEnd:kReadInfoReadPosBeforeEnd];
            }
            
            [self drawText:[NSString stringWithFormat:@"%c",[gridPos.str characterAtIndex:i]] atPoint:point withRGB:(double[3]){dnaColors.black.r, dnaColors.black.g,dnaColors.black.b}];//May want to change the color for each read or something
        }
        
        y += kGridLineWidthRow+boxHeight;
    }
}

- (void)drawReadStartAtPoint:(CGPoint)point {
    CGRect rect = CGRectMake(point.x, point.y, boxWidth+boxWidth/2, boxHeight);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:15.0];
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [UIColor grayColor].CGColor);
    [bezierPath fill];
}

- (void)drawReadEndAtPoint:(CGPoint)point {
    CGRect rect = CGRectMake(point.x, point.y, boxWidth, boxHeight);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:15.0];
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [UIColor grayColor].CGColor);
    [bezierPath fill];
}
- (void)drawReadBodyAtPoint:(CGPoint)point {
    CGRect rect = CGRectMake(point.x, point.y, boxWidth+self.kGridLineWidthCol, boxHeight);
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [UIColor grayColor].CGColor);
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
}

- (void)drawReadBodyAtPoint:(CGPoint)point nextToAnEnd:(int)end {
    CGRect rect = CGRectMake(point.x, point.y, boxWidth+self.kGridLineWidthCol, boxHeight);
    if (end == kReadInfoReadPosBeforeEnd)
        rect = CGRectMake(point.x, point.y, boxWidth+boxWidth/2, boxHeight);
    
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [UIColor grayColor].CGColor);
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
}

- (void)setUpAlignmentGridPositionsArr {
    alignmentGridPositionsArr = [[NSMutableArray alloc] init];
    for (int i = 0; i < dgenomeLen; i++) {
        AlignmentGridPosition *position = [[AlignmentGridPosition alloc] init];
        position.startIndexInreadAlignmentsArr = kAlignmentGridViewReadStartIndexNone;
        position.positionRelativeToReadStart = kAlignmentGridViewReadStartIndexNone;
        [alignmentGridPositionsArr addObject:position];
    }

    int rowOfRead = 0;
    for (int i = 0; i < [readAlignmentsArr count]; i++) {
        ED_Info *read = [readAlignmentsArr objectAtIndex:i];
        int lenA = strlen(read.gappedA);
        
        for (int x = 0; x < lenA; x++) {
            AlignmentGridPosition *gridPos = [alignmentGridPositionsArr objectAtIndex:read.position+x];
            gridPos.startIndexInreadAlignmentsArr = read.position;
            gridPos.positionRelativeToReadStart = x;
            gridPos.readLen = lenA;

            if (!gridPos.str)
                gridPos.str = [[NSMutableString alloc] init];
            if (!gridPos.readInfoStr)
                gridPos.readInfoStr = [[NSMutableString alloc] init];
            [gridPos.str appendFormat:@"%c",read.gappedA[x]];
            
            int readInfoNum;
            if (x == 0)
                readInfoNum = kReadInfoReadStart;
            else if (x == lenA-1)
                readInfoNum = kReadInfoReadEnd;
            else if (x == 1)
                readInfoNum = kReadInfoReadPosAfterStart;
            else if (x == lenA-2)
                readInfoNum = kReadInfoReadPosBeforeEnd;
            else
                readInfoNum = kReadInfoReadMiddle;
            [gridPos.readInfoStr appendFormat:@"%i",readInfoNum];
            
            if (x > 0) {
                while(rowOfRead+1 > gridPos.str.length) {
                    [gridPos.str insertString:kAlignmentGridViewCharColumnNoChar atIndex:0];
                    [gridPos.readInfoStr insertString:kAlignmentGridViewCharColumnNoChar atIndex:0];
                }
            }
            else {
                rowOfRead = gridPos.str.length-1;
            }
        }
    }
}


- (void)drawCharColumnWithTxt:(NSString*)txt atX:(float)x andY:(float)y {
    if (txt.length == 0)
        return;
    for (int i = 0; i < txt.length; i++) {
        [self drawText:[NSString stringWithFormat:@"%c",[txt characterAtIndex:i]] atPoint:CGPointMake(x, y) withRGB:(double[3]){dnaColors.black.r, dnaColors.black.g,dnaColors.black.b}];//May want to change the color for each read or something
        y += kGridLineWidthRow+boxHeight;
    }
}

@end
