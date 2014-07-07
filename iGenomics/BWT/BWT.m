//
//  BWT.m
//  LabProject7
//
//  Created by Stuckinaboot Inc. on 9/15/12.
//
//

#import "BWT.h"

@implementation BWT

@synthesize bwtMutationFilter;
@synthesize readLen, refSeqLen, numOfReads, numOfReadsMatched;
@synthesize delegate;

- (void)setUpForRefFileContents:(NSString *)contents andFilePath:(NSString*)filePath {
    BWT_Maker *bwt_Maker = [[BWT_Maker alloc] init];
    
    if (![filePath isEqualToString:@""]) {//filePath is from dropbox
        DBFilesystem *dbFileSys = [DBFilesystem sharedFilesystem];
        DBPath *newPath = [[DBPath alloc] initWithString:[filePath stringByAppendingFormat:@".%@",kBWTFileExt]];
        DBFile *file = [dbFileSys openFile:newPath error:nil];
        
        if (file == nil) {
//        if ([[GlobalVars extFromFileName:filePath] caseInsensitiveCompare:kBWTFileExt] != NSOrderedSame) {
            
            refStrBWT = strdup([bwt_Maker createBWTFromResFileContents:[contents stringByReplacingOccurrencesOfString:kLineBreak withString:@""]]);
            originalStr = strdup([bwt_Maker getOriginalString]);
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            
            dispatch_async(queue, ^{
                NSMutableString *benchmarkPosStr = [[NSMutableString alloc] init];
                dgenomeLen = strlen(refStrBWT);
                for (int i = 0; i < dgenomeLen; i++) {
                    [benchmarkPosStr appendFormat:@"%i\n",benchmarkPositions[i]];
                }
                
                DBFilesystem *sys = [DBFilesystem sharedFilesystem];
                DBPath *newFilePath = [[DBPath alloc] initWithString:[NSString stringWithFormat:@"%@.%@",filePath,kBWTFileExt]];
                DBFile *file = [sys createFile:newFilePath error:nil];
                [file writeString:[NSString stringWithFormat:@"%s%@%@",refStrBWT,kBWTFileDividerBtwBWTandBenchmarkPosList,benchmarkPosStr] error:nil];
            });
            
        }
        else {
            bwt_MatcherSC = [[BWT_MatcherSC alloc] init];
            
            NSString *bwtFileStr = [file readString:nil];
            NSArray *bwtFileStrComponents = [bwtFileStr componentsSeparatedByString:kBWTFileDividerBtwBWTandBenchmarkPosList];
            refStrBWT = strdup((char*)[[bwtFileStrComponents objectAtIndex:0] UTF8String]);
            originalStr = strdup([contents UTF8String]);
            
            NSArray *benchmarkPosComponents = [[bwtFileStrComponents objectAtIndex:1] componentsSeparatedByString:kLineBreak];
            for (int i = 0; i < [benchmarkPosComponents count]; i++) {
                benchmarkPositions[i] = [[benchmarkPosComponents objectAtIndex:i] intValue];
            }
        }
    }
    else {//Local file
        refStrBWT = strdup([bwt_Maker createBWTFromResFileContents:contents]);
        originalStr = strdup([contents UTF8String]);
    }
    
    bwtMutationFilter = [[BWT_MutationFilter alloc] init];
    
    if (kDebugOn == 1)
        printf("\n%s",refStrBWT);
}

- (void)matchReedsFileContentsAndParametersArr:(NSArray *)arr {
    NSLog(@"matchReedsFileContentsAndParametersArr entered");
    
    numOfReadsMatched = 0;
    
    NSString *contents = [arr objectAtIndex:0];
    NSArray *parameters = [arr objectAtIndex:1];
    
    NSLog(@"About to build the BWT");
    
    bwt_Matcher = [[BWT_Matcher alloc] init];

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
    
    bwt_Matcher.matchType = [[parameters objectAtIndex:kParameterArrayMatchTypeIndex] intValue];
    maxSubs = [[parameters objectAtIndex:kParameterArrayEDIndex] intValue];
    bwt_Matcher.alignmentType = [[parameters objectAtIndex:kParameterArrayFoRevIndex] intValue];
    
    NSLog(@"About to set delegate");
    
    [bwt_Matcher setDelegate:self];
    
    NSLog(@"About to setUpReedsFileContents");
    [bwt_Matcher setUpReedsFileContents:contents refStrBWT:refStrBWT andMaxSubs:maxSubs];
    
    readLen = bwt_Matcher.readLen;
    refSeqLen = bwt_Matcher.refSeqLen;
    numOfReads = bwt_Matcher.numOfReads;
    
    [bwt_Matcher matchReeds];
    
    insertions = bwt_Matcher.insertionsArray;

    bwtMutationFilter.kHeteroAllowance = [[parameters objectAtIndex:kParameterArrayMutationCoverageIndex] intValue]-1;//-1 because kHeteroAllowance is for one lower than what is allowed to be considered a mutation.
    
    [bwtMutationFilter setUpMutationFilterWithOriginalStr:originalStr andMatcher:bwt_Matcher];
    
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
- (void)readProccesed:(NSString *)readData andMatchedAtLeastOnce:(BOOL)didMatch {
    if (didMatch)
        numOfReadsMatched++;
    [delegate readProccesed:readData];
}
@end
