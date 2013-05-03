//
//  BWT_Matcher_InsertionDeletion.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 10/29/12.
//
//

#import <Foundation/Foundation.h>

#import "EditDistance.h"
#import "MatchedReadData.h"
#import "Chunks.h"

#define kPrintInDelPos 0

@interface BWT_Matcher_InsertionDeletion : NSObject {
    EditDistance *editDist;
    NSMutableArray *matchedInDels;
    int maxEditDist;
    BOOL isRev;
}
- (NSMutableArray*)setUpWithCharA:(char*)a andCharB:(char*)b andChunks:(NSMutableArray*)chunkArray andMaximumEditDist:(int)maxED andIsReverse:(BOOL)isR;
- (void)findInDels:(char*)a andCharB:(char*)b andChunks:(NSMutableArray*)chunkArray;
- (void)checkForInDelMatch:(ED_Info*)edInfo andMatchedPos:(int)matchedPos andChunkNum:(int)cNum andChunkSize:(int)cSize;//If true, done searching and just return

- (int)findStartPosForChunkNum:(int)cNum andSizeOfChunks:(int)cSize andMatchedPos:(int)mPos;
@end
