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
    
    NSLog(@"About to create firstCol");
    
    [self setUpNumberOfOccurencesArrayFast];
    
    firstCol = calloc(dgenomeLen+1, 1);
    
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
}

- (void)matchReeds {
    
    NSLog(@"Match Reeds Entered");
    
    if (!matchingTimer)
        matchingTimer = [[APTimer alloc] init];
    [matchingTimer start];
    Read *reed;
    readDataStr = [[NSMutableString alloc] init];
    if (kDebugOn == 2)
        printf("%s\n",originalStr);
    
    NSLog(@"About to enter match reads loop");
    
    for (readNum = 0; readNum < reedsArray.count; readNum++) {
        
        reed = [reedsArray objectAtIndex:readNum];
        readLen = (int)strlen(reed.sequence);
        
        //printf("DK: calling getBestMatchForQuery\n");
        int maxNumOfSubs = maxErrorRate * readLen;
        ED_Info* a = [self getBestMatchForQuery:reed.sequence withLastCol:refStrBWT andFirstCol:firstCol andNumOfSubs:maxNumOfSubs andReadNum:readNum];
        
        if (a != NULL) {
            a.readName = reed.name;
            //printf("DK: calling numOfCharsPastSegment\n");
//            int gappedALen = strlen(a.gappedA);
//            int charsToTrimEnd = [self numOfCharsPastSegmentEndingForEDInfo:a andReadLen:gappedALen];
//            int charsToTrimBeginning = (a.position < 0) ? abs(a.position) : 0;
            
            a = [self updatedInfoCorrectedForExtendingOverSegmentStartsAndEnds:a forNumOfSubs:maxNumOfSubs];
            
//            a.distance += charsToTrimEnd + charsToTrimBeginning;
            if (a.distance <= maxNumOfSubs) {
                //printf("DK: calling updatePosOccsArray\n");
                [self updatePosOccsArrayWithRange:NSMakeRange(a.position, strlen(a.gappedA)) andED_Info:a];
            }
            else
                a = NULL;//So it is not counted as matchedAtLeastOnce
            
        }
        //printf("DK: calling readProcessed\n");
        [delegate readProccesed:readDataStr andMatchedAtLeastOnce:a != NULL];
        [readDataStr setString:@""];
    }
//    [exactMatcher timerPrint];
    [matchingTimer stopAndLog];
}

- (ED_Info*)updatedInfoCorrectedForExtendingOverSegmentStartsAndEnds:(ED_Info *)info forNumOfSubs:(int)subs {
    int gappedALen = (int)strlen(info.gappedA);
    
    int index = [self indexInCumSepGenomeLensArrOfClosestSegmentEndingForEDInfo:info];
    
    int closeEnding = [[cumulativeSeparateGenomeLens objectAtIndex:index] intValue];
    
    BOOL shouldTrim = (closeEnding - (info.position + gappedALen) <= 0);
    
    BOOL trimEnding = NO;
    BOOL trimBeginning = NO;
    
    if (shouldTrim) {
        if (abs(closeEnding - (info.position + gappedALen)) < closeEnding - info.position)
            trimEnding = TRUE;
        else
            trimBeginning = TRUE;
    }
//    BOOL trimEnding = (closeEnding - (info.position + gappedALen) <= 0);
//    BOOL trimBeginning = trimEnding && (closeEnding - info.position > 0 && (closeEnding - (info.position + gappedALen) <= 0));
    
    if (index < 0 || (!trimBeginning && !trimEnding))
        return info;
    
    int charsToTrimEnd = (trimEnding) ? [self numOfCharsPastSegmentEndingForEDInfo:info andReadLen:gappedALen andIndexInCumSepGenomesOfClosestSegmentEndingPos:index] : 0;
    
    int charsToTrimBeginning = (trimBeginning) ? [self numOfCharsBeforeSegmentEndingForEDInfo:info andReadLen:gappedALen andIndexInCumSepGenomesOfClosestSegmentEndingPos:index] : 0;
    
    int amtOfCharsToAddToPosition = (trimBeginning) ? [[cumulativeSeparateGenomeLens objectAtIndex:index] intValue] - info.position : 0;
    
    BOOL noGappedB = strcmp(info.gappedB, kNoGappedBChar) == 0;
    
    if (charsToTrimEnd <= 0 && charsToTrimBeginning <= 0)
        return info;
    
    ED_Info *newInfo = [[ED_Info alloc] init];
    
    newInfo.insertion = info.insertion;
    newInfo.position = info.position;
    newInfo.isRev = info.isRev;
    newInfo.readName = info.readName;
    newInfo.rowInAlignmentGrid = info.rowInAlignmentGrid;
    
    int numOfCharsToTrimFromBeginningFromED = 0;
    
    if (noGappedB)
        numOfCharsToTrimFromBeginningFromED = charsToTrimBeginning;
    else {
        for (int i = 0; i < charsToTrimBeginning; i++)
            if (info.gappedA[i] == info.gappedB[i])
                numOfCharsToTrimFromBeginningFromED++;
    }
    
    int numOfCharsToTrimFromEndFromED = 0;

    if (noGappedB)
        numOfCharsToTrimFromEndFromED = charsToTrimEnd;
    else {
        for (int i = gappedALen-charsToTrimEnd; i < (gappedALen-charsToTrimEnd-1)+charsToTrimEnd+1; i++)
            if (info.gappedA[i] == info.gappedB[i])
                numOfCharsToTrimFromEndFromED++;
    }
    
    newInfo.gappedA = calloc(gappedALen-charsToTrimBeginning-charsToTrimEnd+1, 1);//+1 for null terminator
    strncpy(newInfo.gappedA, info.gappedA+charsToTrimBeginning, gappedALen-charsToTrimBeginning-charsToTrimEnd);
    newInfo.gappedA[gappedALen-charsToTrimBeginning-charsToTrimEnd] = '\0';
    
    if (!noGappedB) {
        newInfo.gappedB = calloc(gappedALen-charsToTrimBeginning-charsToTrimEnd+1, 1);//+1 for null terminator
        strncpy(newInfo.gappedB, info.gappedB+charsToTrimBeginning, gappedALen-charsToTrimBeginning-charsToTrimEnd);
        newInfo.gappedB[gappedALen-charsToTrimBeginning-charsToTrimEnd] = '\0';
    }
    else
        newInfo.gappedB = strdup(kNoGappedBChar);
        
    newInfo.distance = info.distance;

    newInfo.distance += numOfCharsToTrimFromBeginningFromED;
    newInfo.position += amtOfCharsToAddToPosition;

    newInfo.distance += numOfCharsToTrimFromEndFromED;
    
    [info freeUsedMemory];//Doesn't free readName, so the above code where I set all of newInfo. should be good
    
    return newInfo;
}

- (ED_Info*)getBestMatchForQuery:(char*)query withLastCol:(char*)lastCol andFirstCol:(char*)firstCol andNumOfSubs:(int)amtOfSubs andReadNum:(int)readNum {
    
    NSArray *arr;
    
    int forwardMatches = 0;//EX. ACA

    BWT_Matcher_Approxi *approxiMatcher = [[BWT_Matcher_Approxi alloc] init];
    for (int subs = 0; subs < amtOfSubs+1; subs++) {
        if (subs == 0 || matchType == MatchTypeExactOnly)
            arr = [exactMatcher exactMatchForQuery:query andIsReverse:NO andForOnlyPos:NO];
        else {
            if (matchType == MatchTypeExactAndSubs)
                arr = [approxiMatcher approxiMatchForQuery:query andNumOfSubs:subs andIsReverse:NO andReadLen:readLen];
            else if (matchType == MatchTypeSubsAndIndels) {
                //printf("DK: calling insertionDeletionMatches (Forward)\n");
                arr = [self insertionDeletionMatchesForQuery:query andLastCol:lastCol andNumOfSubs:subs andIsReverse:NO];
            }
        }
        
        forwardMatches = [arr count];
        
        if (alignmentType == kAlignmentTypeForwardAndReverse) {//Reverse also
            if (subs == 0 || matchType == MatchTypeExactOnly)
                arr = [arr arrayByAddingObjectsFromArray:[exactMatcher exactMatchForQuery:[self getReverseComplementForSeq:query] andIsReverse:YES andForOnlyPos:NO]];
            else {
                if (matchType == MatchTypeExactAndSubs)
                    arr = [arr arrayByAddingObjectsFromArray:[approxiMatcher approxiMatchForQuery:[self getReverseComplementForSeq:query] andNumOfSubs:subs andIsReverse:YES andReadLen:readLen]];
                else if (matchType == MatchTypeSubsAndIndels) {
                    //printf("DK: calling insertionDeletionMatches (Reverse)\n");
                    arr = [arr arrayByAddingObjectsFromArray:[self insertionDeletionMatchesForQuery:[self getReverseComplementForSeq:query] andLastCol:lastCol andNumOfSubs:subs andIsReverse:YES]];
                }
            }
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
            ED_Info *info = [arr objectAtIndex:((int)arc4random()%[arr count])];
            arr = nil;
            return info;
        }
    }
    return NULL;//No match
}

- (void)updatePosOccsArrayWithRange:(NSRange)range andED_Info:(ED_Info *)info {
//    if (info.isRev)
//        query = [self getReverseComplementForSeq:query];
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
        for (int i = range.location; i<range.length+range.location; i++) {
            int c = [BWT_MatcherSC whichChar:info.gappedA[i-range.location] inContainer:acgt];
            
            if (c == -1) {//DEL --- Not positive though
                if (info.gappedA[i-range.location] == kDelMarker)
                    c = kACGTLen;
            }
            
            posOccArray[c][i]++;
        }
    }
    else if (info.distance == 0) {
        for (int i = info.position; i<range.length+info.position; i++) {
            int c = [BWT_MatcherSC whichChar:info.gappedA[i-info.position] inContainer:acgt];
            
            if (c == -1) {//DEL --- Not positive though
                if (info.gappedA[i-info.position] == kDelMarker)
                    c = kACGTLen;
            }
            
            posOccArray[c][i]++;
        }
    }
    else {
        [self recordInDel:info];
    }
    
    if (kDebugAllInfo > 0) {
        if (info != NULL)
            printf("\n%i,%i,%c,%i,%s,%s", readNum,info.position,(info.isRev) ? '-' : '+', info.distance,info.gappedB,info.gappedA);
//        else
//            printf("\n%i,%i,%c,%i,%s,%s", readNum,range.location,(isRev) ? '-' : '+', -2-1,"N/A",query);
    }
    [readDataStr setString:@""];
    [readDataStr appendFormat:kReadExportDataBasicInfo, info.readName,info.position+1/* +1 because export data should start from 1, not 0*/,(info.isRev) ? '-' : '+', info.distance,info.gappedB,info.gappedA];
    [readAlignmentsArr addObject:info];
}

//INSERTION/DELETION
- (NSMutableArray*)insertionDeletionMatchesForQuery:(char*)query andLastCol:(char*)lastCol andNumOfSubs:(int)numOfSubs andIsReverse:(BOOL)isRev {
    //    Create BWT Matcher for In/Del
    BWT_Matcher_InsertionDeletion *bwtIDMatcher = [[BWT_Matcher_InsertionDeletion alloc] init];
    
    //    Split read into chunks
    int numOfChunks = numOfSubs+1;
    int queryLength = readLen;
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
        
        chunk.matchedPositions = (NSMutableArray*)[exactMatcher exactMatchForChunk:chunk andIsReverse:isRev andForOnlyPos:YES];
        [chunkArray addObject:chunk];
        start += sizeOfChunks;
        
        //printf("DK: log Chunk Matched Position State: %i, Str State: %s\n",chunk.str != NULL, chunk.str);
    }
    
    //printf("DK: calling setUpWithCharA:query andCharB:originalStr andChunks\n");
    
    //  Find In/Del by using the matched positions of the chunks
    NSMutableArray *matchedInDels = [bwtIDMatcher setUpWithCharA:query andCharB:originalStr andChunks:chunkArray andMaximumEditDist:numOfSubs andIsReverse:isRev];

    [chunkArray removeAllObjects];
    chunkArray = nil;
    
    return matchedInDels;
}

- (void)recordInDel:(ED_Info*)info {
    int aLen = strlen(info.gappedA);
    
//    if (info.position+aLen<=fileStrLen && !info.insertion) //If it does not go over
//        [self updatePosOccsArrayWithRange:NSMakeRange(info.position,aLen) andQuery:info.gappedA andED_Info:NULL andIsReverse:NO];
    
    //        INSERTIONS
    if (info.position >= 0 && info.position+aLen<=dgenomeLen) {//ISN'T Negative and doesn't go over
        int bLen = strlen(info.gappedB);
        int insCount = 0;

        for (int a = 0; a<bLen; a++) {
            if (info.gappedB[a] == kDelMarker) {
                BWT_Matcher_InsertionDeletion_InsertionHolder *tID = [[BWT_Matcher_InsertionDeletion_InsertionHolder alloc] init];
                [tID setUp];
                tID.seq[0] = info.gappedA[a];
                tID.seq[1] = '\0';
                tID.pos = info.position+a-insCount;
                
                int tIDSeqLen = strlen(tID.seq);
                
                while (info.gappedB[a+1] == kDelMarker) {
                    tID.seq[tIDSeqLen] = info.gappedA[a+1];
                    tID.seq[tIDSeqLen+1] = '\0';
                    insCount++;
                    a++;
                }
                //Check if insertions array already has it
                BOOL alreadyRec = FALSE;
                for (int l = 0; l<self.insertionsArray.count; l++) {
                    BWT_Matcher_InsertionDeletion_InsertionHolder *tt = [self.insertionsArray objectAtIndex:l];
                    if (tt.pos == tID.pos && strcmp(tt.seq, tID.seq) == 0) {
                        tt.count++;
                        alreadyRec = TRUE;
                    }
                }
                if (!alreadyRec) {
                    [self.insertionsArray addObject:tID];
                }
                posOccArray[kACGTLen+1][tID.pos]++;//Insertions add one
                insCount++;
            }
            else {
                int w = [BWT_MatcherSC whichChar:info.gappedA[a] inContainer:acgt];
                posOccArray[(w>-1) ? w : kACGTLen][info.position+a-insCount]++;
            }
        }
    }
}
//INSERTION/DELETION END

- (void)setUpNumberOfOccurencesArray {
    int len = dgenomeLen;
    
    int spotInACGTOccurences = 0;
    
    acgt = calloc(kACGTLen+1, 1);
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
    
    acgt = calloc(kACGTLen+1, 1);
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

- (int)indexInCumSepGenomeLensArrOfClosestSegmentEndingForEDInfo:(ED_Info*)info {
    for (int i = 0; i < [cumulativeSeparateGenomeLens count]; i++) {
        int v = [[cumulativeSeparateGenomeLens objectAtIndex:i] intValue];
        if (info.position < v) {
            return i;
        }
    }
    return -1;
}

- (int)numOfCharsPastSegmentEndingForEDInfo:(ED_Info *)info andReadLen:(int)readL andIndexInCumSepGenomesOfClosestSegmentEndingPos:(int)index {
    
    int closestLen = [[cumulativeSeparateGenomeLens objectAtIndex:index] intValue];
    
    if (info.position - info.numOfInsertions + readL-1 < closestLen)
        return 0;
    
    int charsToTrim = info.position - info.numOfInsertions +readL-closestLen;
    
    return charsToTrim;
}

- (int)numOfCharsBeforeSegmentEndingForEDInfo:(ED_Info *)info andReadLen:(int)readL andIndexInCumSepGenomesOfClosestSegmentEndingPos:(int)index {
   
    int closestBeginning = [[cumulativeSeparateGenomeLens objectAtIndex:index] intValue];
    
    int k = closestBeginning;
    
    for (int i = info.position; i <= k; i++)
        if (info.gappedB[i-info.position] == kDelMarker)
            k++;
    
    return k-info.position;
}

//Getters
- (char*)getReverseComplementForSeq:(char*)seq {
    int len = readLen; //The only thing you should be getting a reverse complement for is the read (am I right?)
    char *revSeq = calloc(len+1, 1);
    
    for (int i = 0; i<len; i++)
        revSeq[i] = acgt[kACGTLen-[BWT_MatcherSC whichChar:seq[len-i-1] inContainer:acgt]-1];//len-i-1 because that allows for 0th pos to be set rather than just last pos to be set is 1
    revSeq[len] = '\0';
    return revSeq;
}

//Free memory
- (void)freeUsedMemory {
    reedsArray = nil;
//    if (firstCol && strlen(firstCol) > 0)
//        free(firstCol);
//    if (refStrBWT && strlen(refStrBWT) > 0)
//        free(refStrBWT);
}
@end