//
//  BWT_MatcherSC.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 4/20/13.
//
//

#import <Foundation/Foundation.h>

#define kACGTLen 4
#define kACGTStr "ACGT"

#define kMaxBytesForIndexer 101
#define kMaxMultipleToCountAt 100

extern int fileStrLen;
extern char *originalStr;
extern char *refStrBWT;
extern char *acgt;
extern int acgtOccurences[kMaxBytesForIndexer][kACGTLen];//Occurences for up to each multiple to count at
extern int acgtTotalOccs[kACGTLen];
extern int kMultipleToCountAt;

@interface BWT_MatcherSC : NSObject {

}
- (NSArray*)exactMatchForQuery:(char*)query withLastCol:(char*)lastCol andFirstCol:(char*)firstCol;
- (BOOL)isNotDuplicateAlignment:(NSArray*)subsArray andChunkNum:(int)chunkNum;
- (NSArray*)positionInBWTwithPosInBWM:(NSArray*)posArray andFirstCol:(char*)firstColumn andLastCol:(char*)lastColumn;
- (int)charsBeforeChar:(char)c;
+ (int)whichChar:(char)c inContainer:(char*)container;
- (int)LFC:(int)r andChar:(char)c withLastCol:(char*)lastCol;
- (int)getIndexOfNth:(int)n OccurenceOfChar:(char)c inChar:(char*)container;
@end
