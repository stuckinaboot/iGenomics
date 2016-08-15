//
//  BWT_Matcher_InsertionDeletion.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 10/29/12.
//
//

#import "BWT_Matcher_InsertionDeletion.h"
#import "Chunks.h"

@implementation BWT_Matcher_InsertionDeletion

//New Stuff

- (NSMutableArray*)setUpWithNonSeededCharA:(char*)a andCharB:(char*)b andMaximumEditDist:(int)maxED andIsReverse:(BOOL)isR andExactMatcher:(BWT_MatcherSC *)exactMatcher andCumSegLensArr:(NSArray *)cumLens andErrorRate:(float)errorRate {
    matchedInDels = [[NSMutableArray alloc] init];
    editDist = [[EditDistance alloc] init];
    cumulativeSegmentLens = cumLens;
    isRev = isR;
    maxErrorRate = errorRate;
    //printf("DK: creating newa\n");
    
    //    Add space prior to the chars in "a" and prior to the chars in "b"
    int alen = (int)strlen(a);
    char *newa = malloc(alen+2);
    memcpy(newa+1, a, alen);
    newa[0] = ' ';
    newa[alen+1] = '\0';
    
    /*int blen = strlen(b);
     char *newb = calloc(blen+1, 1);
     memcpy(newb+1, b, blen);
     newb[0] = ' ';*/
    
    maxEditDist = maxED;
    
//    APTimer *findInDelsTimer = [[APTimer alloc] init];
//    [findInDelsTimer start];
    
    [self findInDelsNonSeededWithA:newa b:b usingExactMatcher:exactMatcher isReverse:isR];
    
//    printf("Find in dels timer:\n");
//    [findInDelsTimer stopAndLog];
    //    Free memory---NEEDS TO BE DONE
    free(newa);
    
    return matchedInDels;
}

- (void)findInDelsNonSeededWithA:(char *)a b:(char *)b usingExactMatcher:(BWT_MatcherSC *)exactMatcher isReverse:(BOOL)isReverse {
    int lenA = (int)strlen(a);
    int lenB = (int)strlen(b);
    
    ED_Info *match;
    ED_Info *bestMatch = NULL;
    int interval = 1;

//    for (int k = kNonSeedShortSeqSize; k >= kNonSeedShortSeqMinSize; k -= kNonSeedShortSeqSizeInterval) {
    for (int indexInIntervals = 0; indexInIntervals < kNonSeedShortSeqSizeIntervalsCount; indexInIntervals++) {
        int k = kNonSeedShortSeqSizeIntervals[indexInIntervals];
        char *shortA = malloc(k+1);
        interval = kNonSeedShortSeqInterval;
        
        //Starts at i = 1 so that the space is skipped for exact matching
        for (int i = 1; i <= lenA - k; i += interval) {
            strncpy(shortA, a+i, k);
            shortA[k] = '\0';
            
            //ASK MIKE: <<<What about forward/reverse???>>>
    //        APTimer *timer = [[APTimer alloc] init];
    //        [timer start];
            NSMutableArray *exactMatches = (NSMutableArray*)[exactMatcher exactMatchForQuery:shortA andIsReverse:NO andForOnlyPos:YES];
            if ([exactMatches count] > 1) {
//                for (int j = 0; j < [exactMatches count]; j++) {
//                    ED_Info *ed = [exactMatches objectAtIndex:j];
//                    [ed freeUsedMemory];
//                }
//                printf("tacos\n");
//                 printf("Multi-count\n");
                continue;
            }
    //        [timer stopAndLog];
//            printf("%d\n",[exactMatches count]);
            for (int j = 0; j < [exactMatches count]; j++) {
//                printf("Finding\n");
//                ED_Info *ed = [exactMatches objectAtIndex:j];
                ED_Info *ed = [[ED_Info alloc] init];
                ed.position = [[exactMatches objectAtIndex:j] intValue];
                ed = [BWT_MatcherSC infoByUnjustingForSegmentDividerLettersForInfo:ed cumSepSegLens:cumulativeSegmentLens];
                
    //            if (bestMatch) {
    //                int approxStartOfRead = ed.position - i;
    //                
    //                //If the alignment is likely to already have been recorded in bestMatch, then continue
    //                if (NSLocationInRange(approxStartOfRead,
    //                                      NSMakeRange(bestMatch.position - maxEditDist, lenA + maxEditDist)))
    //                    continue;
    //            }
    //
                int ttt = maxEditDist;
                if (kBandWidth < lenA)
                    maxEditDist = kBandWidth;
                
                int bLoc = ed.position - i - maxEditDist;
                int bRangeLen = lenA+2*maxEditDist;
                if (bLoc < 0) {
//                    bRangeLen += bLoc;
                    bLoc = 0;
                }
                if (bLoc + bRangeLen - 1 >= lenB) {
                    bLoc -= maxEditDist;
                    bRangeLen = lenB-bLoc+maxEditDist;
                }
                
//                APTimer *edTimer = [[APTimer alloc] init];
//                [edTimer start];
                ED_Info *edFinal = [editDist editDistanceForInfoWithFullA:a rangeInA:NSMakeRange(0, lenA) andFullB:b rangeInB:NSMakeRange(bLoc, bRangeLen) andMaxED:maxEditDist];//[ED_Info mergedED_Infos:edL andED2:ed];
//                printf("ED Timer:\n");
//                [edTimer stopAndLog];
                
                maxEditDist = ttt;
                edFinal.position += bLoc;
    //            edFinal.position = ed.position - (int)strlen(edL.gappedA) + edL.numOfInsertions;
                
                
    //            if (edFinal && edFinal.distance < kMaxER * lenA && edFinal.distance > maxEditDist)
    //                edFinal = [BWT_MatcherSC updatedInfoCorrectedForExtendingOverSegmentStartsAndEnds:edFinal forNumOfSubs:maxEditDist withCumSepGenomeLens:cumulativeSegmentLens maxErrorRate:maxErrorRate originalReadLen:lenA];
                
                if (edFinal) {
                    edFinal = [BWT_MatcherSC infoByAdjustingForSegmentDividerLettersForInfo:edFinal cumSepSegLens:cumulativeSegmentLens];
                    edFinal.alreadyHasPosAdjusted = TRUE;
                }

                if (edFinal != NULL && edFinal.distance <= maxErrorRate * (int)strlen(edFinal.gappedA)) {
    //                edFinal = [BWT_MatcherSC infoByAdjustingForSegmentDividerLettersForInfo:edFinal cumSepSegLens:cumulativeSegmentLens];
                    match = edFinal;
                    if (bestMatch == NULL) {
                        bestMatch = match;
                    } else if (match.distance / (float)strlen(match.gappedA) < bestMatch.distance / (float)strlen(bestMatch.gappedA)) {
    //                } else if (match.distance < bestMatch.distance) {
                        bestMatch = match;
                    }
                    break;
                }
                else
                    [edFinal freeUsedMemory];
                
            }
//            for (int j = 0; j < [exactMatches count]; j++) {
//                ED_Info *ed = [exactMatches objectAtIndex:j];
//                [ed freeUsedMemory];
//            }
//            if (interval == 1 && bestMatch)
//                interval = kNonSeedShortSeqInterval;
            if (match)
                break;
            if (interval != kNonSeedShortSeqMinInterval && i + interval >= lenA - k) {
                i = 0;
                interval = kNonSeedShortSeqMinInterval;
                k = kNonSeedShortSeqMinSize;
            }
        }
        
        free(shortA);
        //Do something with the match if there was one
        if (bestMatch) {
            bestMatch.isRev = isReverse;
            [matchedInDels addObject:bestMatch];
            break;
        }
    }
}

- (ED_Info*)nonSeededEDForFullA:(char *)fullA fullALen:(int)lenA andB:(char*)b startPos:(int)startPos andIsComputingForward:(BOOL)forward {
    ED_Info *finalInfo;
    int lenB = (int)strlen(b);
    
    if (forward) {
        for (int i = 0; i < lenA; i += kNonSeedLongSeqSize) {
            ED_Info *newInfo;
            int aPos = i, aLen = kNonSeedLongSeqSize, bPos = startPos+kNonSeedShortSeqSize+i, bLen = aLen;
            
            //Checks for extension past end of a
            if (i < lenA && i + kNonSeedLongSeqSize > lenA) {
                aLen = lenA-i;
                bLen = aLen;
            }
            
            //Checks for extension past end of b
            if (bPos < lenB && bPos + kNonSeedLongSeqSize > lenB) {
                bLen = lenB-bPos;
                aLen = bLen;
                
                i = lenA;//Breaks the loop
            }
            
            NSRange rangeA = NSMakeRange(aPos, aLen);
            newInfo = [editDist editDistanceForInfoWithFullA:fullA rangeInA:rangeA andFullB:b rangeInB:NSMakeRange(bPos, bLen) andMaxED:maxEditDist];
            if (newInfo)
                finalInfo = [ED_Info mergedED_Infos:finalInfo andED2:newInfo];
        }
    }
    else if (!forward) {
        for (int i = lenA-kNonSeedLongSeqSize; i >= 0; i -= kNonSeedLongSeqSize) {
            ED_Info *newInfo;
            int aPos = i, aLen = kNonSeedLongSeqSize, bPos = startPos-(lenA-i), bLen = kNonSeedLongSeqSize;
            
            //Checks for extension past beginning of b
            if (bPos < 0) {
                bLen = bPos + kNonSeedLongSeqSize;
                bPos = 0;
                aPos += (kNonSeedLongSeqSize-bLen);
                aLen = bLen;
                
                i = -1;//Breaks the loop
            }
            
            NSRange rangeA = NSMakeRange(aPos, aLen);
            newInfo = [editDist editDistanceForInfoWithFullA:fullA rangeInA:rangeA andFullB:b rangeInB:NSMakeRange(bPos, bLen) andMaxED:maxEditDist];
            if (newInfo)
                finalInfo = [ED_Info mergedED_Infos:newInfo andED2:finalInfo];
            
            NSLog(@"%i, %i",(int)strlen(finalInfo.gappedA), (int)strlen(finalInfo.gappedB));
            //Checks for extension past beginning of a
            if (i > 0 && i - kNonSeedLongSeqSize < 0) {
                aPos = 0;
                aLen = i;
                bPos = startPos-lenA;
                bLen = aLen;
                
                rangeA = NSMakeRange(aPos, aLen);
                newInfo = [editDist editDistanceForInfoWithFullA:fullA rangeInA:rangeA andFullB:b rangeInB:NSMakeRange(bPos, bLen) andMaxED:maxEditDist];
                if (newInfo)
                    finalInfo = [ED_Info mergedED_Infos:newInfo andED2:finalInfo];
            }
        }
    }
    return finalInfo;
}

//End New Stuff

- (NSMutableArray*)setUpWithCharA:(char*)a andCharB:(char*)b andChunks:(NSMutableArray*)chunkArray andMaximumEditDist:(int)maxED andIsReverse:(BOOL)isR {
    matchedInDels = [[NSMutableArray alloc] init];
    editDist = [[EditDistance alloc] init];
    isRev = isR;
    
    //printf("DK: creating newa\n");
    
    //    Add space prior to the chars in "a" and prior to the chars in "b"
    int alen = (int)strlen(a);
    char *newa = malloc(alen+2);
    memcpy(newa+1, a, alen);
    newa[0] = ' ';
    newa[alen+1] = '\0';
    
    /*int blen = strlen(b);
    char *newb = calloc(blen+1, 1);
    memcpy(newb+1, b, blen);
    newb[0] = ' ';*/
    
    maxEditDist = maxED;
    
    //printf("DK: calling findInDels\n");
    
    [self findInDels:newa andCharB:b andChunks:chunkArray];
    
    //    Free memory---NEEDS TO BE DONE
    free(newa);
    
    return matchedInDels;
}

- (NSMutableArray*)setUpWithCharA:(char*)a andCharB:(char*)b andMaximumEditDist:(int)maxED andIsReverse:(BOOL)isR withCumulativeSegmentLengthsArr:(NSArray *)cumLens {
    matchedInDels = [[NSMutableArray alloc] init];
    editDist = [[EditDistance alloc] init];
    isRev = isR;
    
    //printf("DK: creating newa\n");
    
    //    Add space prior to the chars in "a" and prior to the chars in "b"
    int alen = strlen(a);
    char *newa = malloc(alen+2);
    memcpy(newa+1, a, alen);
    newa[0] = ' ';
    newa[alen+1] = '\0';
    
    /*int blen = strlen(b);
     char *newb = calloc(blen+1, 1);
     memcpy(newb+1, b, blen);
     newb[0] = ' ';*/
    
    maxEditDist = maxED;
    
    //printf("DK: calling findInDels\n");
    
    [self findInDels:newa andCharB:b withCumulativeSegmentLengthsArr:cumLens];
    
    //    Free memory---NEEDS TO BE DONE
    free(newa);
    
    return matchedInDels;
}

- (void)findInDels:(char*)a andCharB:(char*)b andChunks:(NSMutableArray*)chunkArray {//REMEMBER TO REMOVE SPACE
    int matchedPos = 0;
    int startPos = 0;//+1 is added during substring to account for the space when finding the pos
    int lenA = (int)strlen(a);
    int lenAWithoutSpace = lenA-1;
    Chunks *chunk = [chunkArray objectAtIndex:0];
    int chunkSize = chunk.range.length;
    ED_Info *edInfo;// = [[ED_Info alloc] init];

    
    //printf("DK: finding InDels C1\n");
    //    Finding InDels for Chunk 1
    for (int i = 0; i<chunk.matchedPositions.count; i++) {
        matchedPos = [[chunk.matchedPositions objectAtIndex:i] intValue];
        startPos = [self findStartPosForChunkNum:0 andSizeOfChunks:chunkSize andMatchedPos:matchedPos];
        if (startPos>=0) {
            edInfo = [editDist editDistanceForInfoWithFullA:a rangeInA:NSMakeRange(0, lenA) andFullB:b rangeInB:NSMakeRange(startPos, lenAWithoutSpace+maxEditDist) andMaxED:maxEditDist];
//            edInfo = [editDist editDistanceForInfo:a andBFull:b andRangeOfActualB:NSMakeRange(startPos, lenA+maxEditDist) andChunkNum:0 andChunkSize:chunkSize andMaxED:maxEditDist andKillIfLargerThanDistance:kEditDistanceDoNotKill];
            [self checkForInDelMatch:edInfo andMatchedPos:matchedPos andChunkNum:0 andChunkSize:chunkSize];
        }
    }
    
    
    //printf("DK: finding InDels C2 to Cn-1\n");
    //    Finding InDels for Chunk 2 through amtOfChunks-1
    if ([chunkArray count]>2) {
        for (int cNum = 1; cNum<[chunkArray count]-1; cNum++) {
            chunk = [chunkArray objectAtIndex:cNum];
            for (int i = 0; i<chunk.matchedPositions.count; i++) {
                matchedPos = [[chunk.matchedPositions objectAtIndex:i] intValue];
                startPos = [self findStartPosForChunkNum:cNum andSizeOfChunks:chunkSize andMatchedPos:matchedPos];
                if (startPos>=0) {
                    edInfo = [editDist editDistanceForInfoWithFullA:a rangeInA:NSMakeRange(0, lenA) andFullB:b rangeInB:NSMakeRange(startPos-maxEditDist, lenAWithoutSpace+(maxEditDist*2)) andMaxED:maxEditDist];
//                    edInfo = [editDist editDistanceForInfo:a andBFull:b andRangeOfActualB:NSMakeRange(startPos-maxEditDist, lenA+(maxEditDist*2)) andChunkNum:cNum andChunkSize:chunkSize andMaxED:maxEditDist andKillIfLargerThanDistance:kEditDistanceDoNotKill];
                    [self checkForInDelMatch:edInfo andMatchedPos:matchedPos andChunkNum:cNum andChunkSize:chunkSize];
                }
            }
        }
    }
    
    //printf("DK: finding InDels Cn\n");
    //    Finding InDels for Final Chunk
    if ([chunkArray count]>1) {
        chunk = [chunkArray objectAtIndex:[chunkArray count]-1];
        for (int i = 0; i<chunk.matchedPositions.count; i++) {
            matchedPos = [[chunk.matchedPositions objectAtIndex:i] intValue];
            startPos = [self findStartPosForChunkNum:[chunkArray count]-1 andSizeOfChunks:chunkSize andMatchedPos:matchedPos];
            if (startPos>=0) {
                edInfo = [editDist editDistanceForInfoWithFullA:a rangeInA:NSMakeRange(0, lenA) andFullB:b rangeInB:NSMakeRange(startPos-maxEditDist, lenAWithoutSpace+maxEditDist) andMaxED:maxEditDist];
//                edInfo = [editDist editDistanceForInfo:a andBFull:b andRangeOfActualB:NSMakeRange(startPos-maxEditDist, lenA+maxEditDist) andChunkNum:[chunkArray count]-1 andChunkSize:chunkSize andMaxED:maxEditDist andKillIfLargerThanDistance:kEditDistanceDoNotKill];
                [self checkForInDelMatch:edInfo andMatchedPos:matchedPos andChunkNum:[chunkArray count]-1 andChunkSize:chunkSize];
            }
        }
    }
    
    if (kPrintInDelPos>0) {
        for (int i = 0; i<[matchedInDels count]; i++) {
            ED_Info *info = [matchedInDels objectAtIndex:i];
            if (kPrintInDelPos == 1)
                printf("\nPOS: %i : A: %s : B: %s",info.position,info.gappedA,info.gappedB);
            else if (kPrintInDelPos == 2)
                printf("\nPOS: %i",info.position);
        }
    }
}

- (void)findInDels:(char*)a andCharB:(char*)b withCumulativeSegmentLengthsArr:(NSArray *)cumLens {//REMEMBER TO REMOVE SPACE
    int startPos = 0;//+1 is added during substring to account for the space when finding the pos
    int lenA = strlen(a)-1;
    
    ED_Info *bestMatchedInfo;
    
    APTimer *timer = [[APTimer alloc] init];
    NSLog(@"New Read Being Aligned");
    for (int i = 0; i < cumLens.count; i++) {
        int cumLen = [[cumLens objectAtIndex:i] intValue];
        int segLen = cumLen - startPos;
        [timer start];
        ED_Info *edInfo = [editDist editDistanceForInfo:a andBFull:b andRangeOfActualB:NSMakeRange(startPos, segLen) andChunkNum:0 andChunkSize:lenA andMaxED:maxEditDist andKillIfLargerThanDistance:(!bestMatchedInfo) ? kEditDistanceDoNotKill : bestMatchedInfo.distance];
        if (edInfo)
            edInfo.position = startPos + edInfo.position;
        [timer stopAndLog];
        if (!bestMatchedInfo && edInfo.distance <= maxEditDist)
            bestMatchedInfo = edInfo;
        else if (edInfo != NULL && edInfo.distance < bestMatchedInfo.distance) {
            [bestMatchedInfo freeUsedMemory];
            bestMatchedInfo = edInfo;
        }
        
        startPos = cumLen;
    }
    if (bestMatchedInfo && bestMatchedInfo.distance <= maxEditDist)
        [matchedInDels addObject:bestMatchedInfo];
}

- (void)checkForInDelMatch:(ED_Info*)edInfo andMatchedPos:(int)matchedPos andChunkNum:(int)cNum andChunkSize:(int)cSize {
    if (edInfo && edInfo.distance<=maxEditDist) {//Match Occurred
        BOOL alreadyRecorded = FALSE;
        //First matchPos needs to be set to the matchedPos w/o gaps, then use edInfo.position to account for gaps
        if (cNum == 0) {
            matchedPos = matchedPos + edInfo.position;
        }
        else if (cNum>0) {
            matchedPos = matchedPos-(cNum*cSize);
            matchedPos = matchedPos + (edInfo.position-maxEditDist);
            //                    Check To See If Match Has Already been recorded
            for (int i = 0; i<[matchedInDels count]; i++) {
                ED_Info *data = [matchedInDels objectAtIndex:i];
                if (data.position == matchedPos) //If pos is the same
                    alreadyRecorded = TRUE;
            }
        }
        
        if (!alreadyRecorded) {
            edInfo.position = matchedPos;
            edInfo.isRev = isRev;
            [matchedInDels addObject:edInfo];
        }
        else
            [edInfo freeUsedMemory];
    }
    else
        [edInfo freeUsedMemory];
}

- (int)findStartPosForChunkNum:(int)cNum andSizeOfChunks:(int)cSize andMatchedPos:(int)mPos {
    if (cNum == 0) {
        return mPos;
    }
    else {
        return mPos-(cNum*cSize);
    }
}
@end