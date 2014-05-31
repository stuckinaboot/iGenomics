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

@synthesize /*kMultipleToCountAt,*/ matchType, alignmentType, insertionsArray;
@synthesize readLen, refSeqLen, numOfReads;
@synthesize delegate;

- (id)initWithOriginalStr:(char*)orgStr {
    if (self == [super init]) {
        originalStr = orgStr;
        exactMatcher = [[BWT_MatcherSC alloc] init];
    }
    return self;
}

- (void)setUpReedsFileContents:(NSString*)contents refStrBWT:(char*)bwt andMaxSubs:(int)subs {
    
    NSLog(@"==> setUpReedsFileContents:(NSString*)contents refStrBWT:(char*)bwt andMaxSubs:(int)subs entered");
    
    NSArray *preReadsArray = [[NSMutableArray alloc] initWithArray:[contents componentsSeparatedByString:kReedsArraySeperationStr]];
    reedsArray = [[NSMutableArray alloc] init];
    
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
    
    NSLog(@"About to set basic variables");
    
    numOfReads = [reedsArray count];
    
    Read *firstRead = [reedsArray objectAtIndex:0];
    readLen = strlen(firstRead.sequence);
    
    refStrBWT = strdup(bwt);
    
    maxSubs = subs;
    readNum = 0;
    
    dgenomeLen = strlen(refStrBWT);
    refSeqLen = dgenomeLen;
    
//    [self setUpNumberOfOccurencesArray];
    NSLog(@"About to call setUpNumberOfOccurencesArrayFast");
    
    [self setUpNumberOfOccurencesArrayFast];
    
    self.insertionsArray = [[NSMutableArray alloc] init];
    
    NSLog(@"About to create firstCol");
    
    firstCol = calloc(dgenomeLen, 1);
    
    firstCol[0] = '$';
    
    int pos = 1;
    for (int x = 0; x<kACGTLen; x++) {
        for (int i = 0; i<acgtTotalOccs[x]; i++) {
            firstCol[pos] = acgt[x];
            pos++;
        }
    }
    
    for (int i = 0; i<kACGTLen+2; i++) {
        for (int x = 0; x<dgenomeLen; x++)
            posOccArray[i][x] = 0;
    }
    
    NSLog(@"<== setUpReedsFileContents:(NSString*)contents refStrBWT:(char*)bwt andMaxSubs:(int)subs");
    
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
        
        ED_Info* a = [self getBestMatchForQuery:reed.sequence withLastCol:refStrBWT andFirstCol:firstCol andNumOfSubs:maxSubs andReadNum:readNum];
        
        if (a != NULL) {
            a.readName = reed.name;
            [self updatePosOccsArrayWithRange:NSMakeRange(a.position, readLen) andED_Info:a];
            
        }
        [delegate readProccesed:readDataStr];
        [readDataStr setString:@""];
    }
//    [exactMatcher timerPrint];
    [matchingTimer stopAndLog];
}


- (ED_Info*)getBestMatchForQuery:(char*)query withLastCol:(char*)lastCol andFirstCol:(char*)firstCol andNumOfSubs:(int)amtOfSubs andReadNum:(int)readNum {
    
    NSArray *arr = [[NSMutableArray alloc] init];
    
    int forwardMatches = 0;//EX. ACA

    BWT_Matcher_Approxi *approxiMatcher = [[BWT_Matcher_Approxi alloc] init];
    
    for (int subs = 0; subs < amtOfSubs+1; subs++) {
        if (subs == 0 || matchType == MatchTypeExactOnly)
            arr = [exactMatcher exactMatchForQuery:query andIsReverse:NO andForOnlyPos:NO];
        else {
            if (matchType == MatchTypeExactAndSubs)
                arr = [approxiMatcher approxiMatchForQuery:query andNumOfSubs:subs andIsReverse:NO andReadLen:readLen];
            else if (matchType == MatchTypeSubsAndIndels)
                arr = [self insertionDeletionMatchesForQuery:query andLastCol:lastCol andNumOfSubs:subs andIsReverse:NO];
        }
        
        forwardMatches = [arr count];
        
        if (alignmentType > 0) {//Reverse also
            if (subs == 0 || matchType == MatchTypeExactOnly) {
                arr = [arr arrayByAddingObjectsFromArray:[exactMatcher exactMatchForQuery:[self getReverseComplementForSeq:query] andIsReverse:YES andForOnlyPos:NO]];
//                if ([arr count] > forwardMatches) {
//                    int counter = 0;
//                    for (ED_Info *info in arr) {
//                        counter++;
//                        if (counter >= forwardMatches)
//                            printf("\n%i",info.isRev);
//                    }
//                }
            }
            else {
                if (matchType == MatchTypeExactAndSubs)
                    arr = [arr arrayByAddingObjectsFromArray:[approxiMatcher approxiMatchForQuery:[self getReverseComplementForSeq:query] andNumOfSubs:subs andIsReverse:YES andReadLen:readLen]];
                else if (matchType == MatchTypeSubsAndIndels)
                    arr = [arr arrayByAddingObjectsFromArray:[self insertionDeletionMatchesForQuery:[self getReverseComplementForSeq:query] andLastCol:lastCol andNumOfSubs:subs andIsReverse:YES]];
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
        
        if ([arr count] > 0)
            return [arr objectAtIndex:((int)arc4random()%[arr count])];
    }
    return NULL;//No match
}

- (void)updatePosOccsArrayWithRange:(NSRange)range andED_Info:(ED_Info *)info {
//    if (info.isRev)
//        query = [self getReverseComplementForSeq:query];
    
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
    [readDataStr appendFormat:@"%s,%i,%c,%i,%s,%s\n", info.readName,info.position+1/* +1 because export data should start from 1, not 0*/,(info.isRev) ? '-' : '+', info.distance,info.gappedB,info.gappedA];
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
    }
    
    //  Find In/Del by using the matched positions of the chunks
    NSMutableArray *matchedInDels = [[NSMutableArray alloc] initWithArray:[bwtIDMatcher setUpWithCharA:query andCharB:originalStr andChunks:chunkArray andMaximumEditDist:numOfSubs andIsReverse:isRev]];

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

- (void)setUpNumberOfOccurencesArray {
    int len = dgenomeLen;
    
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

char *substr(const char *pstr, int start, int numchars)
{
    char *pnew = malloc(numchars+1);
    strncpy(pnew, pstr + start, numchars);
    pnew[numchars] = '\0';
    return pnew;
}

//Getters
- (char*)getReverseComplementForSeq:(char*)seq {
    int len = readLen; //The only thing you should be getting a reverse complement for is the read (am I right?)
    char *revSeq = calloc(len, 1);
    
    for (int i = 0; i<len; i++)
        revSeq[i] = acgt[kACGTLen-[BWT_MatcherSC whichChar:seq[len-i-1] inContainer:acgt]-1];//len-i-1 because that allows for 0th pos to be set rather than just last pos to be set is 1
    
    return revSeq;
}
@end