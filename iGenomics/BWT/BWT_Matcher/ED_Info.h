//
//  ED_Info.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 11/11/12.
//
//

#import <Foundation/Foundation.h>

//used for info returned by the EditDist class

@interface ED_Info : NSObject {
    char *gappedA;
    char *gappedB;
    char *readName;
    int position;
    int distance;
    BOOL insertion;
    BOOL isRev;
}
@property (nonatomic) BOOL isRev;
@property (nonatomic) char *gappedA, *gappedB, *readName;
@property (nonatomic) int position, distance, numOfInsertions;
@property (nonatomic) int rowInAlignmentGrid;//Should only be modified/accessed by AlignmentGridView class
@property (nonatomic) BOOL insertion;
- (id)initWithPos:(int)pos editDistance:(int)dist gappedAStr:(char*)gA gappedBStr:(char*)gB isIns:(BOOL)ins isReverse:(BOOL)isReverse;
+ (BOOL)areEqualEditDistance1:(ED_Info*)ed1 andEditDistance2:(ED_Info*)ed2;
+ (ED_Info*)mergedED_Infos:(ED_Info*)ed1 andED2:(ED_Info*)ed2;//Pre-condition: ed1.position <= ed2.position
- (int)intValue;

- (void)freeUsedMemory;
@end
