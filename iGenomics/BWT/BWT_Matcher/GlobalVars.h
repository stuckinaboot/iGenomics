//
//  GlobalVars.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/19/13.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    MatchTypeExactOnly,
    MatchTypeExactAndSubs,
    MatchTypeSubsAndIndels
} MatchType;

//Debugging constants
#define kPrintExportStrToConsole 1

//End debugging constants

#define kMaxMultipleToCountAt 64
#define kMaxBytesForIndexer 100000

#define kACGTLen 4
#define kACGTStr "ACGT"
#define kACGTwithInDels "ACGT-+"

#define kNoGappedBChar "X"

#define kLineBreak @"\n"
#define kTxt @"txt"

extern int bytesForIndexer;
extern int fileStrLen;
extern char *originalStr;
extern char *refStrBWT;
extern char *firstCol;
extern char *acgt;
extern int acgtOccurences[kMaxBytesForIndexer][kACGTLen];//Occurences for up to each multiple to count at
extern int acgtTotalOccs[kACGTLen];
extern int kMultipleToCountAt;

@interface GlobalVars : NSObject
+ (void)sortArrayUsingQuicksort:(NSMutableArray*)array withStartPos:(int)startPos andEndPos:(int)endpos;
@end
