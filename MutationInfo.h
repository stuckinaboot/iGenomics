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
#define kCovStrInsFormat @"[%c=%@]"
#define kInsStrFormat @"{%s=%i}"
#define kMutationTotalFormat @"Total Mutations: %i\n"

#define kMutationStrMaxLen 80

@interface MutationInfo : NSObject {

}
@property (nonatomic) int pos, displayedPos, indexInSegmentNameArr;
@property (nonatomic) NSString* genomeName;
@property (nonatomic) NSArray *relevantInsertionsArr;
@property (nonatomic) char refChar;
@property (nonatomic) char* foundChars;
- (id)initWithPos:(int)p andRefChar:(char)refC
    andFoundChars:(char*)foundC andDisplayedPos:(int)dispP
    andInsertionsArr:(NSArray*)insArr heteroAllowance:(float)heteroAllowance;
- (void)freeUsedMemory;
+ (NSString*)mutationInfosOutputString:(NSArray*)mutationInfos;
+ (char*)createMutStrFromOriginalChar:(char)originalC
                        andFoundChars:(char*)fc pos:(int)pos relevantInsArr:(NSArray*)insertions;
+ (char*)createMutCovStrFromFoundChars:(char*)fc
                                andPos:(int)pos relevantInsArr:(NSArray*)insertions;
+ (BOOL)mutationInfoObjectsHaveSameContents:(MutationInfo*)info1 :(MutationInfo*)info2;
@end
