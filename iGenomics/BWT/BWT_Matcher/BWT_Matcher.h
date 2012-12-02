//
//  BWT_Matcher.h
//  LabProject7
//
//  Created by Stuckinaboot Inc. on 9/15/12.
//
//

#import <Foundation/Foundation.h>
#import "BWT_Matcher_InsertionDeletion.h"
#import "BWT_Matcher_InsertionDeletion_InsertionHolder.h"
#import "ED_Info.h"
#import "Chunks.h"

//CONSTANTS
#define kReedsArraySeperationStr @"\n"

#define kMaxBytesForIndexer 100
#define kMaxMultipleToCountAt 100
//#define kBytesForIndexer 101//101
//#define kMultipleToCountAt 50//50

#define kACGTLen 4
#define kACGTStr "ACGT"

#define kDelMarker '-'
#define kInsMarker '+'

#define kLowestAllowedCoverage 5
#define kHeteroAllowance 1 //Greater than 1

#define kMaxEditDist 2

#define kDebugPrintInsertions 0
#define kDebugOn 0

@interface BWT_Matcher : NSObject {
    
    int kBytesForIndexer;
    int kMultipleToCountAt;
    
    //New Vars
    int maxSubs;
    NSArray *reedsArray;
    char *refStrBWT;
    int fileStrLen;
    
    //Old Vars
    int posOccArray[kACGTLen+2][kMaxBytesForIndexer*kMaxMultipleToCountAt];//+2 because of deletions +1(-) and insertions +2(+)
    NSMutableArray *insertionsArray;
    int acgtOccurences[kMaxBytesForIndexer][kACGTLen];//Occurences for up to each multiple to count at
    char *acgt;
    int acgtTotalOccs[kACGTLen];
    
    int coverageArray[kMaxBytesForIndexer*kMaxMultipleToCountAt];
}
@property (nonatomic) int kBytesForIndexer, kMultipleToCountAt;
- (void)setUpReedsFile:(NSString*)fileName fileExt:(NSString*)fileExt refStrBWT:(char*)bwt andMaxSubs:(int)subs;

- (int)getPosOccArrayObj:(int)x:(int)y;
//- (NSString*)getPosOccArray; //FORMAT: 2,3,5,4,3,3\n3,3,2,3,6\n3,3,2,1,1\n5,5,3,2,3

- (char*)getReverseComplementForSeq:(char*)seq;

- (void)matchForJustIndels:(NSArray*)array withLastCol:(char*)lastCol;
- (void)matchReedsArray:(NSArray *)array withLastCol:(char*)lastCol andFirstCol:(char*)firstCol;

- (NSArray*)positionInBWTwithPosInBWM:(NSArray*)posArray andFirstCol:(char*)firstColumn andLastCol:(char*)lastColumn;
- (char*)unravelCharWithLastColumn:(char*)lastColumn firstColumn:(char*)firstColumn;

- (int)getIndexOfNth:(int)n OccurenceOfChar:(char)c inChar:(char*)container;
- (int)whichOccurenceOfChar:(char)c inChar:(char*)container atPos:(int)pos;

- (NSArray*)exactMatchForQuery:(char*)query withLastCol:(char*)lastCol andFirstCol:(char*)firstCol;
- (int)LFC:(int)r andChar:(char)c withLastCol:(char*)lastCol;//The row (r) of the char (c)

- (void)setUpNumberOfOccurencesArray;
- (void)setUpBytesForIndexerAndMultipleToCountAt:(int)seqLen;//This can be modified if necessary

- (int)whichChar:(char)c inContainer:(char*)container;

- (int)charsBeforeChar:(char)c;

//APPROXI MATCH
- (NSArray*)approxiMatchForQuery:(char*)query withLastCol:(char*)lastCol andFirstCol:(char*)firstCol andNumOfSubs:(int)amtOfSubs;

- (int)getBestMatchForQuery:(char*)query withLastCol:(char*)lastCol andFirstCol:(char*)firstCol andNumOfSubs:(int)amtOfSubs;//returns >-1 for a match, -1 for no match, and <-1 for a rev comp match

- (BOOL)isNotDuplicateAlignment:(NSArray*)subsArray andChunkNum:(int)chunkNum;
- (void)updatePosOccsArrayWithRange:(NSRange)range andOriginalStr:(char*)originalStr andQuery:(char*)query;
char *substr(const char *pstr, int start, int numchars);

//INSERTION/DELETION MATCH
- (NSMutableArray*)insertionDeletionMatchesForQuery:(char*)query andLastCol:(char*)lastCol;
@end
