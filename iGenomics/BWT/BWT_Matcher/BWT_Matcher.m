//
//  BWT_Matcher.m
//  LabProject7
//
//  Created by Stuckinaboot Inc. on 9/15/12.
//
//

#import "BWT_Matcher.h"

@implementation BWT_Matcher

- (void)setUpReedsFile:(NSString*)fileName fileExt:(NSString*)fileExt refStrBWT:(char*)bwt andMaxSubs:(int)subs {
    NSString* reedsString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:fileExt] encoding:NSUTF8StringEncoding error:nil];
    reedsArray = [[NSArray alloc] initWithArray:[reedsString componentsSeparatedByString:kReedsArraySeperationStr]];
    
    refStrBWT = strdup(bwt);
    
    maxSubs = subs;
    
    fileStrLen = strlen(refStrBWT);
    
    [self setUpNumberOfOccurencesArray];
    
    char *lastCol = refStrBWT;
    char *firstCol = calloc(fileStrLen, 1);
    
    firstCol[0] = '$';
    
    int pos = 1;
    for (int x = 0; x<kACGTLen; x++) {
        for (int i = 0; i<acgtTotalOccs[x]; i++) {
            firstCol[pos] = acgt[x];
            pos++;
        }
    }
    
    for (int i = 0; i<kACGTLen; i++) {
        for (int x = 0; x<fileStrLen; x++) {
            posOccArray[i][x] = 0;
        }
    }
    
    char *originalStr = calloc(fileStrLen, 1);
    strcpy(originalStr, [self unravelCharWithLastColumn:lastCol firstColumn:firstCol]);
    
    [self matchReedsArray:reedsArray withLastCol:lastCol andFirstCol:firstCol];
}

- (void)matchReedsArray:(NSArray *)array withLastCol:(char*)lastCol andFirstCol:(char*)firstCol {
    char *reed;
    
    char *originalStr = calloc(strlen(lastCol), 1);
    strcpy(originalStr,  [self unravelCharWithLastColumn:lastCol firstColumn:firstCol]);
    
    if (kDebugOn == 2) {
        printf("%s\n",originalStr);
    }
    
    for (int i = 0; i < array.count; i++) {
        reed = (char*)[[array objectAtIndex:i] UTF8String];
        
        int a = [self getBestMatchForQuery:reed withLastCol:lastCol andFirstCol:firstCol andNumOfSubs:maxSubs];
        
        if (kDebugOn == -1) {
            for (int t = 0; t<a; t++) {
                printf(" ");
            }
            printf("%s\n",reed);
        }
        
        if (a > -1)//var a matched
            [self updatePosOccsArrayWithRange:NSMakeRange(a, strlen(reed)) andOriginalStr:originalStr andQuery:reed];//a-1 because $ is first
        else if (a < -1)
            [self updatePosOccsArrayWithRange:NSMakeRange(abs(a), strlen(reed)) andOriginalStr:originalStr andQuery:[self getReverseComplementForSeq:reed]];
    }
    
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

- (int)getIndexOfNth:(int)n OccurenceOfChar:(char)c inChar:(char*)container {
    int loc = 1;
    int whichChar = [self whichChar:c inContainer:acgt];
    for (int i = 0; i<whichChar; i++) {
        loc+=acgtTotalOccs[i];
    }
    loc+=n;
    return loc-1;
    
}
- (int)whichOccurenceOfChar:(char)c inChar:(char*)container atPos:(int)pos {
    int topMultiple = 0;
    for (int i = 0; i<pos; i++) {
        if (topMultiple<pos) {
            topMultiple+=kMultipleToCountAt;
        }
        if (topMultiple>pos) {
            topMultiple-=kMultipleToCountAt;
            break;
        }
        if (topMultiple == pos) {
            break;
        }
    }
    int whichChar = [self whichChar:c inContainer:acgt];
    int occurences = 0;
    for (int i = 0; i<topMultiple/kMultipleToCountAt; i++) {
        occurences+=acgtOccurences[i][whichChar];
    }
    if (topMultiple<pos) {
        for (int i = topMultiple; i<pos; i++) {
            if (container[i] == acgt[whichChar]) {
                occurences++;
            }
        }
    }
    occurences++;
    return occurences;
}

- (NSArray*)exactMatchForQuery:(char*)query withLastCol:(char*)lastCol andFirstCol:(char*)firstCol {
    int i = strlen(query)-1;
    char c = query[i];
    int startPos = [self charsBeforeChar:c];
    
    int whichChar = [self whichChar:c inContainer:acgt]+1;
    int endPos = [self charsBeforeChar:acgt[whichChar]];
    
    if (whichChar == kACGTLen) {
        endPos = fileStrLen;
    }
    i--;
    while (startPos<endPos && i >= 0) {
        c = query[i];
        startPos = [self LFC:startPos andChar:c withLastCol:lastCol]-1;
        endPos = [self LFC:endPos andChar:c withLastCol:lastCol]-1;
        i--;
    }
    
    NSMutableArray *posArray = [[NSMutableArray alloc] init];
    
    for (int l = 0; l<endPos-startPos; l++) {
        [posArray addObject:[NSNumber numberWithInt:startPos+l]];
    }
    
    return (NSArray*)[[NSMutableArray alloc] initWithArray:[self positionInBWTwithPosInBWM:posArray andFirstCol:firstCol andLastCol:lastCol]];
}
- (int)LFC:(int)r andChar:(char)c withLastCol:(char*)lastCol {
    int occ = [self whichOccurenceOfChar:c inChar:lastCol atPos:r];
    return [self charsBeforeChar:c]+occ;
}

- (NSArray*)positionInBWTwithPosInBWM:(NSArray*)posArray andFirstCol:(char *)firstColumn andLastCol:(char *)lastColumn {
    
    NSMutableArray *positionsInBWTArray = [[NSMutableArray alloc] init];
    
    int i;//index
    int pos = fileStrLen-1;
    int occurence = 1;//1 = 1st, etc.
    char lastChar = lastColumn[0];
    
    
    i = [self getIndexOfNth:occurence OccurenceOfChar:lastChar inChar:firstColumn];
    
    for (int l = 0; l<[posArray count]; l++) {
        if ([[posArray objectAtIndex:l] intValue] == i) {
            [positionsInBWTArray addObject:[NSNumber numberWithInt:pos-1]];
        }
    }
    
    while (pos>=0) {
        pos--;
        lastChar = lastColumn[i];
        
        occurence = [self whichOccurenceOfChar:lastChar inChar:lastColumn atPos:i];
        i = [self getIndexOfNth:occurence OccurenceOfChar:lastChar inChar:firstColumn];
        
        if ([posArray count] == [positionsInBWTArray count]) {
            break;
        }
        for (int l = 0; l<[posArray count]; l++) {
            if ([[posArray objectAtIndex:l] intValue] == i) {
                [positionsInBWTArray addObject:[NSNumber numberWithInt:pos-1]];
            }
        }
    }
    
    return (NSArray*)positionsInBWTArray;
}
- (void)setUpNumberOfOccurencesArray {
    int len = fileStrLen;
    
    int spotInACGTOccurences = 0;
    
    acgt = calloc(kACGTLen, 1);
    strcpy(acgt, kACGTStr);
    
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
                }
            }
            if (i == pos) {
                for (int l = 0; l<kACGTLen; l++) {
                    acgtOccurences[spotInACGTOccurences][l] = occurences[l];
                }
                spotInACGTOccurences++;
                for (int x = 0; x<kACGTLen; x++) {
                    occurences[x] = 0;
                }
                pos += kMultipleToCountAt;
            }
            for (int x = 0; x<kACGTLen; x++) {
                if (acgt[x] == refStrBWT[i]) {
                    acgtTotalOccs[x]++;
                }
            }
        }
    }
}


- (int)whichChar:(char)c inContainer:(char*)container {
    int which = 0;
    for (int i = 0; i<kACGTLen; i++) {
        if (acgt[i] == c) {
            which = i;
            break;
        }
    }
    return which;
}
- (int)charsBeforeChar:(char)c {
    int which = [self whichChar:c inContainer:acgt];
    int num = 0;
    for (int i = 0; i<which; i++) {
        num+=acgtTotalOccs[i];
    }
    return num+1;
}

#pragma APPROXIMATE MATCH
- (NSArray*)approxiMatchForQuery:(char*)query withLastCol:(char*)lastCol andFirstCol:(char*)firstCol andNumOfSubs:(int)amtOfSubs {
    
    if (amtOfSubs == 0) {
         return (NSMutableArray*)[self exactMatchForQuery:query withLastCol:lastCol andFirstCol:firstCol];
    }
    
    if (strcmp(query,"ACT") == 0)
        printf("");
    
    int numOfChunks = amtOfSubs+1;
    int sizeOfChunks = strlen(query)/numOfChunks;
    int queryLength = strlen(query);
    
    if (fmod(queryLength, 2) != 0) {
        //Odd
        queryLength++;
        sizeOfChunks = (float)queryLength/numOfChunks;
    }
    
    Chunks *chunks[numOfChunks];
    
    for (int i = 0; i<numOfChunks; i++) {
        chunks[i] = [[Chunks alloc] init];
    }
    
    int subsInChunk[numOfChunks];
    int start = 0;
    
    NSMutableArray *positionsArray = [[NSMutableArray alloc] init];
    
    char *originalStr = [self unravelCharWithLastColumn:lastCol firstColumn:firstCol];
    
    if (amtOfSubs>0) {
        for (int i = 0; i<numOfChunks; i++) {
            if (i < numOfChunks-1) {
                strcpy(chunks[i].string, strcat(substr(query, start, sizeOfChunks),"\0"));
            }
            else {
                strcpy(chunks[i].string, strcat(substr(query, start, sizeOfChunks+1),"\0"));
            }
            start += sizeOfChunks;
        }
        
        if (kDebugOn > 0) {
            for (int i = 0; i<numOfChunks; i++) {
                printf("\nCHUNK: %s, %i",chunks[i].string, i);
            }
        }
        int charsToCheckRight = 0;
        int charsToCheckLeft = 0;
        
        int counter = 0;
        
        int numOfSubstitutions = 0;
        
        for (int i = 0; i<numOfChunks; i++) {
            chunks[i].matchedPositions = (NSMutableArray*)[self exactMatchForQuery:chunks[i].string withLastCol:lastCol andFirstCol:firstCol];
            
            if (kDebugOn>0)
                printf("\nNUMBER OF MATCHED POSITIONS FOR CHUNK %i (%s): %i: 1st Matched Pos: %i",i,chunks[i].string,chunks[i].matchedPositions.count,(chunks[i].matchedPositions.count>0)?[[chunks[i].matchedPositions objectAtIndex:0] intValue]:-1);
                
            
            for (int x = 0; x<[chunks[i].matchedPositions count]; x++) {
                counter++;
                
                if (i>0 && i<numOfChunks-1) {
                    charsToCheckLeft = (i)*sizeOfChunks;//i+1?
                    charsToCheckRight = (queryLength-1)-((sizeOfChunks*i+1)+(sizeOfChunks-1));
                }
                else if (i == 0) {
                    charsToCheckLeft = 0;
                    charsToCheckRight = (numOfChunks-1)*sizeOfChunks;
                    if (strlen(query)%2 != 0) {
                        charsToCheckRight -= 1;//originally ++
                    }
                }
                else if (i == numOfChunks-1) {
                    charsToCheckLeft = (numOfChunks-1)*sizeOfChunks;
                    charsToCheckRight = 0;
                }
                
                int leftStrStart = [[chunks[i].matchedPositions objectAtIndex:x] intValue] - charsToCheckLeft;
                int rightStrStart = [[chunks[i].matchedPositions objectAtIndex:x] intValue]+strlen(chunks[i].string);
                
                
                for (int l = 0; l<charsToCheckLeft; l++) {
                    if (originalStr[l+leftStrStart] != query[l]) {
                        numOfSubstitutions++;
                        subsInChunk[numOfChunks-(int)floorf((float)(l/sizeOfChunks)+1)-(numOfChunks-i-1)-1]++;//orignially no numofchunk or -1
                    }
                }
                
                if (rightStrStart>=fileStrLen-1) {
                    charsToCheckRight = 0;
                }
                for (int l = 0; l<charsToCheckRight; l++) {
                    
                    if (originalStr[l+rightStrStart] != query[(i+1)*sizeOfChunks+l]) {//-1
                        numOfSubstitutions++;
                        
                        subsInChunk[(int)floorf((float)l/sizeOfChunks)+1+i]++;
                        
                        if (numOfSubstitutions > amtOfSubs) {
                            break;
                        }
                    }
                }

                if (numOfSubstitutions<=amtOfSubs) {
                    NSMutableArray *array = [[NSMutableArray alloc] init];
                    for (int r = 0; r<numOfChunks; r++) {
                        [array addObject:[NSNumber numberWithInt:subsInChunk[r]]];
                    }
                    
                    if ([self isNotDuplicateAlignment:array andChunkNum:i]) {
                        int pos = [[chunks[i].matchedPositions objectAtIndex:x] intValue] - i*sizeOfChunks;//QUESTIONABLE HERE
                        
                        if (pos+strlen(query)<=strlen(refStrBWT) && pos>-1) {
                            [positionsArray addObject:[NSNumber numberWithInt:pos]];
                            
                            //                            [self updatePosOccsArrayWithRange:NSMakeRange(pos, strlen(query)) andOriginalStr:originalStr andQuery:query];         COMMENTED SO THAT IT CAN BE UPDATE ABOVE
                        }
                    }
                }
                
                numOfSubstitutions = 0;
                for (int r = 0; r<numOfChunks; r++) {
                    subsInChunk[r] = 0;
                }
            }
            
        }
    }
    return positionsArray;
}

- (int)getBestMatchForQuery:(char*)query withLastCol:(char*)lastCol andFirstCol:(char*)firstCol andNumOfSubs:(int)amtOfSubs {
    
    NSArray *arr = [[NSMutableArray alloc] init];
    
    int forwardMatches = 0;//EX. ACA
    int reverseMatches = 0;//EX. TGT
    
    for (int x = 0; x < amtOfSubs+1; x++) {
        arr = (x>0) ? [self approxiMatchForQuery:query withLastCol:lastCol andFirstCol:firstCol andNumOfSubs:x] : [self exactMatchForQuery:query withLastCol:lastCol andFirstCol:firstCol];
        
        forwardMatches = [arr count];
        
        arr = [arr arrayByAddingObjectsFromArray:[self approxiMatchForQuery:[self getReverseComplementForSeq:query] withLastCol:lastCol andFirstCol:firstCol andNumOfSubs:x]];
        
        reverseMatches = [arr count]-forwardMatches;
        
        if (kDebugOn>0) {
            for (int o = 0; o<arr.count; o++) {
                printf("\nMATCH[%i] FOR QUERY: %s WITH NUMOFSUBS: %i ::: %i",o,query,x,[[arr objectAtIndex:o] intValue]);
            }
        }
        
        if (kDebugOn == -1) {
            for (int o = 0; o<[arr count]; o++) {
                printf("\n%i\n",[[arr objectAtIndex:o] intValue]);
            }
        }
        
        if ([arr count] > 0) {
            int rand = (int)arc4random()%[arr count];
            int v = [[arr objectAtIndex:rand] intValue];
            v = (rand>forwardMatches-1) ? -v : v;
            return v;
        }
    }
    return -1;//No match
}

- (BOOL)isNotDuplicateAlignment:(NSArray *)subsArray andChunkNum:(int)chunkNum {//TRUE IS NO DUPLICATE
    
    if (chunkNum == 0) {//No Duplicates If it is first chunk (nothing come before it)
        return TRUE;
    }
    
    for (int i = 0; i<[subsArray count]-([subsArray count]-chunkNum); i++) {
        if ([[subsArray objectAtIndex:i] intValue] == 0) {
            return FALSE;
        }
    }
    
    return TRUE;
}

- (void)updatePosOccsArrayWithRange:(NSRange)range andOriginalStr:(char*)originalStr andQuery:(char*)query {
    for (int i = range.location; i<range.length+range.location; i++) {
        int c = [self whichChar:query[i-range.location] inContainer:acgt];
        posOccArray[c][i]++;
        
    }
}

char *substr(const char *pstr, int start, int numchars)
{
    char *pnew = malloc(numchars+1);
    strncpy(pnew, pstr + start, numchars);
    pnew[numchars] = '\0';
    return pnew;
}


- (void)sortArrayUsingQuicksort:(NSMutableArray*)array withStartPos:(int)startPos andEndPos:(int)endpos {
    int pivotPos = (arc4random() % (endpos-startPos))+startPos;//rand%amtofthings in array
    int pivot = [[array objectAtIndex:pivotPos] intValue];
    int firstPos = startPos;
    int lastPos = endpos;
    int s = [[array objectAtIndex:firstPos] intValue];
    int e = [[array objectAtIndex:lastPos] intValue];
    
    while (firstPos<lastPos) {
        while (s<pivot) {
            firstPos++;
            s = [[array objectAtIndex:firstPos] intValue];
        }
        while (e>pivot) {
            lastPos--;
            e = [[array objectAtIndex:lastPos] intValue];
        }
        if (firstPos<=lastPos) {
            [array exchangeObjectAtIndex:firstPos withObjectAtIndex:lastPos];
            firstPos++;//Meant to get out of while loop if firstpos==lastpos
            lastPos--;
            if (firstPos!=[array count]) {
                s = [[array objectAtIndex:firstPos] intValue];
            }
            if (lastPos!=-1) {
                e = [[array objectAtIndex:lastPos] intValue];
            }
        }
    }
    
    if (startPos<lastPos) {//Lastpos is one to left of median
        [self sortArrayUsingQuicksort:array withStartPos:startPos andEndPos:lastPos];
    }
    if (firstPos<endpos) {//firstpos is one to right of median
        [self sortArrayUsingQuicksort:array withStartPos:firstPos andEndPos:endpos];
    }
}

//Getters
- (char*)getReverseComplementForSeq:(char*)seq {
    int len = strlen(seq);
    char *revSeq = calloc(len, 1);
    
    for (int i = 0; i<len; i++) {
        revSeq[i] = acgt[kACGTLen-[self whichChar:seq[i] inContainer:acgt]-1];//len-i-1 because that allows for 0th pos to be set rather than just last pos to be set is 1
    }
    
    return revSeq;
}

- (NSString*)getPosOccArray {
    NSMutableString* myString = [[NSMutableString alloc] init];
    
    for (int i = 0; i<kACGTLen; i++) {
        for (int a = 0; a<kBytesForIndexer*kMultipleToCountAt; a++) {
            (i == kACGTLen-1 && a == kBytesForIndexer*kMultipleToCountAt) ? [myString appendFormat:@"%i",posOccArray[i][a]] : [myString appendFormat:@"%i,",posOccArray[i][a]];
        }
        [myString appendFormat:@"\n"];
    }
    
    return myString;
}
@end
