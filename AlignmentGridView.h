//
//  AlignmentGridView.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 7/10/14.
//
//

#import "QuickGridView.h"
#import "GlobalVars.h"
#import "AlignmentGridPosition.h"
#import "ReadPopoverController.h"
#import <malloc/malloc.h>
#import <objc/runtime.h>

#define kAlignmentGridViewMaxCharsReadSpacing 2

#define kAlignmentGridViewNumOfGridSections 3 //Includes graph row for spacing reasons and to possibly put insertion buttons there

#define kAlignmentGridExtraSpaceAtBottomOfScrollView 20

#define kReadLongPressRecognizerMinDuration 1.0f

@interface AlignmentGridView : QuickGridView {
    __strong AlignmentGridPosition **alignmentGridPositionsArr;//Strong means ARC won't destroy this object unless it is set to nil, ** is a Pointer to a pointer
    int currYOffset;
    
    BOOL isScrollingHorizontally;
    
    UILongPressGestureRecognizer *longPressRecognizer;
}
- (IBAction)readLongPressed:(id)sender;
- (void)displayReadPopoverForRead:(ED_Info *)read atPosInGenome:(int)pos atPointOnScreen:(CGPoint)point;
- (void)setUpAlignmentGridPositionsArr;
- (int)readInfoNumForX:(int)x len:(int)len andInsCount:(int)insCount andStartsBefore0:(BOOL)startsBefore0;
//- (void)setUpPositionMatchedCharsArr;
- (void)drawReadStartAtPoint:(CGPoint)point withColorRef:(CGColorRef)colorRef;
- (void)drawReadEndAtPoint:(CGPoint)point withColorRef:(CGColorRef)colorRef;;
- (void)drawReadBodyAtPoint:(CGPoint)point withColorRef:(CGColorRef)colorRef;
- (void)drawReadBodyAtPoint:(CGPoint)point nextToAnEnd:(int)end withColorRef:(CGColorRef)colorRef;;
//- (void)drawReadWithEDInfo:(ED_Info*)read atX:(float)x andY:(float)y;
//- (void)drawCharColumnWithTxt:(NSString*)txt atX:(float)x andY:(float)y;
- (void)drawCharColumnWithAlignmentGridPos:(AlignmentGridPosition*)gridPos withGridPosIndexInGridPosArr:(int)j atX:(float)x andY:(float)y andYToNotCross:(int)yToNotCross;

- (void)freeUsedMemory;
@end
