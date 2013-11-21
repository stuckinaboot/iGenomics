//
//  BWT_MatcherSC.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 4/20/13.
//
//

#import <Foundation/Foundation.h>
//#import "MatchedReadData.h"
#import "ED_Info.h"
#import "Chunks.h"
#import "GlobalVars.h"
#import "APTimer.h"

@interface BWT_MatcherSC : NSObject {
    APTimer *timer;
}

- (NSArray*)exactMatchForQuery:(char*)query andIsReverse:(BOOL)isRev andForOnlyPos:(BOOL)forOnlyPos;//if forOnlyPos = true, will return just the position
- (NSArray*)exactMatchForChunk:(Chunks*)chunk andIsReverse:(BOOL)isRev andForOnlyPos:(BOOL)forOnlyPos;
- (BOOL)isNotDuplicateAlignment:(NSArray*)subsArray andChunkNum:(int)chunkNum;
//- (NSArray*)positionInBWTwithPosInBWMForArr:(NSArray*)posArray andIsReverse:(BOOL)isRev andForOnlyPos:(BOOL)forOnlyPos andForED:(int)ed andForQuery:(char*)query;
- (ED_Info*)positionInBWTwithPosInBWM:(int)position andIsReverse:(BOOL)isRev andForOnlyPos:(BOOL)forOnlyPos andForED:(int)ed andForQuery:(char*)query;
- (int)positionOfChunkInBWTwithPosInBWM:(int)position andIsReverse:(BOOL)isRev andForOnlyPos:(BOOL)forOnlyPos andForED:(int)ed;
- (int)charsBeforeChar:(char)c;
+ (int)whichChar:(char)c inContainer:(char*)container;
- (int)LFC:(int)r andChar:(char)c;
- (int)getIndexOfNth:(int)n OccurenceOfChar:(char)c inChar:(char*)container;

- (void)timerPrint;
@end
