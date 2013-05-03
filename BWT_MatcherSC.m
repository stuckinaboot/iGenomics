//
//  BWT_MatcherSC.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 4/20/13.
//
//

#import "BWT_MatcherSC.h"

 int fileStrLen;
 char *originalStr;
 char *refStrBWT;
 char *acgt;
 int acgtOccurences[kMaxBytesForIndexer][kACGTLen];//Occurences for up to each multiple to count at
 int acgtTotalOccs[kACGTLen];
int kMultipleToCountAt;

@implementation BWT_MatcherSC

- (NSArray*)exactMatchForQuery:(char*)query withLastCol:(char*)lastCol andFirstCol:(char*)firstCol andIsReverse:(BOOL)isRev andForOnlyPos:(BOOL)forOnlyPos {
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
        startPos = [self LFC:startPos andChar:c withLastCol:lastCol]-1;
        endPos = [self LFC:endPos andChar:c withLastCol:lastCol]-1;
        i--;
    }
    
    NSMutableArray *posArray = [[NSMutableArray alloc] init];
    
    for (int l = 0; l<endPos-startPos; l++)
        [posArray addObject:[NSNumber numberWithInt:startPos+l]];
    
    return (NSArray*)[[NSMutableArray alloc] initWithArray:[self positionInBWTwithPosInBWM:posArray andFirstCol:firstCol andLastCol:lastCol andIsReverse:isRev andForOnlyPos:forOnlyPos]];
}

- (BOOL)isNotDuplicateAlignment:(NSArray *)subsArray andChunkNum:(int)chunkNum {//TRUE IS NO DUPLICATE
    
    if (chunkNum == 0) //No Duplicates If it is first chunk (nothing come before it)
        return TRUE;
    
    for (int i = 0; i<[subsArray count]-([subsArray count]-chunkNum); i++) {
        if ([[subsArray objectAtIndex:i] intValue] == 0)
            return FALSE;
    }
    
    return TRUE;
}

- (NSArray*)positionInBWTwithPosInBWM:(NSArray*)posArray andFirstCol:(char *)firstColumn andLastCol:(char *)lastColumn andIsReverse:(BOOL)isRev andForOnlyPos:(BOOL)forOnlyPos {
    
    NSMutableArray *positionsInBWTArray = [[NSMutableArray alloc] init];
    
    int i;//index
    int pos = fileStrLen-1;
    int occurence = 1;//1 = 1st, etc.
    char lastChar = lastColumn[0];
    
    
    i = [self getIndexOfNth:occurence OccurenceOfChar:lastChar inChar:firstColumn];
    
    for (int l = 0; l<[posArray count]; l++) {
        if ([[posArray objectAtIndex:l] intValue] == i)
            [positionsInBWTArray addObject:[NSNumber numberWithInt:pos-1]];
    }
    
    while (pos>=0) {
        pos--;
        lastChar = lastColumn[i];
        
        occurence = [self whichOccurenceOfChar:lastChar inChar:lastColumn atPos:i];
        i = [self getIndexOfNth:occurence OccurenceOfChar:lastChar inChar:firstColumn];
        
        if ([posArray count] == [positionsInBWTArray count])
            break;
        for (int l = 0; l<[posArray count]; l++) {
            if ([[posArray objectAtIndex:l] intValue] == i) {
                if (!forOnlyPos)
                    [positionsInBWTArray addObject:[[MatchedReadData alloc] initWithPos:pos-1 isReverse:isRev andEDInfo:NULL]];
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
    for (int i = 0; i<kACGTLen; i++) {
        if (acgt[i] == c) {
            which = i;
            break;
        }
    }
    return which;
}

- (int)LFC:(int)r andChar:(char)c withLastCol:(char*)lastCol {
    int occ = [self whichOccurenceOfChar:c inChar:lastCol atPos:r];
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

- (int)whichOccurenceOfChar:(char)c inChar:(char*)container atPos:(int)pos {
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
    for (int i = 0; i<(float)topMultiple/kMultipleToCountAt; i++)
        occurences+=acgtOccurences[i][whichChar];
    if (topMultiple<pos) {
        for (int i = topMultiple; i<pos; i++) {
            if (container[i] == acgt[whichChar])
                occurences++;
        }
    }
    occurences++;
    return occurences;
}

#pragma UNRAVEL

 - (char*)unravelCharWithLastColumn:(char*)lastColumn firstColumn:(char*)firstColumn {
 
     int i = 0;//index
     int pos = fileStrLen-1;
     int occurence = 1;//1 = 1st, etc.
     char *unraveledChar = calloc(fileStrLen, 1);
     char lastChar = lastColumn[i];
     
     unraveledChar[pos] = lastChar;
     
     i = [self getIndexOfNth:occurence OccurenceOfChar:lastChar inChar:firstColumn];
     
     while (strlen(unraveledChar)<fileStrLen) {
         pos--;
         //Add lastChar to beginning of unraveledChar
         lastChar = lastColumn[i];
         
         unraveledChar[pos] = lastChar;
         
         occurence = [self whichOccurenceOfChar:lastChar inChar:lastColumn atPos:i];
         i = [self getIndexOfNth:occurence OccurenceOfChar:lastChar inChar:firstColumn];
     }
     
     strcpy(unraveledChar, unraveledChar+1);
     return unraveledChar;
 }
@end
