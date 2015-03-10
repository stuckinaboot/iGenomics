//
//  BWT_MutationFilter.h
//  LabProject7
//
//  Created by Stuckinaboot Inc. on 9/15/12.
//
//

#import <Foundation/Foundation.h>
#import "BWT_Matcher.h"
#import "GlobalVars.h"

//Format- P: R: F: #A: #C: #G: #T:
//     Pos: Real: Found: # of A: # of C: # of G: # of T:

#define kOnlyPrintFoundGenome -111
#define kFoundGenomeDefaultChar ' '

#define kMatchTypeHomozygousMutationNormal 'h'
#define kMatchTypeHomozygousMutationImportant 'H'
#define kMatchTypeHeterozygousMutationNormal 't'
#define kMatchTypeHeterozygousMutationImportant 'T'
#define kMatchTypeHomozygousNoMutation 'n'
#define kMatchTypeNoMutationImportant 'j'
#define kMatchTypeHeterozygousNoMutation 'd'
#define kMatchTypeNoAlignment 'x'

#define kFoundGenomeArrSize 7 //A, C, G, T, -, +, status code for hetero/homo/other

extern char *foundGenome[kFoundGenomeArrSize]; //I--------GLOBAL-------I
extern int coverageArray[kMaxBytesForIndexer*kMaxMultipleToCountAt];//I--------GLOBAL-------I

#define kImptMutsStrSegmentNameIndex 0
#define kImptMutsStrPositionIndex 1
#define kImptMutsStrRefCharIndex 2
#define kImptMutsStrFoundCharIndex 3
#define kImptMutsStrDescriptionIndex 4
#define kImptMutsStrComponentSeparator @"    "

@class ImportantMutationInfo;

@interface BWT_MutationFilter : NSObject {
    BWT_Matcher *matcher;

    char *refStr;
    char *acgt;
    
    int fileStrLen;
}
@property (nonatomic) int kHeteroAllowance;
- (void)setUpMutationFilterWithOriginalStr:(char*)originalSeq andMatcher:(BWT_Matcher*)myMatcher;
- (void)resetFoundGenome;

- (void)buildOccTableWithUnravStr:(char*)unravStr;
- (NSArray*)filterMutationsForDetails;
- (NSArray*)findMutationsWithOriginalSeq:(char*)seq;

+ (NSMutableArray*)filteredMutations:(NSArray*)arr forHeteroAllowance:(int)heteroAllowance;
+ (NSMutableArray*)compareFoundMutationsArr:(NSArray *)arr toImptMutationsString:(NSString *)imptMutsStr andCumulativeLenArr:(NSMutableArray*)lenArr andSegmentNameArr:(NSMutableArray*)nameArr;
@end
