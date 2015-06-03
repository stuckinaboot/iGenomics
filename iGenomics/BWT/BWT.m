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

- (void)setUpForRefFileContents:(NSString *)contents andFilePath:(NSString*)filePath {
    BWT_Maker *bwt_Maker = [[BWT_Maker alloc] init];
    [delegate bwtLoadedWithLoadingText:kBWTCreatingTxt];
    if (filePath != nil && ![filePath isEqualToString:@""]) {//filePath is from dropbox
        DBFilesystem *dbFileSys = [DBFilesystem sharedFilesystem];
        DBPath *newPath = [[DBPath alloc] initWithString:[filePath stringByAppendingFormat:@".%@",kBWTFileExt]];
        DBFile *file = [dbFileSys openFile:newPath error:nil];
        
        if (file == nil) {
            refStrBWT = strdup([bwt_Maker createBWTFromResFileContents:[contents stringByReplacingOccurrencesOfString:kLineBreak withString:@""]]);
            originalStr = [bwt_Maker getOriginalString];
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            
            dispatch_async(queue, ^{
                [delegate bwtLoadedWithLoadingText:kBWTSavingToDropboxTxt];
                
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
            [delegate bwtLoadedWithLoadingText:kBWTLoadingFromDropboxTxt];
            
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
    
    bwt_Matcher.matchType = [[parameters objectAtIndex:kParameterArrayMatchTypeIndex] intValue];
    maxErrorRate = [[parameters objectAtIndex:kParameterArrayERIndex] floatValue];
    bwt_Matcher.alignmentType = [[parameters objectAtIndex:kParameterArrayFoRevIndex] intValue];
    
    NSString *genomeFileSegmentNames = [parameters objectAtIndex:kParameterArrayRefFileSegmentNamesIndex];
    
    NSRange genomeFileNameRange = NSMakeRange(0, [genomeFileSegmentNames rangeOfString:kRefFileInternalDivider].location);
    genomeFileSegmentNames = [genomeFileSegmentNames substringFromIndex:genomeFileNameRange.length+kRefFileInternalDivider.length];
    
    NSMutableArray *segArr = (NSMutableArray*)[genomeFileSegmentNames componentsSeparatedByString:kRefFileInternalDivider];
    
    separateGenomeNames = [[NSMutableArray alloc] init];
    separateGenomeLens = [[NSMutableArray alloc] init];
    cumulativeSeparateGenomeLens = [[NSMutableArray alloc] init];
    
    for (int i = 0, x = 0; i < [segArr count]; i += 2, x++) {
        NSString *seg = [segArr objectAtIndex:i];
        NSRange r = [seg rangeOfString:kSeparateGenomeNamesSubstringToIndexStr];
        if (r.location != NSNotFound)
            [separateGenomeNames addObject:[seg substringToIndex:r.location]];
        else
            [separateGenomeNames addObject:seg];
        [separateGenomeLens addObject:[NSNumber numberWithInt:[[segArr objectAtIndex:i+1] intValue]]];
        if (i > 0)
            [cumulativeSeparateGenomeLens addObject:[NSNumber numberWithInt:[[separateGenomeLens objectAtIndex:x] intValue]+[[cumulativeSeparateGenomeLens objectAtIndex:x-1] intValue]]];
        else
            [cumulativeSeparateGenomeLens addObject:[NSNumber numberWithInt:[[separateGenomeLens objectAtIndex:x] intValue]]];
    }
    
    bwt_Matcher.cumulativeSeparateGenomeLens = [[NSMutableArray alloc] initWithArray:cumulativeSeparateGenomeLens];
    
    [bwt_Matcher setDelegate:self];
    
    NSLog(@"About to setUpReedsFileContents");
    [bwt_Matcher setUpReedsFileContents:contents refStrBWT:refStrBWT andMaxErrorRate:maxErrorRate];
    
    readLen = bwt_Matcher.readLen;
    refSeqLen = bwt_Matcher.refSeqLen;
    numOfReads = bwt_Matcher.numOfReads;
    
    BOOL seedingIsOn = [[parameters objectAtIndex:kParameterArraySeedingOnIndex] boolValue];
    
    [bwt_Matcher matchReedsWithSeedingState:seedingIsOn];
    
    insertions = bwt_Matcher.insertionsArray;

    bwtMutationFilter.kHeteroAllowance = [[parameters objectAtIndex:kParameterArrayMutationCoverageIndex] intValue];
    
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
