//
//  BWT_Matcher_InsertionDeletion_InsertionHolder.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 11/11/12.
//
//

#import <Foundation/Foundation.h>

#define kMaxInsertionSeqLen 20

@interface BWT_Matcher_InsertionDeletion_InsertionHolder : NSObject //Used to keep track of insertions
{
    char* seq;
    int count;
    int pos;
}
@property (nonatomic) int count;
@property (nonatomic) char *seq;
@property (nonatomic) int pos;
- (void)setUp;
- (void)freeUsedMemory;
@end
