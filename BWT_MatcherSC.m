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
    int i = strlen(query)-1;
    char c = query[i];
    int startPos = [self charsBeforeChar:c];
    
    int whichChar = [BWT_MatcherSC whichChar:c inContainer:acgt]+1;
    int endPos = [self charsBeforeChar:acgt[whichChar]];
    
    if (whichChar == kACGTLen)
        endPos = fileStrLen;
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
            [posArray addObject:[self positionInBWTwithPosInBWM:startPos+l andIsReverse:isRev andForOnlyPos:forOnlyPos andForED:0 andForQuery:query]];
        }
        return posArray;
    }
    else
    {
        for (int l = 0; l<endPos-startPos; l++)
            [posArray addObject:[NSNumber numberWithInteger:((ED_Info*)[self positionInBWTwithPosInBWM:startPos+l andIsReverse:isRev andForOnlyPos:forOnlyPos andForED:0 andForQuery:query]).position]];
        return posArray;
//        return (NSArray*)[[NSMutableArray alloc] initWithArray:[self positionInBWTwithPosInBWMForArr:posArray andIsReverse:isRev andForOnlyPos:forOnlyPos andForED:0 andForQuery:query]];
    }
}

- (NSArray*)exactMatchForChunk:(Chunks*)chunk andIsReverse:(BOOL)isRev andForOnlyPos:(BOOL)forOnlyPos {
    
    int i = chunk.range.length-1;
    char c = chunk.str[chunk.range.location+i];
    int startPos = [self charsBeforeChar:c];
    
    int whichChar = [BWT_MatcherSC whichChar:c inContainer:acgt]+1;
    int endPos = [self charsBeforeChar:acgt[whichChar]];
    
    if (whichChar == kACGTLen)
        endPos = fileStrLen;
    i--;
    while (startPos<endPos && i >= 0) {
        c = chunk.str[chunk.range.location+i];
        startPos = [self LFC:startPos andChar:c]-1;
        endPos = [self LFC:endPos andChar:c]-1;
        i--;
    }
    
    NSMutableArray *posArray = [[NSMutableArray alloc] init];
    for (int l = 0; l<endPos-startPos; l++)
        [posArray addObject:[NSNumber numberWithInteger:[self positionOfChunkInBWTwithPosInBWM:startPos+l andIsReverse:isRev andForOnlyPos:forOnlyPos andForED:0]]];
    return posArray;
}

- (BOOL)isNotDuplicateAlignment:(NSArray *)subsArray andChunkNum:(int)chunkNum {//TRUE IS NO DUPLICATE
    
    if (chunkNum == 0) //No Duplicates If it is first chunk (nothing come before it)
        return TRUE;
    int s = [subsArray count];
    for (int i = 0; i<s-(s-chunkNum); i++) {
        if ([[subsArray objectAtIndex:i] intValue] == 0)
            return FALSE;
    }
    
    return TRUE;
}

- (int)positionOfChunkInBWTwithPosInBWM:(int)position andIsReverse:(BOOL)isRev andForOnlyPos:(BOOL)forOnlyPos andForED:(int)ed {
    int i;//index
    int pos = fileStrLen-1;
    int occurence = 1;//1 = 1st, etc.
    char lastChar = refStrBWT[0];
    
    
    i = [self getIndexOfNth:occurence OccurenceOfChar:lastChar inChar:firstCol];
    
    while (pos>=0) {
        pos--;
        lastChar = refStrBWT[i];
        
        occurence = [self whichOccurenceOfChar:lastChar inBWT:refStrBWT atPos:i];
        i = [self getIndexOfNth:occurence OccurenceOfChar:lastChar inChar:firstCol];
        
        if (position == i) {
            return pos-1;
        }
    }
    return pos-1;
}

- (ED_Info*)positionInBWTwithPosInBWM:(int)position andIsReverse:(BOOL)isRev andForOnlyPos:(BOOL)forOnlyPos andForED:(int)ed andForQuery:(char *)query {
    
    int i;//index
    int pos = fileStrLen-1;
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
    int pos = fileStrLen-1;
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
    for (int i = 0; i<kACGTLen+2; i++) {
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

/*
- (int)whichOccurenceOfChar:(char)c inBWT:(char*)container atPos:(int)pos {
    int topMultiple = 0;
     for (int i = 0; i<pos; i++) {
     if (topMultiple<pos)
     topMultiple+=kMultipleToCountAt;
     if (topMultiple>pos) {
     topMultiple-=kMultipleToCountAt;
     break;
     }
     if (topMultiple == pos)
     break;
     }
    int whichChar = [BWT_MatcherSC whichChar:c inContainer:acgt];
    int occurences = 0;
    int val = ((int)pos/kMultipleToCountAt)*kMultipleToCountAt;
    for (int i = 0; i<(int)val/kMultipleToCountAt; i++)
        occurences+=acgtOccurences[i][whichChar];
    if (val<pos) {
        for (int i = val; i<pos; i++) {
            if (container[i] == acgt[whichChar])
                occurences++;
        }
    }
    occurences++;
    
//    printf("%i, %c, %i\n",occurences,c,pos);
    
    return occurences;
}
*/

- (int)whichOccurenceOfChar:(char)c inBWT:(char*)bwt atPos:(int)pos {
    int whichChar = [BWT_MatcherSC whichChar:c inContainer:acgt];
    int occurences = 0;
    if (pos >= kMultipleToCountAt-1) {
        int index = ((int)pos/kMultipleToCountAt)-1;
        occurences = acgtOccurences[index][whichChar];
        int startPos = (index+1)*kMultipleToCountAt;
        for (int i = startPos; i<pos; i++)
            if (c == refStrBWT[i])
                occurences++;
//        int acgtOccurencesIdx = (int)floor((pos-1)/kMultipleToCountAt);
//        int val = acgtOccurencesIdx*kMultipleToCountAt;
//        occurences = acgtOccurences[acgtOccurencesIdx][whichChar];
        
//        for (int i = val+1; i < pos-1; i++)
//            if (bwt[i] == acgt[whichChar])
//                occurences++;
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
     int pos = fileStrLen-1;
     int occurence = 1;//1 = 1st, etc.
     char *unraveledChar = calloc(fileStrLen, 1);
     int unravCharSize = 0;
     char lastChar = lastColumn[i];
     
     unraveledChar[pos] = lastChar;
     
     i = [self getIndexOfNth:occurence OccurenceOfChar:lastChar inChar:firstColumn];
     
     while (/*strlen(unraveledChar)*/unravCharSize<fileStrLen) {
         pos--;
         //Add lastChar to beginning of unraveledChar
         lastChar = lastColumn[i];
         
         unraveledChar[pos] = lastChar;
         
         occurence = [self whichOccurenceOfChar:lastChar inBWT:lastColumn atPos:i];
         i = [self getIndexOfNth:occurence OccurenceOfChar:lastChar inChar:firstColumn];
         unravCharSize++;
     }
     
     strcpy(unraveledChar, unraveledChar+1);
     return unraveledChar;
 }

- (void)timerPrint {
    [timer printTotalRecTime];
}
@end
