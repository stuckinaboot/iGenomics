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
    seq = calloc(kMaxInsertionSeqLen, 1);
    count = 1;
}
@end
