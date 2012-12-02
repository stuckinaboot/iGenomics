//
//  BWT.m
//  LabProject7
//
//  Created by Stuckinaboot Inc. on 9/15/12.
//
//

#import "BWT.h"

@implementation BWT

@synthesize bwtMutationFilter, originalString;

- (void)setUpForRefFile:(NSString*)fileName fileExt:(NSString*)fileExt {
    BWT_Maker *bwt_Maker = [[BWT_Maker alloc] init];
    bwtString = strdup([bwt_Maker createBWTFromResFile:fileName andFileExt:fileExt]);
    originalString = strdup([bwt_Maker getOriginalString]);
    
    bwtMutationFilter = [[BWT_MutationFilter alloc] init];
    
    if (kDebugOn == 1)
        printf("\n%s",bwtString);
}

- (void)matchReedsFile:(NSString*)fileName fileExt:(NSString*)fileExt withNumOfSubs:(int)subs {
    maxSubs = subs;
    BWT_Matcher *bwt_Matcher = [[BWT_Matcher alloc] init];
    [bwt_Matcher setUpReedsFile:fileName fileExt:fileExt refStrBWT:bwtString andMaxSubs:maxSubs];
    
    /*TEMPORARYAYYARYRYAYRYYARYYR ----------- WILL EVENTUALLY BE DONE IN SetUpReedsFile*/
//    NSArray *reads = [[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:fileExt] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
//    for (int i = 0; i<reads.count;i++) {
//        [bwt_Matcher insertionDeletionMatchesForQuery:(char*)[[reads objectAtIndex:i] UTF8String] andLastCol:bwtString];
//    }
    
//    posOccArray = [bwt_Matcher getPosOccArray];
    [bwtMutationFilter setUpMutationFilterWithOriginalStr:originalString andMatcher:bwt_Matcher];
    
}

- (void)setUpMutationFilter {
//    [bwtMutationFilter setUpMutationFilterWithOriginalStr:originalString];
}
@end
