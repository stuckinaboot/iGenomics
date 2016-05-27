//
//  MutationInfo.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 6/23/13.
//
//

#import <Foundation/Foundation.h>
#import "BWT_MutationFilter.h"

#define kMutationFormat @"Pos: %i, %s | Cov: %s\n"
#define kMutationExportFormat @"%i\t%s\t%s\t%@\n"
#define kCovStrFormat @"[%c=%i]"
#define kMutationTotalFormat @"Total Mutations: %i\n"

@interface MutationInfo : NSObject {
    
}
@property (nonatomic) int pos, displayedPos, indexInSegmentNameArr;
@property (nonatomic) NSString* genomeName;
@property (nonatomic) char refChar;
@property (nonatomic) char* foundChars;
- (id)initWithPos:(int)p andRefChar:(char)refC
    andFoundChars:(char*)foundC andDisplayedPos:(int)dispP;
+ (char*)createMutStrFromOriginalChar:(char)originalC andFoundChars:(char*)fc;
+ (char*)createMutCovStrFromFoundChars:(char*)fc andPos:(int)pos;
+ (BOOL)mutationInfoObjectsHaveSameContents:(MutationInfo*)info1 :(MutationInfo*)info2;
@end
