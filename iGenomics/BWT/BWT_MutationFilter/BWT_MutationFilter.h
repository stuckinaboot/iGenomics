//
//  BWT_MutationFilter.h
//  LabProject7
//
//  Created by Stuckinaboot Inc. on 9/15/12.
//
//

#import <Foundation/Foundation.h>
#import "BWT_Matcher.h"
#import "MutationInfo.h"

//Format- P: R: F: #A: #C: #G: #T:
//     Pos: Real: Found: # of A: # of C: # of G: # of T:

#define kOnlyPrintFoundGenome -111

extern char *foundGenome[kACGTLen+2]; //I--------GLOBAL-------I
extern int coverageArray[kMaxBytesForIndexer*kMaxMultipleToCountAt];//I--------GLOBAL-------I

@interface BWT_MutationFilter : NSObject {
    BWT_Matcher *matcher;

    char *refStr;
    
    char *acgt;
    
    int fileStrLen;
}
@property (nonatomic) int kHeteroAllowance;
- (void)setUpMutationFilterWithOriginalStr:(char*)originalSeq andMatcher:(BWT_Matcher*)myMatcher;

- (void)buildOccTableWithUnravStr:(char*)unravStr;
- (NSArray*)filterMutationsForDetails;
- (NSArray*)findMutationsWithOriginalSeq:(char*)seq;

+ (NSMutableArray*)filteredMutations:(NSArray*)arr forHeteroAllowance:(int)heteroAllowance;
@end
