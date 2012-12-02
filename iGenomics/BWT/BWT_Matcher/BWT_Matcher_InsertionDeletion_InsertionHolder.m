//
//  BWT_Matcher_InsertionDeletion_InsertionHolder.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 11/11/12.
//
//

#import "BWT_Matcher_InsertionDeletion_InsertionHolder.h"

@implementation BWT_Matcher_InsertionDeletion_InsertionHolder

@synthesize position, c;

- (void)setUp {
    c = calloc(kMaxInsertionSeqLen, 1);
    currPos = 0;
}
- (void)appendChar:(char)ch {
    c[currPos] = ch;
    currPos++;
}
@end
