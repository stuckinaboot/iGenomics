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

#define kAlignmentGridViewMaxCharsReadSpacing 2

#define kAlignmentGridViewNumOfGridSections 4 //Includes graph row for spacing reasons and to possibly put insertion buttons there

@interface AlignmentGridView : QuickGridView {
//    NSMutableArray *positionMatchedCharsArr;
//    NSMutableArray *positionMatchedIndecesArr;
//    NSMutableArray *alignmentGridPositionsArr;
//    char *alignmentGridPosStrings;
//    char *alignmentGridPosReadInfo;
    __strong AlignmentGridPosition **alignmentGridPositionsArr;
//    AlignmentGridPosition *alignmentGridPositions;
    int currYOffset;
//    ED_Info *alignmentGridPositionsArr[kMaxBytesForIndexer*kMaxMultipleToCountAt];
//    int readStartsIndexArr[kMaxBytesForIndexer*kMaxMultipleToCountAt];//Size of the genome, contains the first index in the readAlignmentsArr where a read matched pos was there
    
}
- (void)setUpAlignmentGridPositionsArr;
//- (void)setUpPositionMatchedCharsArr;
- (void)drawReadStartAtPoint:(CGPoint)point;
- (void)drawReadEndAtPoint:(CGPoint)point;
- (void)drawReadBodyAtPoint:(CGPoint)point;
- (void)drawReadBodyAtPoint:(CGPoint)point nextToAnEnd:(int)end;
//- (void)drawReadWithEDInfo:(ED_Info*)read atX:(float)x andY:(float)y;
//- (void)drawCharColumnWithTxt:(NSString*)txt atX:(float)x andY:(float)y;
- (void)drawCharColumnWithAlignmentGridPos:(AlignmentGridPosition*)gridPos atX:(float)x andY:(float)y andYToNotCross:(int)yToNotCross;
@end
