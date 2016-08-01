//
//  BWT_Matcher_InsertionDeletion_InsertionHolder.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 11/11/12.
//
//

#import "BWT_Matcher_InsertionDeletion_InsertionHolder.h"

@implementation BWT_Matcher_InsertionDeletion_InsertionHolder

@synthesize seq, pos, count;

- (void)setUp {
    seq = malloc(kMaxInsertionSeqLen);
    count = 1;
}

- (void)freeUsedMemory {
    free(seq);
}

@end
