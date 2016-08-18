//
//  BWT_Matcher.m
//  LabProject7
//
//  Created by Stuckinaboot Inc. on 9/15/12.
//
//

#import "BWT_Matcher.h"

int posOccArray[kACGTwithInDelsLen][kMaxBytesForIndexer*kMaxMultipleToCountAt];//+2 because of deletions +1(-) and insertions +2(+)

@implementation BWT_Matcher

@synthesize /*kMultipleToCountAt,*/ matchType, alignmentType, insertionsArray, cumulativeSeparateGenomeLens;
@synthesize readLen, refSeqLen, numOfReads;
@synthesize delegate;

- (id)init {
    self = [super init];
    
    exactMatcher = [[BWT_MatcherSC alloc] init];
    return self;
}

- (void)setUpReedsFileContents:(NSString*)contents refStrBWT:(char*)bwt andMaxErrorRate:(double)maxER {
    
    [self freeUsedMemory];
    
    NSLog(@"==> setUpReedsFileContents:(NSString*)contents refStrBWT:(char*)bwt andMaxSubs:(int)subs entered");
    
    NSMutableArray *preReadsArray = [[NSMutableArray alloc] initWithArray:[contents componentsSeparatedByString:kReedsArraySeperationStr]];
    
    reedsArray = [[NSMutableArray alloc] init];
    
    readAlignmentsArr = [[NSMutableArray alloc] init];
    
    NSLog(@"About to form reedsArray");
    
    if ([preReadsArray count] % 2 == 0) {//Means is possible, means is not a txt file
        for (int i = 0; i<[preReadsArray count]; i+= 2) {
            Read *read = [[Read alloc] initWithSeq:(char*)[[preReadsArray objectAtIndex:i+1] UTF8String] andName:(char*)[[preReadsArray objectAtIndex:i] UTF8String]];
            [reedsArray addObject:read];
        }
    }
    else
        for (int i = 0; i < [preReadsArray count]; i++) {
            NSString *n = [NSString stringWithFormat:@"%i",i];//More efficient way to do this?
            Read *read = [[Read alloc] initWithSeq:(char*)[[preReadsArray objectAtIndex:i] UTF8String] andName:(char*)[n UTF8String]];
            [reedsArray addObject:read];
        }
    
    [preReadsArray removeAllObjects];
    preReadsArray = nil;
    
    NSLog(@"About to set basic variables");
    
    numOfReads = [reedsArray count];
    
    Read *firstRead = [reedsArray objectAtIndex:0];
    readLen = strlen(firstRead.sequence);
    
    refStrBWT = bwt;
    
    maxErrorRate = maxER;
    readNum = 0;
    
    dgenomeLen = strlen(refStrBWT);
    refSeqLen = dgenomeLen;
    
//    [self setUpNumberOfOccurencesArray];
    NSLog(@"About to call setUpNumberOfOccurencesArrayFast");
    
    self.insertionsArray = [[NSMutableArray alloc] init];
    insertionsDict = [[NSMutableDictionary alloc] init];
    
    NSLog(@"About to create firstCol");
    
    [self setUpNumberOfOccurencesArrayFast];
    
    firstCol = malloc(dgenomeLen+1);
    
    firstCol[0] = '$';
    
    int pos = 1;
    for (int x = 0; x<kACGTLen; x++) {
        for (int i = 0; i<acgtTotalOccs[x]; i++) {
            firstCol[pos] = acgt[x];
            pos++;
        }
    }
    
    firstCol[dgenomeLen] = '\0';
    
    for (int i = 0; i<kACGTwithInDelsLen; i++) {
        for (int x = 0; x<dgenomeLen; x++)
            posOccArray[i][x] = 0;
    }
    
    /*
    if (kDebugPrintInsertions>0) {
        printf("\nINSERTIONS:");
        for (int i = 0; i<[insertionsArray count]; i++) {
            BWT_Matcher_InsertionDeletion_InsertionHolder *h = [self.insertionsArray objectAtIndex:i];
            printf("\nPos: %i, Count: %i, Seq: %s",h.pos,h.count,h.seq);
        }
    }*/
    [self createOriginalStrWithDividers];
}

- (void)matchReedsWithSeedingState:(BOOL)seedingState {
    
    NSLog(@"Match Reeds Entered");
    
    if (!matchingTimer)
        matchingTimer = [[APTimer alloc] init];
    [matchingTimer start];

    if (kDebugOn == 2)
        printf("%s\n",originalStr);
    
    NSLog(@"About to enter match reads loop");
    
    totalAlignmentRuntime = 0;

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
//    ED_Info *bestMatchesVals[[reedsArray count]];
    ED_Info *__strong*bestMatches = (ED_Info*__strong*)calloc([reedsArray count], sizeof([ED_Info class]));
    int actualDGenomeLen = dgenomeLen;
    dgenomeLen = (int)strlen(originalStrWithDividers);
    
    int reedsCount = [reedsArray count];
    int stride = reedsCount / kBWT_MatcherReadAlignerMultiThreadNumOfThreads;
    
    dispatch_queue_t _q = dispatch_queue_create("dsfasd", DISPATCH_QUEUE_SERIAL);
    if (stride > 0) {
        dispatch_apply(reedsCount / stride, queue, ^(size_t i) {
            int j = (int)(i * stride);
            int endj = j + stride;
            while (j < endj) {
                Read *reed = reedsArray[j];

                int localReadLen = (int)strlen(reed.sequence);
                
                int maxNumOfSubs = maxErrorRate * localReadLen;
                ED_Info* a = [self getBestMatchForQuery:reed.sequence withLastCol:refStrBWT andFirstCol:firstCol andNumOfSubs:maxNumOfSubs andReadNum:readNum andShouldSeed:seedingState forReadLen:localReadLen];
                if (a != NULL) {
                    a.readName = reed.name;
                }
                bestMatches[j] = a;
                j++;
                dispatch_async(_q, ^{
                    [delegate readAligned];
                });
            }
        });
    }
    for (int i = (stride > 0) ? reedsCount - (reedsCount % stride) : 0; i < reedsCount; i++) {
        Read *reed = reedsArray[i];
        
        int localReadLen = (int)strlen(reed.sequence);
        int maxNumOfSubs = maxErrorRate * localReadLen;
        ED_Info* a = [self getBestMatchForQuery:reed.sequence withLastCol:refStrBWT andFirstCol:firstCol andNumOfSubs:maxNumOfSubs andReadNum:readNum andShouldSeed:seedingState forReadLen:localReadLen];
        if (a != NULL) {
            a.readName = reed.name;
        }
        bestMatches[i] = a;
        dispatch_async(_q, ^{
            [delegate readAligned];
        });
    }
    
    dgenomeLen = actualDGenomeLen;

    for (int i = 0; i < [reedsArray count]; i++) {
        ED_Info *a = bestMatches[i];
        int localReadLen = (int)strlen(((Read*)reedsArray[i]).sequence);
        
        int maxNumOfSubs = maxErrorRate * localReadLen;
        //        int maxNumOfSubs = maxErrorRate * readLen;
        if (a != NULL) {
            if (!a.alreadyHasPosAdjusted && a.distance > 0)//Exact matches are never unjusted
                a = [BWT_MatcherSC infoByAdjustingForSegmentDividerLettersForInfo:a cumSepSegLens:cumulativeSeparateGenomeLens];
            if (a != NULL) {
                int aGappedALen = (int)strlen(a.gappedA);
                maxNumOfSubs = maxErrorRate * aGappedALen;
                if (a.distance <= maxNumOfSubs) {
                    [self updatePosOccsArrayWithRange:NSMakeRange(a.position, aGappedALen) andED_Info:a relativeReadNum:i];
                }
            }
        }
        if (a == NULL) {
            //            dispatch_queue_t _q = dispatch_queue_create("apples", DISPATCH_QUEUE_SERIAL);
            dispatch_async(_q, ^{
                [delegate readProccesed:@"" andMatchedAtLeastOnce:NO];
            });
        }
    }
    
//    //Shift insertions array elements so that they are all in front
//    NSMutableArray *newInsertionsArray = [[NSMutableArray alloc] init];
//    for (int i = 0; i < [insertionsArray count]; i++) {
//        BWT_Matcher_InsertionDeletion_InsertionHolder *holder = [insertionsArray objectAtIndex:i];
//        if (![holder isKindOfClass:[NSNull class]]) {
//            [newInsertionsArray addObject:holder];
//            [insertionsArray removeObjectAtIndex:i];
//            i--;
//        }
//    }
//    insertionsArray = newInsertionsArray;
    for (int i = 0; i < reedsCount; i++) {
        bestMatches[i] = NULL;
    }
    free(bestMatches);
    
    self.insertionsArray = [NSMutableArray arrayWithArray:[insertionsDict allValues]];
    [matchingTimer stopAndLog];
    totalAlignmentRuntime = [matchingTimer getTotalRecordedTime];
}

- (ED_Info*)getBestMatchForQuery:(char*)query withLastCol:(char*)lastCol andFirstCol:(char*)firstCol andNumOfSubs:(int)amtOfSubs andReadNum:(int)readNum andShouldSeed:(BOOL)shouldSeed forReadLen:(int)actualReadLen {
    
    NSArray *arr;
    
    int forwardMatches = 0;//EX. ACA

    int step = (amtOfSubs > kReadLoopMaxSmallEditDist) ? ceilf(amtOfSubs * kReadLoopLargeEditDistStepFactor) : 1;
    
    int initialNumOfSubs = (shouldSeed) ? 0 : amtOfSubs;

    int lastColLen = (int)strlen(lastCol);
    
    BWT_Matcher_Approxi *approxiMatcher = [[BWT_Matcher_Approxi alloc] init];
    for (int subs = initialNumOfSubs; subs < amtOfSubs+1; subs += step) {
        if (subs == 0 || matchType == MatchTypeExactOnly) {
            int temp = dgenomeLen;
            dgenomeLen = lastColLen;
            arr = [exactMatcher exactMatchForQuery:query andIsReverse:NO andForOnlyPos:NO];
            dgenomeLen = temp;
        }
        else {
            if (matchType == MatchTypeExactAndSubs)
                arr = [approxiMatcher approxiMatchForQuery:query andNumOfSubs:subs andIsReverse:NO andReadLen:actualReadLen cumSepGenomeLens:cumulativeSeparateGenomeLens];
            else if (matchType == MatchTypeSubsAndIndels) {
                //printf("DK: calling insertionDeletionMatches (Forward)\n");
                arr = [self insertionDeletionMatchesForQuery:query andLastCol:lastCol andNumOfSubs:subs andIsReverse:NO andShouldSeed:shouldSeed readLen:actualReadLen];
            }
        }
        
        forwardMatches = [arr count];
        
        if (alignmentType == kAlignmentTypeForwardAndReverse) {//Reverse also
            char *revSeq = [self getReverseComplementForSeq:query seqLen:actualReadLen];
            if (subs == 0 || matchType == MatchTypeExactOnly) {
                int temp = dgenomeLen;
                dgenomeLen = lastColLen;
                arr = [arr arrayByAddingObjectsFromArray:[exactMatcher exactMatchForQuery:revSeq andIsReverse:YES andForOnlyPos:NO]];
                dgenomeLen = temp;
            }
            else {
                if (matchType == MatchTypeExactAndSubs)
                    arr = [arr arrayByAddingObjectsFromArray:[approxiMatcher approxiMatchForQuery:revSeq andNumOfSubs:subs andIsReverse:YES andReadLen:actualReadLen cumSepGenomeLens:cumulativeSeparateGenomeLens]];
                else if (matchType == MatchTypeSubsAndIndels) {
                    //printf("DK: calling insertionDeletionMatches (Reverse)\n");
                    arr = [arr arrayByAddingObjectsFromArray:[self insertionDeletionMatchesForQuery:revSeq andLastCol:lastCol andNumOfSubs:subs andIsReverse:YES andShouldSeed:shouldSeed readLen:actualReadLen]];
                }
            }
            free(revSeq);
        }
        
        if (kDebugAllInfo>0) {
            //prints all objects of arr to the console
            int refPos = INT32_MAX;
            int smallestRefPosIndex = -1;
            for (int i = 0; i<[arr count]; i++) {
                ED_Info *d = [arr objectAtIndex:i];
                if (d.position <= refPos) {
                    refPos = d.position;
                    smallestRefPosIndex = i;
                }
            }
        }

        if (kDebugOn>0)
            for (int o = 0; o<arr.count; o++)
                printf("\nMATCH[%i] FOR QUERY: %s WITH NUMOFSUBS: %i ::: %i",o,query,subs,[[arr objectAtIndex:o] intValue]);
        
        if (kDebugOn == -1)
            for (int o = 0; o<[arr count]; o++)
                printf("\n%i\n",[[arr objectAtIndex:o] intValue]);
        
        if ([arr count] > 0) {
//            ED_Info *info = [arr objectAtIndex:((int)arc4random()%[arr count])];
//            arr = nil;
            
            //Get the best alignment and return it
            float lowestErrorRate = 1;
            ED_Info* lowestErrorRateInfo = arr[0];
            for (ED_Info *info in arr) {
                float errorRate = info.distance / (float)strlen(info.gappedA);
                if (errorRate < lowestErrorRate) {
                    lowestErrorRate = errorRate;
                    lowestErrorRateInfo = info;
                }
                
            }
            return lowestErrorRateInfo;
        }
        if (subs + step > amtOfSubs && subs != amtOfSubs)
            subs = amtOfSubs-step;
    }
    return NULL;//No match
}

- (void)updatePosOccsArrayWithRange:(NSRange)range andED_Info:(ED_Info *)info relativeReadNum:(int)relativeReadNum {

    dispatch_queue_t _q = dispatch_queue_create("fish tuna", DISPATCH_QUEUE_SERIAL);
    if (info == NULL) {
        dispatch_async(_q, ^{
            [delegate readProccesed:@"" andMatchedAtLeastOnce:NO];
            return;
        });
    }
    
        if (range.length != strlen(info.gappedA)) {
            int startLoc = (info.position < 0) ? abs(info.position) : 0;
            strlcpy(info.gappedA, &info.gappedA[startLoc], range.length+1);//strlcpy auto adds null terminator so no need to do it explicitly
            
            if (strlen(info.gappedB) > 1) {
                strlcpy(info.gappedB, &info.gappedB[startLoc], range.length+1);
            }
            if (startLoc > 0)
                info.position = 0;
        }
        if (!info.insertion && info.distance > 0) {
//            dispatch_queue_t _q = dispatch_queue_create("afffpples", DISPATCH_QUEUE_SERIAL);
//            dispatch_async(_q, ^{
            for (int i = range.location; i<range.length+range.location; i++) {
                int c = [BWT_MatcherSC whichChar:info.gappedA[i-range.location] inContainer:acgt];
                
                if (c == -1) {//DEL --- Not positive though
                    if (info.gappedA[i-range.location] == kDelMarker)
                        c = kACGTLen;
                }
                
                OSAtomicIncrement32(&posOccArray[c][i]);
    //            posOccArray[c][i]++;
            }
//            });
        }
        else if (info.distance == 0) {
//            dispatch_queue_t _q = dispatch_queue_create("appfffales", DISPATCH_QUEUE_SERIAL);
//            dispatch_async(_q, ^{
            for (int i = info.position; i<range.length+info.position; i++) {
                int c = [BWT_MatcherSC whichChar:info.gappedA[i-info.position] inContainer:acgt];
                
                if (c == -1) {//DEL --- Not positive though
                    if (info.gappedA[i-info.position] == kDelMarker)
                        c = kACGTLen;
                }
                
                OSAtomicIncrement32(&posOccArray[c][i]);
    //            posOccArray[c][i]++;
            }
//            });
        }
        else {
            [self recordInDel:info relativeReadNum:relativeReadNum];
        }

//        if (kDebugAllInfo > 0) {
//            if (info != NULL)
//                printf("\n%i,%i,%c,%i,%s,%s", readNum,info.position,(info.isRev) ? '-' : '+', info.distance,info.gappedB,info.gappedA);
//        }
    @synchronized (self) {
        NSString *readDataStr = [NSString stringWithFormat:kReadExportDataBasicInfo, info.readName,info.position+1/* +1 because export data should start from 1, not 0*/,(info.isRev) ? '-' : '+', info.distance,info.gappedB,info.gappedA];

        [delegate readProccesed:readDataStr andMatchedAtLeastOnce:info != NULL];
        [readAlignmentsArr addObject:info];
    };
}

- (void)createOriginalStrWithDividers {
    int originalStrWithDividersSize = dgenomeLen + ([cumulativeSeparateGenomeLens count] + 1) * kOriginalStrSegmentLetterDividersLen + 1;
    originalStrWithDividers = malloc(originalStrWithDividersSize);
    originalStrWithDividers[originalStrWithDividersSize - 1] = '\0';
    char *strOfLetterDividers = malloc(kOriginalStrSegmentLetterDividersLen + 1);
    strOfLetterDividers[kOriginalStrSegmentLetterDividersLen] = '\0';
    for (int i = 0; i < kOriginalStrSegmentLetterDividersLen; i++) {
        strOfLetterDividers[i] = kOriginalStrSegmentLetterDivider;
    }
    strcpy(originalStrWithDividers, strOfLetterDividers);
    int posInOriginalStrWithDividers = kOriginalStrSegmentLetterDividersLen;
    int indexInCumulativeSegLens = 0;
    for (int i = 0; i < dgenomeLen; i++) {
        if (i == [[cumulativeSeparateGenomeLens objectAtIndex:indexInCumulativeSegLens] intValue]) {
            strcpy(originalStrWithDividers + posInOriginalStrWithDividers, strOfLetterDividers);
            posInOriginalStrWithDividers += kOriginalStrSegmentLetterDividersLen;
            indexInCumulativeSegLens++;
        }
        originalStrWithDividers[posInOriginalStrWithDividers] = originalStr[i];
        posInOriginalStrWithDividers++;
    }
    free(strOfLetterDividers);
}

//INSERTION/DELETION
- (NSMutableArray*)insertionDeletionMatchesForQuery:(char*)query andLastCol:(char*)lastCol andNumOfSubs:(int)numOfSubs andIsReverse:(BOOL)isRev andShouldSeed:(BOOL)shouldSeed readLen:(int)actualReadLen {
    //    Create BWT Matcher for In/Del
    

    BWT_Matcher_InsertionDeletion *bwtIDMatcher = [[BWT_Matcher_InsertionDeletion alloc] init];
    if (shouldSeed) {
        //    Split read into chunks
        int numOfChunks = numOfSubs+1;
        int queryLength = actualReadLen;
        int sizeOfChunks = queryLength/numOfChunks;
        
        if (fmod(queryLength, 2) != 0) {
            //Odd
            queryLength++;
            sizeOfChunks = (float)queryLength/numOfChunks;
        }
        
        //printf("DK: creating Chunk Array with query: %s\n",query);
        
        //    Fill Chunks with their respective string, and then use exact match to match the chunks to the reference
        int start = 0;
        NSMutableArray *chunkArray = [[NSMutableArray alloc] init];
        
        for (int i = 0; i<numOfChunks; i++) {
            Chunks *chunk = [[Chunks alloc] initWithString:query];
            if (i < numOfChunks-1)
                chunk.range = NSMakeRange(start, sizeOfChunks);
            else
                chunk.range = NSMakeRange(start, sizeOfChunks+(int)(float)queryLength % numOfChunks);
            
            chunk.matchedPositions = [NSMutableArray arrayWithArray:[exactMatcher exactMatchForChunk:chunk andIsReverse:isRev andForOnlyPos:YES]];
            for (int j = 0; j < [chunk.matchedPositions count]; j++) {
                int pos = [[chunk.matchedPositions objectAtIndex:j] intValue];
                ED_Info *temp = [[ED_Info alloc] init];
                temp.position = pos;
                pos = [BWT_MatcherSC infoByUnjustingForSegmentDividerLettersForInfo:temp cumSepSegLens:cumulativeSeparateGenomeLens].position;
                [chunk.matchedPositions setObject:[NSNumber numberWithInt:pos] atIndexedSubscript:j];
            }
            [chunkArray addObject:chunk];
            start += sizeOfChunks;
            
            //printf("DK: log Chunk Matched Position State: %i, Str State: %s\n",chunk.str != NULL, chunk.str);
        }
        
        //printf("DK: calling setUpWithCharA:query andCharB:originalStr andChunks\n");
        
        //  Find In/Del by using the matched positions of the chunks
        NSMutableArray *matchedInDels = [bwtIDMatcher setUpWithCharA:query andCharB:originalStrWithDividers andChunks:chunkArray andMaximumEditDist:numOfSubs andIsReverse:isRev];
        
        [chunkArray removeAllObjects];
        chunkArray = nil;
        
        return matchedInDels;
    }
    else {
        return [bwtIDMatcher setUpWithNonSeededCharA:query andCharB:originalStrWithDividers andMaximumEditDist:numOfSubs andIsReverse:isRev andExactMatcher:exactMatcher andCumSegLensArr:cumulativeSeparateGenomeLens andErrorRate:maxErrorRate];
//        return [bwtIDMatcher setUpWithCharA:query andCharB:originalStr andMaximumEditDist:numOfSubs andIsReverse:isRev withCumulativeSegmentLengthsArr:cumulativeSeparateGenomeLens];
    }
}

- (void)recordInDel:(ED_Info*)info relativeReadNum:(int)relativeReadNum {
    int aLen = strlen(info.gappedA);
    
//    if (info.position+aLen<=fileStrLen && !info.insertion) //If it does not go over
//        [self updatePosOccsArrayWithRange:NSMakeRange(info.position,aLen) andQuery:info.gappedA andED_Info:NULL andIsReverse:NO];
    
    //        INSERTIONS
    if (info.position >= 0 && info.position+aLen-info.numOfInsertions<=dgenomeLen) {//ISN'T Negative and doesn't go over
        int bLen = strlen(info.gappedB);
        volatile int32_t insCount = 0;

        for (int a = 0; a<bLen; a++) {
            if (info.gappedB[a] == kDelMarker) {
                BWT_Matcher_InsertionDeletion_InsertionHolder *tID = [[BWT_Matcher_InsertionDeletion_InsertionHolder alloc] init];
                [tID setUp];
                
                if (a - 1 >= 0) {
                    tID.seq[0] = info.gappedA[a - 1];
                    tID.seq[1] = info.gappedA[a];
                    tID.seq[2] = '\0';
                } else {
                    tID.seq[0] = info.gappedA[a];
                    tID.seq[1] = '\0';
                }
                tID.pos = info.position+a-insCount-1;
                
                int tIDSeqLen = strlen(tID.seq);
                
                while (info.gappedB[a+1] == kDelMarker) {
                    if (tIDSeqLen > strlen(tID.seq) + 1) {
                        tID.seq = realloc(tID.seq, tIDSeqLen + 1);
                    }
                    tID.seq[tIDSeqLen] = info.gappedA[a+1];
                    tID.seq[tIDSeqLen+1] = '\0';
                    insCount++;
                    a++;
                    tIDSeqLen++;
                }
                //Check if insertions array already has it
                BOOL alreadyRec = FALSE;
            
//                for (int l = 0; l<self.insertionsArray.count; l++) {
//                    BWT_Matcher_InsertionDeletion_InsertionHolder *tt = [self.insertionsArray objectAtIndex:l];
                NSString *insertionsDictKeyFormat = [NSString stringWithFormat:@"%d>%s", tID.pos, tID.seq];
                BWT_Matcher_InsertionDeletion_InsertionHolder *tt = [insertionsDict objectForKey:insertionsDictKeyFormat];
//                    if (![tt isKindOfClass:[NSNull class]] && tt.pos == tID.pos && strcmp(tt.seq, tID.seq) == 0) {
//                        tt.count++;
//                        alreadyRec = TRUE;
////                        free(tID.seq);
//                    }
                if (tt) {
                    tt.count++;
                    alreadyRec = TRUE;
                    free(tID.seq);
                }
//                }
                if (!alreadyRec) {
                    [insertionsDict setObject:tID forKey:insertionsDictKeyFormat];
//                    [self.insertionsArray addObject:tID];
                }
                OSAtomicIncrement32(&posOccArray[kACGTLen+1][tID.pos]);
                OSAtomicIncrement32(&insCount);
            }
            else {
                int w = [BWT_MatcherSC whichChar:info.gappedA[a] inContainer:acgt];
                if ((a + 1 < aLen && info.gappedB[a + 1] != kDelMarker) || (a + 1 == aLen))
                    OSAtomicIncrement32(&posOccArray[(w>-1) ? w : kACGTLen][info.position+a-insCount]);
            }
        }
    }
}
//INSERTION/DELETION END

- (void)setUpNumberOfOccurencesArray {
    int len = dgenomeLen;
    
    int spotInACGTOccurences = 0;
    
    acgt = malloc(kACGTLen+1);
    strcpy(acgt, kACGTStr);
    acgt[kACGTLen+1] = '\0';
    
    int occurences[kACGTLen];//0 = a, 1 = c, 2 = g, t = 3
    for (int i = 0; i<kACGTLen; i++) {
        occurences[i] = 0;
        acgtTotalOccs[i] = 0;
    }
    int pos = kMultipleToCountAt-1;
    if (len>kMultipleToCountAt) {
        for (int i = 0; i<len; i++) {
            for (int x = 0; x<kACGTLen; x++) {
                if (acgt[x] == refStrBWT[i]) {
                    occurences[x]++;
                    acgtTotalOccs[x]++;
                }
            }
            if (i == pos) {
                for (int l = 0; l<kACGTLen; l++)
                    acgtOccurences[spotInACGTOccurences][l] = occurences[l];
                spotInACGTOccurences++;
                for (int x = 0; x<kACGTLen; x++)
                    occurences[x] = 0;
                pos += kMultipleToCountAt;
            }
            /*for (int x = 0; x<kACGTLen; x++) {
                if (acgt[x] == refStrBWT[i])
                    acgtTotalOccs[x]++;
            }*/
        }
    }
}

- (void)setUpNumberOfOccurencesArrayFast {
    int len = dgenomeLen;
    
    int spotInACGTOccurences = 0;
    
    NSLog(@"About to creat acgt string");
    
    acgt = malloc(kACGTLen+1);
    NSLog(@"About to copy kACGTStr into acgt");
    strcpy(acgt, kACGTStr);
    acgt[kACGTLen] = '\0';

    int occurences[kACGTLen];//0 = a, 1 = c, 2 = g, t = 3
    for (int i = 0; i<kACGTLen; i++) {
        occurences[i] = 0;
        acgtTotalOccs[i] = 0;
    }

    int pos = kMultipleToCountAt-1;
    if (len>kMultipleToCountAt) {
        for (int i = 0; i<len; i++) {
            for (int x = 0; x<kACGTLen; x++) {
                if (acgt[x] == refStrBWT[i])
                    occurences[x]++;
            }
            if (i == pos) {
                for (int l = 0; l<kACGTLen; l++)
                    acgtOccurences[spotInACGTOccurences][l] = occurences[l];
                spotInACGTOccurences++;
                pos += kMultipleToCountAt;
            }
            for (int x = 0; x<kACGTLen; x++) {
                if (acgt[x] == refStrBWT[i])
                    acgtTotalOccs[x]++;
            }
        }
    }
    NSLog(@"Set up number of occurences array COMPLETED!!");
}

- (float)getTotalAlignmentRuntime {
    return totalAlignmentRuntime;
}

//Getters
- (char*)getReverseComplementForSeq:(char*)seq seqLen:(int)actualReadLen {
    int len = actualReadLen; //The only thing you should be getting a reverse complement for is the read (am I right?)
    char *revSeq = malloc(len+1);
    
    for (int i = 0; i<len; i++)
        revSeq[i] = acgt[kACGTLen-[BWT_MatcherSC whichChar:seq[len-i-1] inContainer:acgt]-1];//len-i-1 because that allows for 0th pos to be set rather than just last pos to be set is 1
    revSeq[len] = '\0';
    return revSeq;
}

//Free memory
- (void)freeUsedMemory {
    for (BWT_Matcher_InsertionDeletion_InsertionHolder *insHolder in insertionsArray) {
        [insHolder freeUsedMemory];
    }
    reedsArray = nil;
    free(originalStrWithDividers);
//    if (firstCol && strlen(firstCol) > 0)
//        free(firstCol);
//    if (refStrBWT && strlen(refStrBWT) > 0)
//        free(refStrBWT);
}
@end