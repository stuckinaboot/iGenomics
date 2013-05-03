//
//  BWT_Matcher.m
//  LabProject7
//
//  Created by Stuckinaboot Inc. on 9/15/12.
//
//

#import "BWT_Matcher.h"

int posOccArray[kACGTLen+2][kMaxBytesForIndexer*kMaxMultipleToCountAt];//+2 because of deletions +1(-) and insertions +2(+)

@implementation BWT_Matcher

@synthesize kBytesForIndexer, /*kMultipleToCountAt,*/ matchType, alignmentType, insertionsArray;
@synthesize readLen, refSeqLen, numOfReads;
@synthesize delegate;

- (id)initWithOriginalStr:(char*)orgStr {
    if (self == [super init]) {
        originalStr = orgStr;
        exactMatcher = [[BWT_MatcherSC alloc] init];
    }
    return self;
}

- (void)setUpReedsFile:(NSString*)fileName fileExt:(NSString*)fileExt refStrBWT:(char*)bwt andMaxSubs:(int)subs {
    NSString* reedsString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:fileExt] encoding:NSUTF8StringEncoding error:nil];
    reedsArray = [[NSArray alloc] initWithArray:[reedsString componentsSeparatedByString:kReedsArraySeperationStr]];
    numOfReads = [reedsArray count];
    
    NSString *firstRead = [reedsArray objectAtIndex:0];
    readLen = firstRead.length;
    
    refStrBWT = strdup(bwt);
    
    maxSubs = subs;
    
    fileStrLen = strlen(refStrBWT);
    refSeqLen = fileStrLen;
    
    //kBytesForIndexer and kMultipleToCountAt Are Set here
    [self setUpBytesForIndexerAndMultipleToCountAt:fileStrLen];
    
    [self setUpNumberOfOccurencesArray];
    
    self.insertionsArray = [[NSMutableArray alloc] init];
    
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
        for (int x = 0; x<fileStrLen; x++)
            posOccArray[i][x] = 0;
    }
    
    [self matchReedsArray:reedsArray withLastCol:lastCol andFirstCol:firstCol];
    
    if (kDebugPrintInsertions>0) {
        printf("\nINSERTIONS:");
        for (int i = 0; i<[insertionsArray count]; i++) {
            BWT_Matcher_InsertionDeletion_InsertionHolder *h = [self.insertionsArray objectAtIndex:i];
            printf("\nPos: %i, Count: %i, Seq: %s",h.pos,h.count,h.seq);
        }
    }
}

- (void)matchReedsArray:(NSArray *)array withLastCol:(char*)lastCol andFirstCol:(char*)firstCol {
    char *reed;
    
    if (kDebugOn == 2)
        printf("%s\n",originalStr);
    
    for (int i = 0; i < array.count; i++) {
        reed = (char*)[[array objectAtIndex:i] UTF8String];
        
        MatchedReadData* a = [self getBestMatchForQuery:reed withLastCol:lastCol andFirstCol:firstCol andNumOfSubs:maxSubs];
        
        if (a != NULL)
            [self updatePosOccsArrayWithRange:NSMakeRange(a.pos, strlen(reed)) andQuery:reed andED_Info:a.info andIsReverse:a.isReverse];
        
        [delegate readProccesed];
    }
    
}


- (MatchedReadData*)getBestMatchForQuery:(char*)query withLastCol:(char*)lastCol andFirstCol:(char*)firstCol andNumOfSubs:(int)amtOfSubs {
    
    NSArray *arr = [[NSMutableArray alloc] init];
    
    int forwardMatches = 0;//EX. ACA
    int reverseMatches = 0;//EX. TGT
    
    BWT_Matcher_Approxi *approxiMatcher = [[BWT_Matcher_Approxi alloc] init];
    
    for (int subs = 0; subs < amtOfSubs+1; subs++) {
        if (subs == 0 || matchType == MatchTypeExactOnly)
            arr = [exactMatcher exactMatchForQuery:query withLastCol:lastCol andFirstCol:firstCol andIsReverse:NO andForOnlyPos:NO];
        else {
            if (matchType == MatchTypeExactAndSubs)
                arr = [approxiMatcher approxiMatchForQuery:query withLastCol:lastCol andFirstCol:firstCol andNumOfSubs:subs andIsReverse:NO];
            else if (matchType == MatchTypeSubsAndIndels)
                arr = [self insertionDeletionMatchesForQuery:query andLastCol:lastCol andNumOfSubs:subs andIsReverse:NO];
        }
        
        forwardMatches = [arr count];
        
        if (alignmentType > 0) {//Reverse also
            if (subs == 0 || matchType == MatchTypeExactOnly)
                arr = [arr arrayByAddingObjectsFromArray:[exactMatcher exactMatchForQuery:[self getReverseComplementForSeq:query] withLastCol:lastCol andFirstCol:firstCol andIsReverse:YES andForOnlyPos:NO]];
            else {
                if (matchType == MatchTypeExactAndSubs)
                    arr = [arr arrayByAddingObjectsFromArray:[approxiMatcher approxiMatchForQuery:[self getReverseComplementForSeq:query] withLastCol:lastCol andFirstCol:firstCol andNumOfSubs:subs andIsReverse:YES]];
                else if (matchType == MatchTypeSubsAndIndels)
                    arr = [arr arrayByAddingObjectsFromArray:[self insertionDeletionMatchesForQuery:[self getReverseComplementForSeq:query] andLastCol:lastCol andNumOfSubs:subs andIsReverse:YES]];
            }
        }
        
        reverseMatches = [arr count]-forwardMatches;
        if (kDebugOn>0) {
            for (int o = 0; o<arr.count; o++)
                printf("\nMATCH[%i] FOR QUERY: %s WITH NUMOFSUBS: %i ::: %i",o,query,subs,[[arr objectAtIndex:o] intValue]);
        }
        
        if (kDebugOn == -1) {
            for (int o = 0; o<[arr count]; o++)
                printf("\n%i\n",[[arr objectAtIndex:o] intValue]);
        }
        
        if ([arr count] > 0) {
            int rand = (int)arc4random()%[arr count];
            return [arr objectAtIndex:rand];
        }
    }
    return NULL;//No match
}

- (void)updatePosOccsArrayWithRange:(NSRange)range andQuery:(char*)query andED_Info:(ED_Info *)info andIsReverse:(BOOL)isRev {
    if (isRev)
        query = [self getReverseComplementForSeq:query];
    
    if (info == NULL) {
        for (int i = range.location; i<range.length+range.location; i++) {
            int c = [BWT_MatcherSC whichChar:query[i-range.location] inContainer:acgt];
            
            if (c == -1) {//DEL --- Not positive though
                if (query[i-range.location] == kDelMarker)
                    c = kACGTLen;
            }
            
            posOccArray[c][i]++;
        }
    }
    else if (info.distance == 0) {
        for (int i = info.position; i<range.length+info.position; i++) {
            int c = [BWT_MatcherSC whichChar:query[i-info.position] inContainer:acgt];
            
            if (c == -1) {//DEL --- Not positive though
                if (query[i-info.position] == kDelMarker)
                    c = kACGTLen;
            }
            
            posOccArray[c][i]++;
        }
    }
    else {
        [self recordInDel:info];
    }
}

//INSERTION/DELETION
- (NSMutableArray*)insertionDeletionMatchesForQuery:(char*)query andLastCol:(char*)lastCol andNumOfSubs:(int)numOfSubs andIsReverse:(BOOL)isRev {
    //    Create first Column
    char *firstCol = calloc(fileStrLen, 1);
    firstCol[0] = '$';
    
    int pos = 1;
    for (int x = 0; x<kACGTLen; x++) {
        for (int i = 0; i<acgtTotalOccs[x]; i++) {
            firstCol[pos] = acgt[x];
            pos++;
        }
    }
    //    Create BWT Matcher for In/Del
    BWT_Matcher_InsertionDeletion *bwtIDMatcher = [[BWT_Matcher_InsertionDeletion alloc] init];
    
    //    Split read into chunks
    int numOfChunks = numOfSubs+1;
    int queryLength = strlen(query);
    int sizeOfChunks = queryLength/numOfChunks;
    
    if (fmod(queryLength, 2) != 0) {
        //Odd
        queryLength++;
        sizeOfChunks = (float)queryLength/numOfChunks;
    }
    
    //    Fill Chunks with their respective string, and then use exact match to match the chunks to the reference
    int start = 0;
    NSMutableArray *chunkArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i<numOfChunks; i++) {
        Chunks *chunk = [[Chunks alloc] init];
        if (i < numOfChunks-1)
            strcpy(chunk.string, strcat(substr(query, start, sizeOfChunks),"\0"));
        else
            strcpy(chunk.string, strcat(substr(query, start, sizeOfChunks+(int)(float)queryLength % numOfChunks),"\0"));
        
        chunk.matchedPositions = (NSMutableArray*)[exactMatcher exactMatchForQuery:chunk.string withLastCol:lastCol andFirstCol:firstCol andIsReverse:isRev andForOnlyPos:YES];
        [chunkArray addObject:chunk];
        start += sizeOfChunks;
    }
    
    //  Find In/Del by using the matched positions of the chunks
    NSMutableArray *matchedInDels = [[NSMutableArray alloc] initWithArray:[bwtIDMatcher setUpWithCharA:query andCharB:originalStr andChunks:chunkArray andMaximumEditDist:kMaxEditDist andIsReverse:isRev]];

    return matchedInDels;
}

- (void)recordInDel:(ED_Info*)info {
    int aLen = strlen(info.gappedA);
    
    if (info.position+aLen<=fileStrLen && !info.insertion) //If it does not go over
        [self updatePosOccsArrayWithRange:NSMakeRange(info.position,aLen) andQuery:info.gappedA andED_Info:NULL andIsReverse:NO];
    
    //        INSERTIONS
    else if (info.position >= 0 && info.position+aLen<=fileStrLen) {//ISN'T Negative and doesn't go over
        int bLen = strlen(info.gappedB);
        int insCount = 0;
        char *smallSeq = calloc(kMaxInsertionSeqLen, 1);
        
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
                smallSeq[0] = info.gappedA[a];
                smallSeq[1] = '\0';
                int w = [BWT_MatcherSC whichChar:smallSeq[0] inContainer:acgt];
                posOccArray[(w>-1) ? w : kACGTLen][info.position+a-insCount]++;
            }
        }
    }
}
//INSERTION/DELETION END

- (void)setUpBytesForIndexerAndMultipleToCountAt:(int)seqLen {
    kBytesForIndexer = ceil(sqrt(seqLen));
    kMultipleToCountAt = kBytesForIndexer;
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
                if (acgt[x] == refStrBWT[i])
                    occurences[x]++;
            }
            if (i == pos) {
                for (int l = 0; l<kACGTLen; l++)
                    acgtOccurences[spotInACGTOccurences][l] = occurences[l];
                spotInACGTOccurences++;
                for (int x = 0; x<kACGTLen; x++)
                    occurences[x] = 0;
                pos += kMultipleToCountAt;
            }
            for (int x = 0; x<kACGTLen; x++) {
                if (acgt[x] == refStrBWT[i])
                    acgtTotalOccs[x]++;
            }
        }
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
    
    for (int i = 0; i<len; i++)
        revSeq[i] = acgt[kACGTLen-[BWT_MatcherSC whichChar:seq[len-i-1] inContainer:acgt]-1];//len-i-1 because that allows for 0th pos to be set rather than just last pos to be set is 1
    
    return revSeq;
}

- (char*)getSortedSeq {
    char *firstCol = calloc(fileStrLen, 1);
    firstCol[0] = '$';
    
    int pos = 1;
    for (int x = 0; x<kACGTLen; x++) {
        for (int i = 0; i<acgtTotalOccs[x]; i++) {
            firstCol[pos] = acgt[x];
            pos++;
        }
    }
    
    return  firstCol;
}
@end