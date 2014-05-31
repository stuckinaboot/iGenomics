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
@synthesize readLen, refSeqLen, numOfReads;
@synthesize delegate;

- (void)setUpForRefFileContents:(NSString *)contents {
    BWT_Maker *bwt_Maker = [[BWT_Maker alloc] init];
    bwtString = strdup([bwt_Maker createBWTFromResFileContents:contents]);
    originalString = strdup([bwt_Maker getOriginalString]);
    
    bwtMutationFilter = [[BWT_MutationFilter alloc] init];
    
    if (kDebugOn == 1)
        printf("\n%s",bwtString);
}

- (void)matchReedsFileContentsAndParametersArr:(NSArray *)arr {
    NSLog(@"matchReedsFileContentsAndParametersArr entered");
    
    NSString *contents = [arr objectAtIndex:0];
    NSArray *parameters = [arr objectAtIndex:1];
    
    NSLog(@"About to build the BWT");
    
    bwt_Matcher = [[BWT_Matcher alloc] initWithOriginalStr:originalString];

    /*
     SET OF PARAMETERS:
     
     0-Exact match (0), substitution (1), subs + indels (2) | TYPE: int (exact,sub,subs+indels), int (ED)
     +Max ED
     
     2-Forward alignment(0), forward and reverse alignments (1) | TYPE: int
     
     3-Mutation support (num of disagreements before a position is reported as a mutation): (inputted by user) | TYPE: int
     
     4-Trimming (if selected, chop off last x (user is allowed to chose num) bases) | TYPE: int
     
     5-Seed (chunk) length: automatic, manual (user inputs seed length)  | TYPE: int
     +(Advanced feature)       -------NOT IMPLEMENTED YET
     
     */
    NSLog(@"About to load parameters");
    
    bwt_Matcher.matchType = [[parameters objectAtIndex:0] intValue];
    maxSubs = [[parameters objectAtIndex:1] intValue];
    bwt_Matcher.alignmentType = [[parameters objectAtIndex:2] intValue];
    
    NSLog(@"About to set delegate");
    
    [bwt_Matcher setDelegate:self];
    
    NSLog(@"About to setUpReedsFileContents");
    [bwt_Matcher setUpReedsFileContents:contents refStrBWT:bwtString andMaxSubs:maxSubs];
    
    readLen = bwt_Matcher.readLen;
    refSeqLen = bwt_Matcher.refSeqLen;
    numOfReads = bwt_Matcher.numOfReads;
    
    [bwt_Matcher matchReeds];
    
    insertions = bwt_Matcher.insertionsArray;

    bwtMutationFilter.kHeteroAllowance = [[parameters objectAtIndex:3] intValue]-1;//-1 because kHeteroAllowance is for one lower than what is allowed to be considered a mutation.
    
    [bwtMutationFilter setUpMutationFilterWithOriginalStr:originalString andMatcher:bwt_Matcher];
    
}

- (NSArray*)simpleSearchForQuery:(char*)query {
    bwt_MatcherSC = [[BWT_MatcherSC alloc] init];
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:[bwt_MatcherSC exactMatchForQuery:query andIsReverse:NO andForOnlyPos:YES]];

    return arr;
}

- (NSMutableArray*)getInsertionsArray {
    return insertions;
}

//BWT_MatcherDelegate
- (void)readProccesed:(NSString *)readData {
    [delegate readProccesed:readData];
}
@end
