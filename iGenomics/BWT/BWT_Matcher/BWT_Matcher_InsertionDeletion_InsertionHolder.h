//
//  BWT_Matcher_InsertionDeletion_InsertionHolder.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 11/11/12.
//
//

#import <Foundation/Foundation.h>

#define kMaxInsertionSeqLen 5

@interface BWT_Matcher_InsertionDeletion_InsertionHolder : NSObject //Used to keep track of insertions
{
    int currPos;//in c
}
@property (nonatomic) int position;
@property (nonatomic) char *c;
- (void)setUp;
- (void)appendChar:(char)ch;
@end
