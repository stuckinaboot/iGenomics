//
//  BWT_Matcher_Approxi.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 4/20/13.
//
//

#import <Foundation/Foundation.h>
#import "BWT_MatcherSC.h"
#import "BWT_Matcher.h"
//#import "MatchedReadData.h"

@interface BWT_Matcher_Approxi : BWT_MatcherSC {
    APTimer *approxTimer;
    int charsToCheckRight, charsToCheckLeft;
    int leftStrStart, rightStrStart;
    int numOfSubstitutions;
    int numOfChunks;
    int sizeOfChunks;
    
    NSMutableArray *positionsArray;
}
- (NSArray*)approxiMatchForQuery:(char*)query andNumOfSubs:(int)amtOfSubs andIsReverse:(BOOL)isRev andReadLen:(int)queryLength cumSepGenomeLens:(NSArray*)cumSepGenomeLens;
- (void)addAlignmentsToPosArrayForChunkNum:(int)cNum posIndex:(int)x sizeOfChunks:(int)len matchedChunk:(Chunks*)chunk queryLen:(int)qLen andIsRev:(BOOL)isRev andED:(int)distance andQuery:(char*)query;
@end
