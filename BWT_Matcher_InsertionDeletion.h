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
#define kNonSeedShortSeqSize 30

#define kNonSeedShortSeqMinSize 12
static int kNonSeedShortSeqSizeIntervals[] = {12};//{16, 12};//{19,12,10};
#define kNonSeedShortSeqSizeIntervalsCount 1
#define kNonSeedShortSeqInterval 10//100
#define kNonSeedLongSeqSize 100

@interface BWT_Matcher_InsertionDeletion : NSObject {
    EditDistance *editDist;
    NSMutableArray *matchedInDels;
    int maxEditDist;
    float maxErrorRate;
    BOOL isRev;
    
    NSArray *cumulativeSegmentLens;
}
- (NSMutableArray*)setUpWithCharA:(char*)a andCharB:(char*)b andChunks:(NSMutableArray*)chunkArray andMaximumEditDist:(int)maxED andIsReverse:(BOOL)isR;
- (NSMutableArray*)setUpWithCharA:(char*)a andCharB:(char*)b andMaximumEditDist:(int)maxED andIsReverse:(BOOL)isR withCumulativeSegmentLengthsArr:(NSArray*)cumLens;
- (void)findInDels:(char*)a andCharB:(char*)b andChunks:(NSMutableArray*)chunkArray;
- (void)findInDels:(char*)a andCharB:(char*)b withCumulativeSegmentLengthsArr:(NSArray*)cumLens;

- (NSMutableArray*)setUpWithNonSeededCharA:(char*)a andCharB:(char*)b andMaximumEditDist:(int)maxED andIsReverse:(BOOL)isR andExactMatcher:(BWT_MatcherSC *)exactMatcher andCumSegLensArr:(NSArray *)cumLens andErrorRate:(float)errorRate;
- (void)findInDelsNonSeededWithA:(char*)a b:(char*)b usingExactMatcher:(BWT_MatcherSC*)exactMatcher isReverse:(BOOL)isReverse;
- (ED_Info*)nonSeededEDForFullA:(char*)fullA fullALen:(int)lenA andB:(char*)b startPos:(int)startPos andIsComputingForward:(BOOL)forward;


- (void)checkForInDelMatch:(ED_Info*)edInfo andMatchedPos:(int)matchedPos andChunkNum:(int)cNum andChunkSize:(int)cSize;//If true, done searching and just return

- (int)findStartPosForChunkNum:(int)cNum andSizeOfChunks:(int)cSize andMatchedPos:(int)mPos;
@end
