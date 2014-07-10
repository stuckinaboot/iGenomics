//
//  GlobalVars.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/19/13.
//
//

//You may consider Global Variables, let alone a class dedicated to them, to be bad programming practice but they allowed me to avoid a hell of a lot of strcpys and declerations of extra large-scale arrays/matrices so if you would like to restructure my whole code to avoid all of them you can do so, but I am not going to

#import <Foundation/Foundation.h>
#import "Reachability.h"

typedef enum {
    MatchTypeExactOnly,
    MatchTypeExactAndSubs,
    MatchTypeSubsAndIndels
} MatchType;

//Debugging constants
#define kPrintExportStrToConsole 1
#define kCrashDebug 1
//End debugging constants

#define kReadExportDataBasicInfo @"%s,%i,%c,%i,%s,%s\n"//read name, position, forward/reverse, gapped b, gapped a
#define kReadExportDataCompleteInfo @"%s,%i,%s,%c,%i,%s,%s\n"//read name, position relative to segment, segment, forward/reverse, gapped b, gapped a --May not even need to be used but is good to have to show the format
#define kReadExportDataComponentDivider @","//What divides each component of the string.
#define kReadExportDataStrPositionIndex 1 //Index of position in the string

#define kMaxMultipleToCountAt 16
#define kMaxBytesForIndexer 100000
#define kMultipleToCountAt 16

#define kACGTLen 4
#define kACGTStr "ACGT"
#define kACGTwithInDels "ACGT-+"

#define kBaseUnknownChar 'N'
#define kMinReadLength 15 //If a read is trimmed below this minimum

#define kNoGappedBChar "X"

#define kLineBreak @"\n"
#define kTxt @"txt"

#define kRefFileInternalDivider @",,"//This constant is used to divide the multiple reference file names
#define kRefFileDisplayedDivider @", "//Used when displaying the multiple reference file names

#define kFaFileTitleIndicator '>'

#define kParameterArrayMatchTypeIndex 0
#define kParameterArrayEDIndex 1
#define kParameterArrayFoRevIndex 2
#define kParameterArrayMutationCoverageIndex 3
#define kParameterArrayTrimmingValIndex 4
#define kParameterArrayTrimmingRefCharIndex 5
#define kParameterArrayRefFileSegmentNamesIndex 6
#define kParameterArrayReadFileNameIndex 7

#define kScrollViewSliderUpdateInterval 0.001

#define kNoInternetAlertTitle @"Error"
#define kNoInternetAlertMsg @"No Internet Connection Available"
#define kNoInternetAlertBtn @"Ok"

#define kKeyboardToolbarHeight 50
#define kKeyboardDoneBtnTxt @"Done"

#define kAlertBtnTitleCancel @"Cancel"

#define kOldIPhoneScreenSize 480

#define kBWTFileExt @"bwt"
#define kBWTFileDividerBtwBWTandBenchmarkPosList @"\n--------\n"

extern int bytesForIndexer;
extern int dgenomeLen; //d means including dollar sign
extern char *originalStr;
extern char *refStrBWT;
extern char *firstCol;
extern char *acgt;
extern int acgtOccurences[kMaxBytesForIndexer][kACGTLen];//Occurences for up to each multiple to count at
extern int benchmarkPositions[kMaxBytesForIndexer*kMultipleToCountAt];
extern int acgtTotalOccs[kACGTLen];

extern NSMutableArray* readAlignmentsArr;//Contains the ED_Info for each aligned read

@interface GlobalVars : NSObject
+ (void)sortArrayUsingQuicksort:(NSMutableArray*)array withStartPos:(int)startPos andEndPos:(int)endpos;
+ (BOOL)internetAvailable;
+ (BOOL)isIpad;
+ (BOOL)isOldIPhone;
+ (NSString*)extFromFileName:(NSString *)name;
@end
