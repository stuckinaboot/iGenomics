//
//  MutationInfo.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 6/23/13.
//
//

#import <Foundation/Foundation.h>
#import "BWT_MutationFilter.h"

#define kMutationFormat @"Pos: %i, %s | Cov:%s\n"
#define kMutationExportFormat @"Pos: %i, %s | Cov:%s, %@\n"
#define kCovStrFormat @" %c = %i,"
#define kMutationTotalFormat @"Total Mutations: %i\n"

@interface MutationInfo : NSObject
@property (nonatomic) int pos, displayedPos;
@property (nonatomic) NSString* genomeName;
@property (nonatomic) char refChar;
@property (nonatomic) char* foundChars;
- (id)initWithPos:(int)p andRefChar:(char)refC andFoundChars:(char*)foundC andDisplayedPos:(int)dispP;
+ (char*)createMutStrFromOriginalChar:(char)originalC andFoundChars:(char*)fc;
+ (char*)createMutCovStrFromFoundChars:(char*)fc andPos:(int)pos;
@end
