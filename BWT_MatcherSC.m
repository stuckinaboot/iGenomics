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
@end
