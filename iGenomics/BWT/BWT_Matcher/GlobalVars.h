//
//  GlobalVars.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/19/13.
//
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

typedef enum {
    MatchTypeExactOnly,
    MatchTypeExactAndSubs,
    MatchTypeSubsAndIndels
} MatchType;

//Debugging constants
#define kPrintExportStrToConsole 1

//End debugging constants

#define kMaxMultipleToCountAt 16
#define kMaxBytesForIndexer 100000
#define kMultipleToCountAt 16

#define kACGTLen 4
#define kACGTStr "ACGT"
#define kACGTwithInDels "ACGT-+"

#define kNoGappedBChar "X"

#define kLineBreak @"\n"
#define kTxt @"txt"

#define kScrollViewSliderUpdateInterval 0.001

#define kNoInternetAlertTitle @"Error"
#define kNoInternetAlertMsg @"No Internet Connection Available"
#define kNoInternetAlertBtn @"Ok"

extern int bytesForIndexer;
extern int dgenomeLen; //d means including dollar sign
extern char *originalStr;
extern char *refStrBWT;
extern char *firstCol;
extern char *acgt;
extern int acgtOccurences[kMaxBytesForIndexer][kACGTLen];//Occurences for up to each multiple to count at
extern int benchmarkPositions[kMaxBytesForIndexer*kMultipleToCountAt];
extern int acgtTotalOccs[kACGTLen];

@interface GlobalVars : NSObject
+ (void)sortArrayUsingQuicksort:(NSMutableArray*)array withStartPos:(int)startPos andEndPos:(int)endpos;
+ (BOOL)internetAvailable;
+ (BOOL)isIpad;
@end
