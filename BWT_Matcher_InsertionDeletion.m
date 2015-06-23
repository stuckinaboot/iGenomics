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

- (NSMutableArray*)setUpWithNonSeededCharA:(char*)a andCharB:(char*)b andMaximumEditDist:(int)maxED andIsReverse:(BOOL)isR andExactMatcher:(BWT_MatcherSC *)exactMatcher {
    matchedInDels = [[NSMutableArray alloc] init];
    editDist = [[EditDistance alloc] init];
    isRev = isR;
    
    //printf("DK: creating newa\n");
    
    //    Add space prior to the chars in "a" and prior to the chars in "b"
    int alen = strlen(a);
    char *newa = calloc(alen+2, 1);
    memcpy(newa+1, a, alen);
    newa[0] = ' ';
    newa[alen+1] = '\0';
    
    /*int blen = strlen(b);
     char *newb = calloc(blen+1, 1);
     memcpy(newb+1, b, blen);
     newb[0] = ' ';*/
    
    maxEditDist = maxED;
    
    //printf("DK: calling findInDels\n");
    
    [self findInDelsNonSeededWithA:newa b:b usingExactMatcher:exactMatcher];
    
    //    Free memory---NEEDS TO BE DONE
    free(newa);
    
    return matchedInDels;
}

- (void)findInDelsNonSeededWithA:(char *)a b:(char *)b usingExactMatcher:(BWT_MatcherSC *)exactMatcher {
    int lenA = (int)strlen(a);
    int lenB = (int)strlen(b);
    
    ED_Info *match;
    
    char *shortA = malloc(kNonSeedShortSeqSize+1);
    for (int i = 0; i < lenA-kNonSeedShortSeqSize; i++) {
        strncpy(shortA, a+i, kNonSeedShortSeqSize);
        shortA[kNonSeedShortSeqSize] = '\0';
        
        //ASK MIKE: <<<What about forward/reverse???>>>
        
        NSMutableArray *exactMatches = (NSMutableArray*)[exactMatcher exactMatchForQuery:shortA andIsReverse:NO andForOnlyPos:NO];
        
        for (ED_Info *ed in exactMatches) {
            
//            ED_Info *edL = (ed.position > 0) ? [self nonSeededEDForFullA:a fullALen:lenA andB:b startPos:ed.position-1 andIsComputingForward:NO] : NULL;
//            ED_Info *edR = (ed.position < lenB) ? [self nonSeededEDForFullA:a fullALen:lenA andB:b startPos:ed.position+lenA andIsComputingForward:YES] : NULL;
            int bLoc = ed.position-i-maxEditDist;
            ED_Info *edFinal = [editDist editDistanceForInfoWithFullA:a rangeInA:NSMakeRange(0, lenA) andFullB:b rangeInB:NSMakeRange(bLoc, lenA+2*maxEditDist) andMaxED:maxEditDist];//[ED_Info mergedED_Infos:edL andED2:ed];
//            edFinal = [ED_Info mergedED_Infos:edFinal andED2:edR];
//            edFinal.position = ed.position-(int)strlen(edL.gappedA);
            
            
            edFinal.position = bLoc+edFinal.position;
            
            if (edFinal.distance <= maxEditDist) {
                match = edFinal;
                break;
            }
            else
                [edFinal freeUsedMemory];
        }
        if (match)
            break;
    }
    
    free(shortA);
    //Do something with the match if there was one
    if (match)
        [matchedInDels addObject:match];
}

- (ED_Info*)nonSeededEDForFullA:(char *)fullA fullALen:(int)lenA andB:(char*)b startPos:(int)startPos andIsComputingForward:(BOOL)forward {
    ED_Info *finalInfo;
    int lenB = strlen(b);
    
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
    int alen = strlen(a);
    char *newa = calloc(alen+2, 1);
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
    char *newa = calloc(alen+2, 1);
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
    int lenA = strlen(a)-1;
    Chunks *chunk = [chunkArray objectAtIndex:0];
    int chunkSize = chunk.range.length;
    ED_Info *edInfo = [[ED_Info alloc] init];

    
    //printf("DK: finding InDels C1\n");
    //    Finding InDels for Chunk 1
    for (int i = 0; i<chunk.matchedPositions.count; i++) {
        matchedPos = [[chunk.matchedPositions objectAtIndex:i] intValue];
        startPos = [self findStartPosForChunkNum:0 andSizeOfChunks:chunkSize andMatchedPos:matchedPos];
        if (startPos>=0) {
            edInfo = [editDist editDistanceForInfo:a andBFull:b andRangeOfActualB:NSMakeRange(startPos, lenA+maxEditDist) andChunkNum:0 andChunkSize:chunkSize andMaxED:maxEditDist andKillIfLargerThanDistance:kEditDistanceDoNotKill];
//            edInfo = [editDist editDistanceForInfo:a andB:substring(b, startPos, lenA+maxEditDist) andChunkNum:0 andChunkSize:chunkSize andMaxED:maxEditDist];//Not sure why +1 yet
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
                    edInfo = [editDist editDistanceForInfo:a andBFull:b andRangeOfActualB:NSMakeRange(startPos-maxEditDist, lenA+(maxEditDist*2)) andChunkNum:cNum andChunkSize:chunkSize andMaxED:maxEditDist andKillIfLargerThanDistance:kEditDistanceDoNotKill];
//                        edInfo = [editDist editDistanceForInfo:a andB:substring(b, startPos-maxEditDist, lenA+(maxEditDist*2)) andChunkNum:cNum andChunkSize:chunkSize andMaxED:maxEditDist];//Not sure why +1
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
                edInfo = [editDist editDistanceForInfo:a andBFull:b andRangeOfActualB:NSMakeRange(startPos-maxEditDist, lenA+maxEditDist) andChunkNum:[chunkArray count]-1 andChunkSize:chunkSize andMaxED:maxEditDist andKillIfLargerThanDistance:kEditDistanceDoNotKill];
//                    edInfo = [editDist editDistanceForInfo:a andB:substring(b, startPos-maxEditDist, lenA+maxEditDist) andChunkNum:[chunkArray count]-1 andChunkSize:chunkSize andMaxED:maxEditDist];//Not sure why +1
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