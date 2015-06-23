//
//  BWT_Matcher_InsertionDeletion.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 10/29/12.
//
//

#import <Foundation/Foundation.h>

#import "EditDistance.h"
#import "APTimer.h"
#import "BWT_MatcherSC.h"
//#import "MatchedReadData.h"
#import "Chunks.h"

#define kPrintInDelPos 0
#define kNonSeedShortSeqSize 20
#define kNonSeedLongSeqSize 100

@interface BWT_Matcher_InsertionDeletion : NSObject {
    EditDistance *editDist;
    NSMutableArray *matchedInDels;
    int maxEditDist;
    BOOL isRev;
}
- (NSMutableArray*)setUpWithCharA:(char*)a andCharB:(char*)b andChunks:(NSMutableArray*)chunkArray andMaximumEditDist:(int)maxED andIsReverse:(BOOL)isR;
- (NSMutableArray*)setUpWithCharA:(char*)a andCharB:(char*)b andMaximumEditDist:(int)maxED andIsReverse:(BOOL)isR withCumulativeSegmentLengthsArr:(NSArray*)cumLens;
- (void)findInDels:(char*)a andCharB:(char*)b andChunks:(NSMutableArray*)chunkArray;
- (void)findInDels:(char*)a andCharB:(char*)b withCumulativeSegmentLengthsArr:(NSArray*)cumLens;



- (NSMutableArray*)setUpWithNonSeededCharA:(char*)a andCharB:(char*)b andMaximumEditDist:(int)maxED andIsReverse:(BOOL)isR andExactMatcher:(BWT_MatcherSC*)exactMatcher;
- (void)findInDelsNonSeededWithA:(char*)a b:(char*)b usingExactMatcher:(BWT_MatcherSC*)exactMatcher;
- (ED_Info*)nonSeededEDForFullA:(char*)fullA fullALen:(int)lenA andB:(char*)b startPos:(int)startPos andIsComputingForward:(BOOL)forward;


- (void)checkForInDelMatch:(ED_Info*)edInfo andMatchedPos:(int)matchedPos andChunkNum:(int)cNum andChunkSize:(int)cSize;//If true, done searching and just return

- (int)findStartPosForChunkNum:(int)cNum andSizeOfChunks:(int)cSize andMatchedPos:(int)mPos;
@end
