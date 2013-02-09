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

- (void)setUpForRefFile:(NSString*)fileName fileExt:(NSString*)fileExt {
    BWT_Maker *bwt_Maker = [[BWT_Maker alloc] init];
    bwtString = strdup([bwt_Maker createBWTFromResFile:fileName andFileExt:fileExt]);
    originalString = strdup([bwt_Maker getOriginalString]);
    
    bwtMutationFilter = [[BWT_MutationFilter alloc] init];
    
    if (kDebugOn == 1)
        printf("\n%s",bwtString);
}

- (void)matchReedsFile:(NSString*)fileName fileExt:(NSString*)fileExt withParameters:(NSArray *)parameters {
//    maxSubs = subs;
     bwt_Matcher = [[BWT_Matcher alloc] init];
    
    /*
     SET OF PARAMETERS:
     
     0-Exact match (0), substitution (1), subs + indels (2) | TYPE: int (exact,sub,subs+indels), int (ED)
     +Max ED
     
     1-Forward alignment(0), forward and reverse alignments (1) | TYPE: int
     
     2-Mutation support (num of disagreements before a position is reported as a mutation): (inputted by user) | TYPE: int
     
     3-Trimming (if selected, chop off last x (user is allowed to chose num) bases) | TYPE: int
     
     4-Seed (chunk) length: automatic, manual (user inputs seed length)  | TYPE: int
     +(Advanced feature)       -------NOT IMPLEMENTED YET
     
     */
    bwt_Matcher.matchType = [[parameters objectAtIndex:0] intValue];
    maxSubs = [[parameters objectAtIndex:1] intValue];
    bwt_Matcher.alignmentType = [[parameters objectAtIndex:2] intValue];
    
    [bwt_Matcher setUpReedsFile:fileName fileExt:fileExt refStrBWT:bwtString andMaxSubs:maxSubs];
    
    readLen = bwt_Matcher.readLen;
    refSeqLen = bwt_Matcher.refSeqLen;
    numOfReads = bwt_Matcher.numOfReads;
    
    insertions = bwt_Matcher.insertionsArray;
    /*TEMPORARYAYYARYRYAYRYYARYYR ----------- WILL EVENTUALLY BE DONE IN SetUpReedsFile*/
//    NSArray *reads = [[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:fileExt] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
//    for (int i = 0; i<reads.count;i++) {
//        [bwt_Matcher insertionDeletionMatchesForQuery:(char*)[[reads objectAtIndex:i] UTF8String] andLastCol:bwtString];
//    }
    
//    posOccArray = [bwt_Matcher getPosOccArray];
    bwtMutationFilter.kHeteroAllowance = [[parameters objectAtIndex:3] intValue]-1;//-1 because kHeteroAllowance is for one lower than what is allowed to be considered a mutation.
    
    [bwtMutationFilter setUpMutationFilterWithOriginalStr:originalString andMatcher:bwt_Matcher];
    
}

- (NSArray*)simpleSearchForQuery:(char*)query {
    return [bwt_Matcher exactMatchForQuery:query withLastCol:bwtString andFirstCol:[bwt_Matcher getSortedSeq]];
}

- (NSMutableArray*)getInsertionsArray {
    return insertions;
}

- (void)setUpMutationFilter {
//    [bwtMutationFilter setUpMutationFilterWithOriginalStr:originalString];
}
@end
