//
//  BWT_Matcher.h
//  LabProject7
//
//  Created by Stuckinaboot Inc. on 9/15/12.
//
//

#import <Foundation/Foundation.h>
#import <libkern/OSAtomic.h>
#import "GlobalVars.h"

#import "BWT_Matcher_InsertionDeletion.h"
#import "BWT_Matcher_InsertionDeletion_InsertionHolder.h"
#import "BWT_Matcher_Approxi.h"
#import "ED_Info.h"
#import "Chunks.h"
#import "BWT_MatcherSC.h"
#import "Read.h"
//#import "MatchedReadData.h"

//CONSTANTS
#define kAlignmentTypeForward 1
#define kAlignmentTypeForwardAndReverse 0

#define kReedsArraySeperationStr @"\n"

#define kReadLoopMaxSmallEditDist 20
#define kReadLoopLargeEditDistStepFactor 0.15 //kReadLoopLargeEditDistStepFactor * maxEdit

#define kBWT_MatcherReadAlignerMultiThreadStride 10


//#define kBytesForIndexer 101//101
//#define kMultipleToCountAt 50//50

#define kLowestAllowedCoverage 5

#define kDebugPrintInsertions 0
#define kDebugOn 0

#define kDebugAllInfo 0 //THIS IS THE ONLY ONE NEEDED TO KEEP

#define kPrintReadInfo 0

//MAKE LASTCOL (BWT) AND FIRSTCOL VARIABLE IN THE HEADER FILE
//WORK ON EXPORT (FILE IS ON DESKTOP)

extern int posOccArray[kACGTwithInDelsLen][kMaxBytesForIndexer*kMaxMultipleToCountAt];//+2 because of deletions +1(-) and insertions +2(+) __________________I----- GLOBAL ------I

@protocol BWT_MatcherDelegate <NSObject>
- (void)readAligned;
- (void)readProccesed:(NSString*)readData andMatchedAtLeastOnce:(BOOL)didMatch;
@end
@interface BWT_Matcher : NSObject {
    
    //Parameters
    int matchType;
    int alignmentType;
    
    //New Vars
    float maxErrorRate;
    NSMutableArray *reedsArray;
    int readNum;
    
    APTimer *matchingTimer;
    
    NSMutableArray *insertionsArray;
    
    NSMutableArray *cumulativeSeparateGenomeLens;
    
    BWT_MatcherSC *exactMatcher;
    
    float totalAlignmentRuntime;
    
    char *originalStrWithDividers;
}
@property (nonatomic) id <BWT_MatcherDelegate> delegate;
@property (nonatomic) NSMutableArray *insertionsArray, *cumulativeSeparateGenomeLens;
@property (nonatomic) int kBytesForIndexer, /*kMultipleToCountAt, */alignmentType, matchType;
@property (nonatomic) int readLen, refSeqLen, numOfReads;

- (void)setUpReedsFileContents:(NSString*)contents refStrBWT:(char*)bwt andMaxErrorRate:(double)maxER;

- (char*)getReverseComplementForSeq:(char*)seq seqLen:(int)actualReadLen;

- (void)matchReedsWithSeedingState:(BOOL)seedingState;

- (void)setUpNumberOfOccurencesArray;

//APPROXI MATCH
- (ED_Info*)getBestMatchForQuery:(char*)query withLastCol:(char*)lastCol andFirstCol:(char*)firstCol andNumOfSubs:(int)amtOfSubs andReadNum:(int)readNum andShouldSeed:(BOOL)shouldSeed forReadLen:(int)actualReadLen ;//readNum is only for printing to console, serves no other purpose currently

- (void)updatePosOccsArrayWithRange:(NSRange)range andED_Info:(ED_Info *)info;//info is NULL for a non indel match

//INSERTION/DELETION MATCH
- (NSMutableArray*)insertionDeletionMatchesForQuery:(char*)query andLastCol:(char*)lastCol andNumOfSubs:(int)numOfSubs andIsReverse:(BOOL)isRev andShouldSeed:(BOOL)shouldSeed readLen:(int)actualReadLen;
- (void)recordInDel:(ED_Info*)info;
- (float)getTotalAlignmentRuntime;

- (void)freeUsedMemory;
@end
