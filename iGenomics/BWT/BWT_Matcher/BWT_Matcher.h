//
//  BWT_Matcher.h
//  LabProject7
//
//  Created by Stuckinaboot Inc. on 9/15/12.
//
//

//ORGANIZE INTO FUNCTIONS

#import <Foundation/Foundation.h>
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
#define kReedsArraySeperationStr @"\n"

//#define kBytesForIndexer 101//101
//#define kMultipleToCountAt 50//50

#define kDelMarker '-'
#define kInsMarker '+'

#define kLowestAllowedCoverage 5

#define kDebugPrintInsertions 0
#define kDebugOn 0

#define kDebugAllInfo 0 //THIS IS THE ONLY ONE NEEDED TO KEEP

#define kPrintReadInfo 0

//MAKE LASTCOL (BWT) AND FIRSTCOL VARIABLE IN THE HEADER FILE
//WORK ON EXPORT (FILE IS ON DESKTOP)

extern int posOccArray[kACGTLen+2][kMaxBytesForIndexer*kMaxMultipleToCountAt];//+2 because of deletions +1(-) and insertions +2(+) __________________I----- GLOBAL ------I

@protocol BWT_MatcherDelegate <NSObject>
- (void)readProccesed:(NSString*)readData;
@end
@interface BWT_Matcher : NSObject {
    
    //Parameters
    int matchType;
    int alignmentType;
    
    //New Vars
    int maxSubs;
    NSMutableArray *reedsArray;
    int readNum;
    
    APTimer *matchingTimer;
    
    NSMutableArray *insertionsArray;
    
    BWT_MatcherSC *exactMatcher;
    
    NSMutableString *readDataStr;
}
@property (nonatomic) id <BWT_MatcherDelegate> delegate;
@property (nonatomic) NSMutableArray *insertionsArray;
@property (nonatomic) int kBytesForIndexer, /*kMultipleToCountAt, */alignmentType, matchType;
@property (nonatomic) int readLen, refSeqLen, numOfReads;

- (id)initWithOriginalStr:(char*)orgStr;
- (void)setUpReedsFileContents:(NSString*)contents refStrBWT:(char*)bwt andMaxSubs:(int)subs;

- (char*)getReverseComplementForSeq:(char*)seq;

- (void)matchReeds;

- (void)setUpNumberOfOccurencesArray;

//APPROXI MATCH
- (ED_Info*)getBestMatchForQuery:(char*)query withLastCol:(char*)lastCol andFirstCol:(char*)firstCol andNumOfSubs:(int)amtOfSubs andReadNum:(int)readNum;//readNum is only for printing to console, serves no other purpose currently

- (void)updatePosOccsArrayWithRange:(NSRange)range andED_Info:(ED_Info *)info;//info is NULL for a non indel match
char *substr(const char *pstr, int start, int numchars);

//INSERTION/DELETION MATCH
- (NSMutableArray*)insertionDeletionMatchesForQuery:(char*)query andLastCol:(char*)lastCol andNumOfSubs:(int)numOfSubs andIsReverse:(BOOL)isRev;
- (void)recordInDel:(ED_Info*)info;
@end
