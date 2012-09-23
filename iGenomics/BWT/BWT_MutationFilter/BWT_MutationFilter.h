//
//  BWT_MutationFilter.h
//  LabProject7
//
//  Created by Stuckinaboot Inc. on 9/15/12.
//
//

#import <Foundation/Foundation.h>
#import "BWT_Matcher.h"

@interface BWT_MutationFilter : NSObject {
    int posOccArray[kACGTLen][kBytesForIndexer*kMultipleToCountAt];
    int coverageArray[kBytesForIndexer*kMultipleToCountAt];
    
    char *foundGenome[kACGTLen];
    char *refStr;
    
    char *acgt;
    
    int fileStrLen;
}

- (void)setUpMutationFilterWithPosOccArray:(NSString*)poa andOriginalStr:(char*)originalSeq;
- (void)setUpPosOccArray:(NSString*)poa;

- (void)buildOccTableWithUnravStr:(char*)unravStr;
- (NSArray*)filterMutationsForDetails;
- (NSArray*)findMutationsWithOriginalSeq:(char*)seq;
@end
