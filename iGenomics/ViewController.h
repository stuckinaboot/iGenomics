//
//  ViewController.h
//  LabProject5
//
//  Created by Stuckinaboot Inc. on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chunks.h"

//Find rev/forward for 0 mismatches. If some, choose at random. If none, add +1 and search. If none continues keep doing until you hit kmaxsubs

#define kNumOfSubs 1

#define kBytesForIndexer 10 
//#define kBytesForIndexer 1000 //Num of possible amount of rows to be in index kBytes*kMult = total num of chars possible in array
//#define kMultipleToCountAt 100
#define kMultipleToCountAt 3   

//#define kACGTLen 26
//#define kACGTStr "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
#define kACGTLen 4
#define kACGTStr "ACGT"

#define kDebugON 1


#define kHeteroAllowance 1 //Greater than 1
//char* matrix ==== [pos][char pos]

@interface ViewController : UIViewController {
    char *fileString;
    char *foundGenome[4];
    
    NSMutableArray *reedsArray;
    int posOccArray[kACGTLen][kBytesForIndexer*kMultipleToCountAt];
    
    int acgtOccurences[kBytesForIndexer][kACGTLen];//Occurences for up to each multiple to count at
    char *acgt;
    int acgtTotalOccs[kACGTLen];
}
- (char*)getReverseComplementForSeq:(char*)seq;

- (void)matchReedsArray:(NSArray *)array withLastCol:(char*)lastCol andFirstCol:(char*)firstCol;

- (NSArray*)positionInBWTwithPosInBWM:(NSArray*)posArray andFirstCol:(char*)firstColumn andLastCol:(char*)lastColumn;
- (char*)unravelCharWithLastColumn:(char*)lastColumn firstColumn:(char*)firstColumn;

- (int)getIndexOfNth:(int)n OccurenceOfChar:(char)c inChar:(char*)container;
- (int)whichOccurenceOfChar:(char)c inChar:(char*)container atPos:(int)pos;

- (NSArray*)exactMatchForQuery:(char*)query withLastCol:(char*)lastCol andFirstCol:(char*)firstCol;
- (int)LFC:(int)r andChar:(char)c withLastCol:(char*)lastCol;//The row (r) of the char (c)

- (void)setUpNumberOfOccurencesArray;

- (int)whichChar:(char)c inContainer:(char*)container;

- (int)charsBeforeChar:(char)c;

//APPROXI MATCH
- (NSArray*)approxiMatchForQuery:(char*)query withLastCol:(char*)lastCol andFirstCol:(char*)firstCol andNumOfSubs:(int)amtOfSubs;

- (int)getBestMatchForQuery:(char*)query withLastCol:(char*)lastCol andFirstCol:(char*)firstCol andNumOfSubs:(int)amtOfSubs;

- (BOOL)isNotDuplicateAlignment:(NSArray*)subsArray andChunkNum:(int)chunkNum;
- (void)updatePosOccsArrayWithRange:(NSRange)range andOriginalStr:(char*)originalStr andQuery:(char*)query;
char *substr(const char *pstr, int start, int numchars);

- (void)buildOccTableWithUnravStr:(char*)unravStr;

- (void)sortArrayUsingQuicksort:(NSMutableArray*)array withStartPos:(int)startPos andEndPos:(int)endpos;

- (NSArray*)reedsArrayForFileName:(NSString*)name andExt:(NSString*)ext;
- (NSArray*)findMutationsWithOriginalSeq:(char*)seq; 
@end
