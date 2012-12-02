//
//  BWT_MutationFilter.h
//  LabProject7
//
//  Created by Stuckinaboot Inc. on 9/15/12.
//
//

#import <Foundation/Foundation.h>
#import "BWT_Matcher.h"

//Format- P: R: F: #A: #C: #G: #T:
//     Pos: Real: Found: # of A: # of C: # of G: # of T:

#define kOnlyPrintFoundGenome 0

@interface BWT_MutationFilter : NSObject {
    BWT_Matcher *matcher;
    
    int posOccArray[kACGTLen+2][kMaxBytesForIndexer*kMaxMultipleToCountAt];//+2 because of Del/In
    int coverageArray[kMaxBytesForIndexer*kMaxMultipleToCountAt];
    
    char *foundGenome[kACGTLen+2];
    char *refStr;
    
    char *acgt;
    
    int fileStrLen;
}
- (void)setUpMutationFilterWithOriginalStr:(char*)originalSeq andMatcher:(BWT_Matcher*)myMatcher;
//- (void)setUpMutationFilterWithPosOccArray:(NSString*)poa andOriginalStr:(char*)originalSeq;
- (void)setUpPosOccArray;

- (void)buildOccTableWithUnravStr:(char*)unravStr;
- (NSArray*)filterMutationsForDetails;
- (NSArray*)findMutationsWithOriginalSeq:(char*)seq;
@end
