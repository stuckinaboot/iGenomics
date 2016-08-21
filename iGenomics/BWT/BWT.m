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
@synthesize separateGenomeLens, separateGenomeNames, cumulativeSeparateGenomeLens;

- (void)setUpForRefFile:(APFile*)myRefFile {
    [self freeUsedMemory];
    
    BWT_Maker *bwt_Maker = [[BWT_Maker alloc] init];
    [delegate bwtLoadedWithLoadingText:kBWTCreatingTxt];
    if (myRefFile.fileType == APFileTypeDropbox) {//filePath is from dropbox
        DBFilesystem *dbFileSys = [DBFilesystem sharedFilesystem];
        DBPath *newPath = [[DBPath alloc] initWithString:[myRefFile.name stringByAppendingFormat:@".%@",kBWTFileExt]];
        DBFile *file = [dbFileSys openFile:newPath error:nil];
        
        if (file == nil) {
            refStrBWT = [bwt_Maker createBWTFromResFileContents:[myRefFile.contents stringByReplacingOccurrencesOfString:kLineBreak withString:@""]];
            originalStr = strdup([myRefFile.contents UTF8String]);
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            
            dispatch_async(queue, ^{
                [delegate bwtLoadedWithLoadingText:kBWTSavingToDropboxTxt];
                
                NSMutableString *benchmarkPosStr = [[NSMutableString alloc] init];
                dgenomeLen = strlen(refStrBWT);
                for (int i = 0; i < dgenomeLen; i++) {
                    [benchmarkPosStr appendFormat:@"%i\n",benchmarkPositions[i]];
                }
                
                DBFilesystem *sys = [DBFilesystem sharedFilesystem];
                DBPath *newFilePath = [[DBPath alloc] initWithString:[NSString stringWithFormat:@"%@.%@",myRefFile.name,kBWTFileExt]];
                DBFile *file = [sys createFile:newFilePath error:nil];
                [file writeString:[NSString stringWithFormat:@"%s%@%@",refStrBWT,kBWTFileDividerBtwBWTandBenchmarkPosList,benchmarkPosStr] error:nil];
            });
            
        }
        else {
            [delegate bwtLoadedWithLoadingText:kBWTLoadingFromDropboxTxt];
            
            bwt_MatcherSC = [[BWT_MatcherSC alloc] init];
            
            NSString *bwtFileStr = [file readString:nil];
            NSArray *bwtFileStrComponents = [bwtFileStr componentsSeparatedByString:kBWTFileDividerBtwBWTandBenchmarkPosList];
            refStrBWT = strdup((char*)[[bwtFileStrComponents objectAtIndex:0] UTF8String]);
            originalStr = strdup([myRefFile.contents UTF8String]);
            
            NSArray *benchmarkPosComponents = [[bwtFileStrComponents objectAtIndex:1] componentsSeparatedByString:kLineBreak];
            for (int i = 0; i < [benchmarkPosComponents count]; i++) {
                benchmarkPositions[i] = [[benchmarkPosComponents objectAtIndex:i] intValue];
            }
        }
    }
    else {//Local file
        refStrBWT = [bwt_Maker createBWTFromResFileContents:myRefFile.contents];
        originalStr = strdup([myRefFile.contents UTF8String]);
    }
    
    bwtMutationFilter = [[BWT_MutationFilter alloc] init];
    
    if (kDebugOn == 1)
        printf("\n%s",refStrBWT);
}

- (void)freeUsedMemory {
    free(originalStr);
    free(firstCol);
    free(refStrBWT);
}

- (float)matchReadsFile:(APFile *)readsFile withParameters:(NSMutableDictionary *)parameters {
    NSLog(@"matchReedsFileContentsAndParametersArr entered");
    
    numOfReadsMatched = 0;
    
    NSLog(@"About to build the BWT");
    
    if (bwt_Matcher)
        bwt_Matcher = nil;
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
    
    bwt_Matcher.matchType = [parameters[kParameterArrayMatchTypeKey] intValue];
    maxErrorRate = [parameters[kParameterArrayERKey] floatValue];
    bwt_Matcher.alignmentType = [parameters[kParameterArrayFoRevKey] intValue];
    
    separateGenomeNames = parameters[kParameterArraySegmentNamesKey];
    separateGenomeLens = parameters[kParameterArraySegmentLensKey];
    
    cumulativeSeparateGenomeLens = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [separateGenomeLens count]; i++) {
        int len = [[separateGenomeLens objectAtIndex:i] intValue];
        if (i > 0)
            [cumulativeSeparateGenomeLens addObject:[NSNumber numberWithInt:[[cumulativeSeparateGenomeLens objectAtIndex:i-1] intValue]+len]];
        else
            [cumulativeSeparateGenomeLens addObject:[NSNumber numberWithInt:len]];
    }
    bwt_Matcher.cumulativeSeparateGenomeLens = [[NSMutableArray alloc] initWithArray:cumulativeSeparateGenomeLens];
    
    [bwt_Matcher setDelegate:self];
    
    NSLog(@"About to setUpReedsFileContents");
    [bwt_Matcher setUpReedsFileContents:readsFile.contents refStrBWT:refStrBWT andMaxErrorRate:maxErrorRate];
    
    readLen = bwt_Matcher.readLen;
    refSeqLen = bwt_Matcher.refSeqLen;
    numOfReads = bwt_Matcher.numOfReads;
    
    BOOL seedingIsOn = [parameters[kParameterArraySeedingOnKey] boolValue];
    
    [bwt_Matcher matchReedsWithSeedingState:seedingIsOn];
    
    insertions = bwt_Matcher.insertionsArray;

    bwtMutationFilter.kHeteroAllowance = [parameters[kParameterArrayMutationCoverageKey] intValue];
    
    [bwtMutationFilter setUpMutationFilterWithOriginalStr:originalStr andMatcher:bwt_Matcher];
    return [bwt_Matcher getTotalAlignmentRuntime];
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

- (void)readAligned {
    [delegate readAligned];
}
@end
