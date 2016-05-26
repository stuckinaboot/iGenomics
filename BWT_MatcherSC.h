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

#define kDelMarker '-'
#define kInsMarker '+'

#define kOriginalStrSegmentLetterDividersLen 1000
#define kOriginalStrSegmentLetterDivider 'B'
#define kSoftClippingCharsInARowThresholdToFinish 3 //Originally was 5

@interface BWT_MatcherSC : NSObject {
    APTimer *timer;
}

- (NSArray*)exactMatchForQuery:(char*)query andIsReverse:(BOOL)isRev andForOnlyPos:(BOOL)forOnlyPos;//if forOnlyPos = true, will return just the position
- (NSArray*)exactMatchForChunk:(Chunks*)chunk andIsReverse:(BOOL)isRev andForOnlyPos:(BOOL)forOnlyPos;
- (BOOL)isNotDuplicateAlignment:(ED_Info*)info inArr:(NSMutableArray*)posArr;
//- (NSArray*)positionInBWTwithPosInBWMForArr:(NSArray*)posArray andIsReverse:(BOOL)isRev andForOnlyPos:(BOOL)forOnlyPos andForED:(int)ed andForQuery:(char*)query;
- (ED_Info*)positionInBWTwithPosInBWM:(int)position andIsReverse:(BOOL)isRev andForOnlyPos:(BOOL)forOnlyPos andForED:(int)ed andForQuery:(char*)query;
- (int)positionOfChunkInBWTwithPosInBWM:(int)position andIsReverse:(BOOL)isRev andForOnlyPos:(BOOL)forOnlyPos andForED:(int)ed;
- (int)charsBeforeChar:(char)c;
+ (int)whichChar:(char)c inContainer:(char*)container;
- (int)LFC:(int)r andChar:(char)c;
- (int)getIndexOfNth:(int)n OccurenceOfChar:(char)c inChar:(char*)container;

- (char*)unravelCharWithLastColumn:(char*)lastColumn firstColumn:(char*)firstColumn;

- (void)timerPrint;

//Clipping
+ (ED_Info*)infoByAdjustingForSegmentDividerLettersForInfo:(ED_Info*)info cumSepSegLens:(NSMutableArray*)cumulativeSeparateGenomeLens;
+ (ED_Info*)infoByUnjustingForSegmentDividerLettersForInfo:(ED_Info*)info cumSepSegLens:(NSMutableArray*)cumulativeSeparateGenomeLens;
+ (NSArray*)arrayByUnjustingForsegmentDividerLettersForArr:(NSArray*)arr cumSepSegLens:(NSMutableArray*)lens;
+ (NSArray*)positionsArrayByUnjustingForsegmentDividerLettersForArr:(NSArray*)arr cumSepSegLens:(NSMutableArray*)lens;

+ (ED_Info*)updatedInfoCorrectedForExtendingOverSegmentStartsAndEnds:(ED_Info *)info forNumOfSubs:(int)subs withCumSepGenomeLens:(NSArray*)cumulativeSeparateGenomeLens maxErrorRate:(float)errorRate originalReadLen:(int)originalReadLen;
+ (int)indexInCumSepGenomeLensArrOfClosestSegmentEndingForEDInfo:(ED_Info*)info withCumSepGenomeLens:(NSArray*)cumulativeSeparateGenomeLens;
+ (int)numOfCharsPastSegmentEndingForEDInfo:(ED_Info *)info andReadLen:(int)readL andIndexInCumSepGenomesOfClosestSegmentEndingPos:(int)index withCumSepGenomeLens:(NSArray*)cumulativeSeparateGenomeLens;
+ (int)numOfCharsBeforeSegmentEndingForEDInfo:(ED_Info *)info andReadLen:(int)readL andIndexInCumSepGenomesOfClosestSegmentEndingPos:(int)index andNumOfInsertionsBeforeEnding:(int)numOfInsertions withCumSepGenomeLens:(NSArray*)cumulativeSeparateGenomeLens;
+ (int)numOfInsertionsBeforeSegmentEndingForEDInfo:(ED_Info*)info andIndexInCumSepGenomesOfClosestSegmentEndingPos:(int)index withCumSepGenomeLens:(NSArray*)cumulativeSeparateGenomeLens;
+ (int)numOfInsertionsPastSegmentEndingForEDInfo:(ED_Info *)info andIndexInCumSepGenomesOfClosestSegmentEndingPos:(int)index withCumSepGenomeLens:(NSArray*)cumulativeSeparateGenomeLens;
@end
