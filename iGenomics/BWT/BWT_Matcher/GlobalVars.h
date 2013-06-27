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

#define kMaxBytesForIndexer 101
#define kMaxMultipleToCountAt 100

#define kACGTLen 4
#define kACGTStr "ACGT"
#define kACGTwithInDels "ACGT-+"

#define kNoGappedBChar "X"

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
