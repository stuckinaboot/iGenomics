//
//  BWT_MatcherSC.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 4/20/13.
//
//

#import "BWT_MatcherSC.h"

@implementation BWT_MatcherSC

- (NSArray*)exactMatchForQuery:(char*)query andIsReverse:(BOOL)isRev andForOnlyPos:(BOOL)forOnlyPos {
    int queryLen = strlen(query);
    int i = queryLen-1;
    char c = query[i];
    int startPos = [self charsBeforeChar:c];
    
    int whichChar = [BWT_MatcherSC whichChar:c inContainer:acgt]+1;
    int endPos = [self charsBeforeChar:acgt[whichChar]];
    
    if (whichChar == kACGTLen)
        endPos = dgenomeLen;
    i--;
    while (startPos<endPos && i >= 0) {
        c = query[i];
        startPos = [self LFC:startPos andChar:c]-1;
        endPos = [self LFC:endPos andChar:c]-1;
        i--;
    }
    
    NSMutableArray *posArray = [[NSMutableArray alloc] init];
    
    if (!forOnlyPos)
    {
        for (int l = 0; l<endPos-startPos; l++) {
            [posArray addObject:[[ED_Info alloc] initWithPos:benchmarkPositions[l+startPos] editDistance:0 gappedAStr:query gappedBStr:kNoGappedBChar isIns:NO isReverse:isRev]];
        }
        return posArray;
    }
    else
    {
        for (int l = 0; l<endPos-startPos; l++)
            [posArray addObject:[NSNumber numberWithInteger:((ED_Info*)[self positionInBWTwithPosInBWM:startPos+l andIsReverse:isRev andForOnlyPos:forOnlyPos andForED:0 andForQuery:query]).position]];
        return posArray;
    }
}

- (NSArray*)exactMatchForChunk:(Chunks*)chunk andIsReverse:(BOOL)isRev andForOnlyPos:(BOOL)forOnlyPos {
    
    int i = chunk.range.length-1;
    char c = chunk.str[chunk.range.location+i];
    int startPos = [self charsBeforeChar:c];
    
    int whichChar = [BWT_MatcherSC whichChar:c inContainer:acgt]+1;
    int endPos = [self charsBeforeChar:acgt[whichChar]];
    
    if (whichChar == kACGTLen)
        endPos = dgenomeLen;
    i--;
    while (startPos<endPos && i >= 0) {
        c = chunk.str[chunk.range.location+i];
        startPos = [self LFC:startPos andChar:c]-1;
        endPos = [self LFC:endPos andChar:c]-1;
        i--;
    }
    
    NSMutableArray *posArray = [[NSMutableArray alloc] init];
//    for (int l = 0; l<endPos-startPos; l++)
//        [posArray addObject:[NSNumber numberWithInteger:[self positionOfChunkInBWTwithPosInBWM:startPos+l andIsReverse:isRev andForOnlyPos:forOnlyPos andForED:0]]];
    for (int l = 0; l<endPos-startPos; l++)
        [posArray addObject:[NSNumber numberWithInteger:benchmarkPositions[l+startPos]]];
    return posArray;
}

- (BOOL)isNotDuplicateAlignment:(ED_Info *)info inArr:(NSMutableArray *)posArr {//TRUE IS NO DUPLICATE
    
    for (ED_Info *obj in posArr)
        if ([ED_Info areEqualEditDistance1:obj andEditDistance2:info])
            return FALSE;
    
    return TRUE;
}

- (int)positionOfChunkInBWTwithPosInBWM:(int)position andIsReverse:(BOOL)isRev andForOnlyPos:(BOOL)forOnlyPos andForED:(int)ed {
    int i;//index
    int pos = dgenomeLen-1;
    int occurence = 1;//1 = 1st, etc.
    char lastChar = refStrBWT[0];
    
    
    i = [self getIndexOfNth:occurence OccurenceOfChar:lastChar inChar:firstCol];
    
    while (pos>=0) {
        pos--;
        lastChar = refStrBWT[i];
        
        occurence = [self whichOccurenceOfChar:lastChar inBWT:refStrBWT atPos:i];
        i = [self getIndexOfNth:occurence OccurenceOfChar:lastChar inChar:firstCol];
        
        if (position == i)
            return pos-1;
    }
    return pos-1;
}

- (ED_Info*)positionInBWTwithPosInBWM:(int)position andIsReverse:(BOOL)isRev andForOnlyPos:(BOOL)forOnlyPos andForED:(int)ed andForQuery:(char *)query {
    
    int i;//index
    int pos = dgenomeLen-1;
    int occurence = 1;//1 = 1st, etc.
    char lastChar = refStrBWT[0];
    
    
    i = [self getIndexOfNth:occurence OccurenceOfChar:lastChar inChar:firstCol];
    
    while (pos>=0) {
        pos--;
        lastChar = refStrBWT[i];
        
        occurence = [self whichOccurenceOfChar:lastChar inBWT:refStrBWT atPos:i];
        
        i = [self getIndexOfNth:occurence OccurenceOfChar:lastChar inChar:firstCol];
        
        if (position == i)
            return [[ED_Info alloc] initWithPos:pos-1 editDistance:ed gappedAStr:query gappedBStr:kNoGappedBChar isIns:NO isReverse:isRev];
    }
    return [[ED_Info alloc] initWithPos:pos-1 editDistance:ed gappedAStr:query gappedBStr:kNoGappedBChar isIns:NO isReverse:isRev];
}

- (NSArray*)positionInBWTwithPosInBWMForArr:(NSArray*)posArray andIsReverse:(BOOL)isRev andForOnlyPos:(BOOL)forOnlyPos andForED:(int)ed andForQuery:(char*)query {
    
    NSMutableArray *positionsInBWTArray = [[NSMutableArray alloc] init];
    
    int i;//index
    int pos = dgenomeLen-1;
    int occurence = 1;//1 = 1st, etc.
    char lastChar = refStrBWT[0];
    
    
    i = [self getIndexOfNth:occurence OccurenceOfChar:lastChar inChar:firstCol];
    
    for (int l = 0; l<[posArray count]; l++) {
        if ([[posArray objectAtIndex:l] intValue] == i)
            [positionsInBWTArray addObject:[NSNumber numberWithInt:pos-1]];
    }
    
    while (pos>=0) {
        pos--;
        lastChar = refStrBWT[i];
        
        occurence = [self whichOccurenceOfChar:lastChar inBWT:refStrBWT atPos:i];
        i = [self getIndexOfNth:occurence OccurenceOfChar:lastChar inChar:firstCol];
        
        if ([posArray count] == [positionsInBWTArray count])
            break;
        for (int l = 0; l<[posArray count]; l++) {
            if ([[posArray objectAtIndex:l] intValue] == i) {
                if (!forOnlyPos)
                    [positionsInBWTArray addObject:[[ED_Info alloc] initWithPos:pos-1 editDistance:ed gappedAStr:query gappedBStr:kNoGappedBChar isIns:NO isReverse:isRev]];
                else
                    [positionsInBWTArray addObject:[NSNumber numberWithInt:pos-1]];
            }
        }
    }
    return (NSArray*)positionsInBWTArray;
}
- (int)charsBeforeChar:(char)c {
    int which = [BWT_MatcherSC whichChar:c inContainer:acgt];
    int num = 0;
    for (int i = 0; i<which; i++)
        num+=acgtTotalOccs[i];
    
    return num+1;
}

+ (int)whichChar:(char)c inContainer:(char*)container {
    int which = -1;//Not ACGT
    for (int i = 0; i<kACGTwithInDelsLen; i++) {
        if (kACGTwithInDels[i] == c) {
            which = i;
            break;
        }
    }
    return which;
}

- (int)LFC:(int)r andChar:(char)c {
    int occ = [self whichOccurenceOfChar:c inBWT:refStrBWT atPos:r];
    return [self charsBeforeChar:c]+occ;
}

- (int)getIndexOfNth:(int)n OccurenceOfChar:(char)c inChar:(char*)container {
    int loc = 1;
    int whichChar = [BWT_MatcherSC whichChar:c inContainer:acgt];
    for (int i = 0; i<whichChar; i++)
        loc+=acgtTotalOccs[i];
    loc+=n;
    return loc-1;
    
}

- (int)whichOccurenceOfChar:(char)c inBWT:(char*)bwt atPos:(int)pos {
    int whichChar = [BWT_MatcherSC whichChar:c inContainer:acgt];
    int occurences = 0;
    if (pos >= kMultipleToCountAt) {//pos needs to be at a min kMultipleToCountAt so when they are divided it would be 1
        int index = ((int)pos/kMultipleToCountAt)-1;//Index in the acgtOccurences array, is - 1 because should be getting the index before the character and all arrays start at index 0
        occurences = acgtOccurences[index][whichChar];
        int startPos = (index+1)*kMultipleToCountAt;//The appropriate way to get the startPos
        for (int i = startPos; i < pos; i++)
            if (c == refStrBWT[i])
                occurences++;//Occurences adds 1 for each occurence of that character btw the last benchmark and the position
    }
    else
        for (int i = 0; i<pos; i++)
            if (c == refStrBWT[i])
                occurences++;
    //This is because we know what character is at pos and that it will occur
    occurences++;
//    printf("%i, %c, %i\n",occur ences,c,pos);
    return occurences;
}

#pragma UNRAVEL

 - (char*)unravelCharWithLastColumn:(char*)lastColumn firstColumn:(char*)firstColumn {
 
     int i = 0;//index
     int pos = dgenomeLen-2;//-2 because dollar sign is added afterwards
     int occurence = 1;//1 = 1st, etc.
     char *unraveledChar = calloc(dgenomeLen+1, 1);
     int unravCharSize = 0;
     char lastChar = lastColumn[i];
     
     unraveledChar[pos] = lastChar;
     
     i = [self getIndexOfNth:occurence OccurenceOfChar:lastChar inChar:firstColumn];
     
     while (/*strlen(unraveledChar)*/unravCharSize<dgenomeLen && pos > 0) {
         pos--;
         //Add lastChar to beginning of unraveledChar
         lastChar = lastColumn[i];
         
         occurence = [self whichOccurenceOfChar:lastChar inBWT:lastColumn atPos:i];
         i = [self getIndexOfNth:occurence OccurenceOfChar:lastChar inChar:firstColumn];
         unravCharSize++;
     }
     unraveledChar[dgenomeLen-1] = '$';
     unraveledChar[dgenomeLen] = '\0';
     return unraveledChar;
 }

- (void)timerPrint {
    [timer printTotalRecTime];
}

#pragma Clipping

+ (ED_Info*)infoByAdjustingForSegmentDividerLettersForInfo:(ED_Info*)info cumSepSegLens:(NSMutableArray*)cumulativeSeparateGenomeLens {
    int ogPos = info.position;
    //Trim off all Bs
    int numOfBsInStart = 0, numOfBsInEnd = 0;
    int bLen = (int)strlen(info.gappedB);
    int originalReadLen = bLen; //NOTE: This is essentially an upper bound on the read length, which is fine because the read length is checked against the exact min read len when processing the best match (in a higher level function) - would rather not spend extra time here getting the exact min read len
    
    for (int i = 0; i < ceilf(bLen / 2.0f); i++) {
        BOOL bRecorded = false;
        if (info.gappedB[i] == kOriginalStrSegmentLetterDivider) {
            numOfBsInStart++;
            bRecorded = TRUE;
        }

        if (info.gappedB[bLen - i - 1] == kOriginalStrSegmentLetterDivider) {
            numOfBsInEnd++;
            bRecorded = TRUE;
        }
        if (!bRecorded)
            break;
    }
    
    if (numOfBsInStart > 0 || numOfBsInEnd > 0) {
        char *newa = malloc(bLen - numOfBsInEnd - numOfBsInStart + 1);
        newa[bLen - numOfBsInEnd - numOfBsInStart] = '\0';
        char *newb = malloc(bLen - numOfBsInEnd - numOfBsInStart + 1);
        newb[bLen - numOfBsInEnd - numOfBsInStart] = '\0';
        
        for (int i = numOfBsInStart; i < bLen - numOfBsInEnd; i++) {
            newa[i - numOfBsInStart] = info.gappedA[i];
            newb[i - numOfBsInStart] = info.gappedB[i];
        }
        
        free(info.gappedA);
        free(info.gappedB);
        
        info.gappedA = newa;
        info.gappedB = newb;
        info.position += numOfBsInStart;
        info.distance = info.distance - numOfBsInStart - numOfBsInEnd;
        bLen = (int)strlen(info.gappedB);
    }
    
//    Soft-Clip like a boss
    int numOfCharsToClip = 0;
    if (bLen >= kSoftClippingCharsInARowThresholdToFinish) {
        int pos = 0;
        BOOL nInARowExactMatch = FALSE;
        int numOfIns = 0;
        int edToSub = 0;
        while (!nInARowExactMatch) {
            nInARowExactMatch = TRUE;
            for (int i = pos; i < pos + kSoftClippingCharsInARowThresholdToFinish; i++) {
                if (info.gappedB[i] != info.gappedA[i]) {
                    nInARowExactMatch = FALSE;
                    numOfCharsToClip++;
                    break;
                }
            }
            if (info.gappedB[pos] == kDelMarker)
                numOfIns++;
            if (info.gappedB[pos] != info.gappedA[pos])
                edToSub++;
            if (!nInARowExactMatch)
                pos++;
        }
        
        int endPos = bLen - 1;
        nInARowExactMatch = FALSE;
        while (!nInARowExactMatch) {
            nInARowExactMatch = TRUE;
            for (int i = endPos; i > endPos - kSoftClippingCharsInARowThresholdToFinish; i--) {
                if (info.gappedB[i] != info.gappedA[i]) {
                    nInARowExactMatch = FALSE;
                    numOfCharsToClip++;
                    break;
                }
            }
            if (info.gappedB[endPos] != info.gappedA[endPos])
                edToSub++;
            if (!nInARowExactMatch)
                endPos--;
        }
        
        if (info.distance < 0) {
            NSLog(@"DISTANCE COMPUTATION WENT NEGATIVE");
            return NULL;
        }
        
        int minReadLen = kMinReadLengthPercentOfReadThatMustRemain * originalReadLen;
        if (endPos - pos + 1 < minReadLen) {
            return NULL;
        }
        
        //Clip from pos to the endPos
        char *newa = malloc(endPos-pos + 2);
        char *newb = malloc(endPos-pos + 2);
        for (int i = pos; i <= endPos; i++) {
            newa[i - pos] = info.gappedA[i];
            newb[i - pos] = info.gappedB[i];
        }
        
        newa[endPos - pos + 1] = '\0';
        newb[endPos - pos + 1] = '\0';
        free(info.gappedA);
        free(info.gappedB);
        info.gappedA = newa;
        info.gappedB = newb;
        info.position += pos - numOfIns;
        info.distance -= edToSub;//= info.distance - pos - (bLen - endPos + 1);
    }
    
    //First determine which segment the info is in while accounting for Bs
    int pos;
    for (int i = 0; i < [cumulativeSeparateGenomeLens count]; i++) {
        int val = [[cumulativeSeparateGenomeLens objectAtIndex:i] intValue];
        pos = (i + 1) * kOriginalStrSegmentLetterDividersLen + val;
        if (info.position < pos) {
            info.position -= (i + 1) * kOriginalStrSegmentLetterDividersLen;
            break;
        }
    }
    
    return info;
}

+ (ED_Info*)infoByUnjustingForSegmentDividerLettersForInfo:(ED_Info*)info cumSepSegLens:(NSMutableArray*)cumulativeSeparateGenomeLens {
//    return info;
    //First determine which segment the info is in while accounting for Bs
    for (int i = 0; i < [cumulativeSeparateGenomeLens count]; i++) {
        int val = [[cumulativeSeparateGenomeLens objectAtIndex:i] intValue];
        if (info.position < val) {
            info.position += (i + 1) * kOriginalStrSegmentLetterDividersLen;
            break;
        }
    }
    return info;
}

+ (NSMutableArray*)arrayByUnjustingForsegmentDividerLettersForArr:(NSMutableArray*)arr cumSepSegLens:(NSMutableArray*)lens {
    NSMutableArray *newArr = [NSMutableArray arrayWithArray:arr];
    for (int i = 0; i < [newArr count]; i++) {
        ED_Info *temp = [newArr objectAtIndex:i];
        temp = [BWT_MatcherSC infoByUnjustingForSegmentDividerLettersForInfo:temp cumSepSegLens:lens];
        [newArr setObject:temp atIndexedSubscript:i];
    }
    return newArr;
}

+ (NSArray*)positionsArrayByUnjustingForsegmentDividerLettersForArr:(NSArray*)arr cumSepSegLens:(NSMutableArray*)lens {
    ED_Info *temp = [[ED_Info alloc] init];
    NSMutableArray *newArr = [NSMutableArray arrayWithArray:arr];
    for (int i = 0; i < [newArr count]; i++) {
        temp.position = [[arr objectAtIndex:i] intValue];
        temp = [BWT_MatcherSC infoByUnjustingForSegmentDividerLettersForInfo:temp cumSepSegLens:lens];
        [newArr setObject:[NSNumber numberWithInt:temp.position] atIndexedSubscript:i];
    }
    return newArr;
}

+ (ED_Info*)updatedInfoCorrectedForExtendingOverSegmentStartsAndEnds:(ED_Info *)info forNumOfSubs:(int)subs withCumSepGenomeLens:(NSArray*)cumulativeSeparateGenomeLens maxErrorRate:(float)errorRate originalReadLen:(int)originalReadLen {
    return info;
    int gappedALen = (int)strlen(info.gappedA);
    
    int index = [self indexInCumSepGenomeLensArrOfClosestSegmentEndingForEDInfo:info withCumSepGenomeLens:cumulativeSeparateGenomeLens];
    
    int closeEnding = [[cumulativeSeparateGenomeLens objectAtIndex:index] intValue];
    
    BOOL shouldTrim = (closeEnding - (info.position + gappedALen - info.numOfInsertions) < 0);
    
    BOOL trimEnding = NO;
    BOOL trimBeginning = NO;
    
    if (shouldTrim) {
        if (abs(closeEnding - (info.position + gappedALen-info.numOfInsertions)) < closeEnding - info.position)
            trimEnding = TRUE;
        else
            trimBeginning = TRUE;
    }
    else
        return info;
    //    BOOL trimEnding = (closeEnding - (info.position + gappedALen) <= 0);
    //    BOOL trimBeginning = trimEnding && (closeEnding - info.position > 0 && (closeEnding - (info.position + gappedALen) <= 0));
    
    int newLen = 0;
    if (trimBeginning)
        newLen = originalReadLen-(closeEnding-info.position);
    else if (trimEnding)
        newLen = originalReadLen-(info.position+originalReadLen-closeEnding);
    
    int maxSubsNew = newLen * errorRate;
    
    if (index < 0)
        return info;
    
    int numOfInsertionsInEnding = (trimEnding) ? [self numOfInsertionsPastSegmentEndingForEDInfo:info andIndexInCumSepGenomesOfClosestSegmentEndingPos:index withCumSepGenomeLens:cumulativeSeparateGenomeLens] : 0;
    
    int charsToTrimEnd = (trimEnding) ? [self numOfCharsPastSegmentEndingForEDInfo:info andReadLen:gappedALen andIndexInCumSepGenomesOfClosestSegmentEndingPos:index withCumSepGenomeLens:cumulativeSeparateGenomeLens]+numOfInsertionsInEnding : 0;
    
    int numOfInsertionsInBeginning = (trimBeginning) ? [self numOfInsertionsBeforeSegmentEndingForEDInfo:info andIndexInCumSepGenomesOfClosestSegmentEndingPos:index withCumSepGenomeLens:cumulativeSeparateGenomeLens] : 0;
    
    int charsToTrimBeginning = (trimBeginning) ? [self numOfCharsBeforeSegmentEndingForEDInfo:info andReadLen:gappedALen andIndexInCumSepGenomesOfClosestSegmentEndingPos:index andNumOfInsertionsBeforeEnding:numOfInsertionsInBeginning withCumSepGenomeLens:cumulativeSeparateGenomeLens] : 0;
    
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
    newInfo.numOfInsertions = info.numOfInsertions-numOfInsertionsInBeginning-numOfInsertionsInEnding;
    
    int numOfCharsToTrimFromBeginningFromED = 0;
    
    if (noGappedB)
        numOfCharsToTrimFromBeginningFromED = charsToTrimBeginning;
    else {
        for (int i = 0; i < charsToTrimBeginning; i++)
            if (info.gappedA[i] != info.gappedB[i])
                numOfCharsToTrimFromBeginningFromED++;
    }
    
    int numOfCharsToTrimFromEndFromED = 0;
    
    if (noGappedB)
        numOfCharsToTrimFromEndFromED = charsToTrimEnd;
    else {
        for (int i = gappedALen-info.numOfInsertions-charsToTrimEnd; i < (gappedALen-info.numOfInsertions-charsToTrimEnd-1)+charsToTrimEnd+1; i++)
            if (info.gappedA[i] != info.gappedB[i])
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
    
    newInfo.distance -= numOfCharsToTrimFromBeginningFromED;
    newInfo.position += amtOfCharsToAddToPosition;
    
    newInfo.distance -= numOfCharsToTrimFromEndFromED;
    
    if (!shouldTrim && newInfo.distance > maxSubsNew)
        return NULL;
    
    [info freeUsedMemory];//Doesn't free readName, so the above code where I set all of newInfo. should be good
    
    if (shouldTrim)
        return [BWT_MatcherSC updatedInfoCorrectedForExtendingOverSegmentStartsAndEnds:newInfo forNumOfSubs:subs withCumSepGenomeLens:cumulativeSeparateGenomeLens maxErrorRate:errorRate originalReadLen:originalReadLen];
    return newInfo;
}

+ (int)indexInCumSepGenomeLensArrOfClosestSegmentEndingForEDInfo:(ED_Info*)info withCumSepGenomeLens:(NSArray*)cumulativeSeparateGenomeLens {
    for (int i = 0; i < [cumulativeSeparateGenomeLens count]; i++) {
        int v = [[cumulativeSeparateGenomeLens objectAtIndex:i] intValue];
        if (info.position < v) {
            return i;
        }
    }
    
    return -1;
}

+ (int)numOfCharsPastSegmentEndingForEDInfo:(ED_Info *)info andReadLen:(int)readL andIndexInCumSepGenomesOfClosestSegmentEndingPos:(int)index withCumSepGenomeLens:(NSArray*)cumulativeSeparateGenomeLens {
    
    int closestLen = [[cumulativeSeparateGenomeLens objectAtIndex:index] intValue];
    
    if (info.position - info.numOfInsertions + readL-1 < closestLen)
        return 0;
    
    int charsToTrim = info.position - info.numOfInsertions +readL-closestLen;
    
    return charsToTrim;
}

+ (int)numOfCharsBeforeSegmentEndingForEDInfo:(ED_Info *)info andReadLen:(int)readL andIndexInCumSepGenomesOfClosestSegmentEndingPos:(int)index andNumOfInsertionsBeforeEnding:(int)numOfInsertions withCumSepGenomeLens:(NSArray*)cumulativeSeparateGenomeLens {
    
    int closestBeginning = [[cumulativeSeparateGenomeLens objectAtIndex:index] intValue];
    
    //    int k = closestBeginning+numOfInsertions;
    
    int k = closestBeginning+numOfInsertions;
    
    return k-info.position;
}

+ (int)numOfInsertionsBeforeSegmentEndingForEDInfo:(ED_Info*)info andIndexInCumSepGenomesOfClosestSegmentEndingPos:(int)index withCumSepGenomeLens:(NSArray*)cumulativeSeparateGenomeLens {
    int k = 0;
    int closestEnding = [[cumulativeSeparateGenomeLens objectAtIndex:index] intValue];
    for (int i = info.position; i <= closestEnding; i++)
        if (info.gappedB[i-info.position] == kDelMarker) {
            k++;
            closestEnding++;
        }
    return k;
}

+ (int)numOfInsertionsPastSegmentEndingForEDInfo:(ED_Info *)info andIndexInCumSepGenomesOfClosestSegmentEndingPos:(int)index withCumSepGenomeLens:(NSArray*)cumulativeSeparateGenomeLens {
    //    int k = 0;
    int closestEnding = [[cumulativeSeparateGenomeLens objectAtIndex:index] intValue];
    //    int len = (int)strlen(info.gappedA)-info.numOfInsertions;
    //    for (int i = closestEnding-info.numOfInsertions; i < info.position+len; i++) {
    //        if (info.gappedB[i-info.position] == kDelMarker) {
    //            k++;
    //            len++;
    //        }
    //    }
    //    return k;
    int numOfInsBeforeEnding = 0;
    int k = 0;
    int len = (int)strlen(info.gappedA);
    for (int i = len-1; i >= 0; i--) {
        if (info.gappedB[i] == kDelMarker) {
            k++;
        }
        if (info.position+i-(info.numOfInsertions-k) == closestEnding) {
            numOfInsBeforeEnding = k;
        }
    }
    return numOfInsBeforeEnding;
}

@end
