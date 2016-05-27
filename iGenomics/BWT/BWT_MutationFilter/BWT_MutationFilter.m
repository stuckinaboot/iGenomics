//
//  BWT_MutationFilter.m
//  LabProject7
//
//  Created by Stuckinaboot Inc. on 9/15/12.
//
//

#import "BWT_MutationFilter.h"
#import "ImportantMutationInfo.h"

char *foundGenome[kFoundGenomeArrSize];
int coverageArray[kMaxBytesForIndexer*kMaxMultipleToCountAt];

@implementation BWT_MutationFilter

@synthesize kHeteroAllowance;

- (void)setUpMutationFilterWithOriginalStr:(char*)originalSeq andMatcher:(BWT_Matcher*)myMatcher {
    acgt = kACGTStr;
    refStr = originalSeq;
    fileStrLen = strlen(refStr);
    
    for (int i = 0; i<kFoundGenomeArrSize; i++) {
        if (foundGenome[i] && strlen(foundGenome[i]) > 0)
            free(foundGenome[i]);
        foundGenome[i] = calloc(fileStrLen+1,1);
    }
    
    for (int i = 0; i<kFoundGenomeArrSize; i++) {
        for (int x = 0; x<fileStrLen; x++) {
            foundGenome[i][x] = kFoundGenomeDefaultChar;
        }
        foundGenome[i][fileStrLen] = '\0';
    }
    
    strcpy(foundGenome[0], refStr);
    
    matcher = myMatcher;
//    [self setUpPosOccArray];
}

- (void)resetFoundGenome {
    for (int i = 0; i < kFoundGenomeArrSize; i++) {
        for (int x = 0; x<fileStrLen; x++) {
            foundGenome[i][x] = kFoundGenomeDefaultChar;
        }
        foundGenome[i][fileStrLen] = '\0';
    }
    
    strcpy(foundGenome[0], refStr);
}

/*
- (void)setUpPosOccArray {
    for (int i = 0; i<kACGTLen+2; i++) {
        for (int a = 0; a<fileStrLen-1; a++) {
            posOccArray[i][a] = [matcher getPosOccArrayObj:i :a];
        }
    }
}*/

- (void)buildOccTableWithUnravStr:(char*)unravStr {
    
    int charWMostOccs;//0,1,2,3 etc. -> A, C, G, T etc.
    int posInFoundGenomeCounter = 1;
    int coverageCounter = 0;
    
    for (int i = 0; i<fileStrLen-1; i++) {
        for (int a = 0; a < kACGTwithInDelsLen; a++) {
            
            if (posOccArray[a][i]>0 /*&& a < kACGTLen+1*/) { //Character did match, at least 1x coverage was found, and not an insertion
                coverageCounter += posOccArray[a][i];
            }
            
            if (a == 0)
                charWMostOccs = 0;
            else if (posOccArray[a][i]>posOccArray[charWMostOccs][i]) //Greater
                charWMostOccs = a;
            else if (posOccArray[a][i] == posOccArray[charWMostOccs][i]) {
                //Same = Pick at random
                int r = arc4random()%2;//Pick between the 2
                
                if (r == 0) //Only change charWMostOccs if it is = to 0
                    charWMostOccs = a;
            }
        }
        
        if (coverageCounter>0) {
            if (charWMostOccs<kACGTLen)
                foundGenome[0][i] = acgt[charWMostOccs];
            else if (charWMostOccs == kACGTLen)
                foundGenome[0][i] = kDelMarker;
            else if (charWMostOccs == kACGTLen+1)
                foundGenome[0][i] = kInsMarker;
        }
        for (int a = 0; a < kACGTwithInDelsLen; a++) {
            if (charWMostOccs != a) {
                if (posOccArray[a][i]>=kHeteroAllowance) {
                    if (a<kACGTLen)
                        foundGenome[posInFoundGenomeCounter][i] = acgt[a];
                    else if (a == kACGTLen)
                        foundGenome[posInFoundGenomeCounter][i] = kDelMarker;
                    else if (a == kACGTLen+1)
                        foundGenome[posInFoundGenomeCounter][i] = kInsMarker;
                    posInFoundGenomeCounter++;
                }
            }
        }
        
        coverageArray[i] = coverageCounter;
        
        if (coverageCounter<kLowestAllowedCoverage) { //Less than 5x coverage, report all matches
            posInFoundGenomeCounter = 1;//Must be reset back to 1, so that all matches are reported and copied into the correct position in memory with no gaps in found genome
            for (int a = 0; a < kACGTLen+1; a++) {
                if (charWMostOccs != a) {
                    if (posOccArray[a][i]>0) {  //Character did match, report it
                        if (a<kACGTLen)
                            foundGenome[posInFoundGenomeCounter][i] = acgt[a];
                        else if (a == kACGTLen)
                            foundGenome[posInFoundGenomeCounter][i] = kDelMarker;
                        else if (a == kACGTLen+1)
                            foundGenome[posInFoundGenomeCounter][i] = kInsMarker;
                        posInFoundGenomeCounter++;
                    }
                }
            }
        }
        
        char foundGenomeMatchType = kMatchTypeNoAlignment;
        if (foundGenome[0][i] != kFoundGenomeDefaultChar) {
            if (foundGenome[1][i] != kFoundGenomeDefaultChar)
                foundGenomeMatchType = kMatchTypeHeterozygousNoMutation;
            else
                foundGenomeMatchType = kMatchTypeHomozygousNoMutation;
        }
        foundGenome[kFoundGenomeArrSize-1][i] = foundGenomeMatchType;
        
        posInFoundGenomeCounter = 1;
        coverageCounter = 0;
    }
    
    if (kOnlyPrintFoundGenome == 0) {
        for (int i = 0; i<fileStrLen-1; i++) {
            printf("\nP: %i |R: %c F: %c|  ",i,unravStr[i],foundGenome[0][i]);
            for (int t = 0; t<kACGTwithInDelsLen; t++) {
                if (t<kACGTLen)
                    printf("|%c: %i|  ",acgt[t],posOccArray[t][i]);
                else if (t == kACGTLen)//Deletion (-) THIS IS WHERE IN/DELS ARE DISPLAYED
                    printf("|%c: %i|  ",kDelMarker,posOccArray[t][i]);
                else if (t == kACGTLen+1)//Insertion (+)
                    printf("|%c: %i|",kInsMarker,posOccArray[t][i]);
            }
        }
    }
    if (kOnlyPrintFoundGenome == -3) {
        printf("\n");
        for (int i = 0; i<fileStrLen-1; i++) {
            printf("%c",foundGenome[0][i]);
        }
    }
}


- (NSArray*)findMutationsWithOriginalSeq:(char*)seq {
    NSMutableArray *mutationsArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < strlen(seq); i++) {
        if (coverageArray[i]>=kLowestAllowedCoverage) {
            for (int x = 0; x<kACGTLen+1; x++) {
                if (posOccArray[x][i] >= kHeteroAllowance && acgt[x] != seq[i]) {
                    [mutationsArray addObject:[NSNumber numberWithInt:i]];
                    break;
                }
            }
        }
        else {//Smaller than lowest allowed coverage(5)
            for (int x = 0; x<kACGTLen+1; x++) {
                if (posOccArray[x][i] > 0 && acgt[x] != seq[i]) {
                    [mutationsArray addObject:[NSNumber numberWithInt:i]];
                    break;
                }
            }
        }
    }
    
    return (NSArray*)mutationsArray;
}

- (NSArray*)filterMutationsForDetails {
    NSArray *mutations = [self findMutationsWithOriginalSeq:refStr];
    
    int mutPos;
    
    int mutCounter = 0;
    
    char *mutStr[mutations.count];
    char *heteroStr[mutations.count];
    
    for (int i = 0; i<mutations.count; i++) {
        mutStr[i] = calloc(kACGTwithInDelsLen, 1);
        heteroStr[i] = calloc(kACGTwithInDelsLen, 1);
        strcpy(heteroStr[i], "    ");
    }
    
    
    for (int i = 0; i<mutations.count; i++) {
        int p = [[mutations objectAtIndex:i] intValue];
        if (coverageArray[p]<kLowestAllowedCoverage) {
            for (int a = 0; a<kACGTwithInDelsLen; a++) {
                if (posOccArray[a][p]>0) {
                    mutStr[i][mutCounter] = acgt[a];
                    
                    if (a == kACGTLen)
                        mutStr[i][mutCounter] = kDelMarker;
                    
                    mutCounter++;
                }
            }
        }
        else {
            for (int a = 0; a<kACGTwithInDelsLen; a++) {
                if (posOccArray[a][p]>=kHeteroAllowance) {
                    mutStr[i][mutCounter] = acgt[a];
                    
                    if (a == kACGTLen)
                        mutStr[i][mutCounter] = kDelMarker;
                    
                    mutCounter++;
                    heteroStr[i][a] = acgt[a];
                }
            }
        }
        
        if (mutCounter > 1)
            foundGenome[kFoundGenomeArrSize-1][p] = kMatchTypeHeterozygousMutationNormal;
        else
            foundGenome[kFoundGenomeArrSize-1][p] = kMatchTypeHomozygousMutationNormal;
        
        mutCounter = 0;
    }
    
    if (kOnlyPrintFoundGenome == 0) {
        for (int a = 0; a<mutations.count; a++) {
            mutPos = [[mutations objectAtIndex:a] intValue];
            printf("\n%i-%c-%s",mutPos,refStr[mutPos],mutStr[a]);//MutPos-Original-New//NEED TO DO HETERO (mutPos,originalStr[mutPos],mutStr[a],heteroStr[a])
        }
    }
    
    return NULL;
    //RETURN AN ARRAY OF MUTATION DETAILS (THE ABOVE PRINTF)
}

+ (NSMutableArray*)filteredMutations:(NSArray*)arr
                  forHeteroAllowance:(int)heteroAllowance insertionsArr:(NSArray *)insArr {
    NSMutableArray *finalArr = [[NSMutableArray alloc] init];
    
    int diffCharsAtPos = 0;
    
    char *foundChars = calloc(kACGTwithInDelsLen+1, 1);
    foundChars[kACGTwithInDelsLen] = '\0';
    int posInFoundChars = 0;
    for (int i = 0; i<arr.count; i++) {
        diffCharsAtPos = 0;
        int p = [[arr objectAtIndex:i] intValue];
        for (int a = 0; a<kACGTwithInDelsLen; a++) {
            if (posOccArray[a][p]>0) {
                diffCharsAtPos++;
                foundChars[posInFoundChars] = kACGTwithInDels[a];
                posInFoundChars++;
            }
            foundChars[posInFoundChars] = '\0';
        }
        if (diffCharsAtPos == 1)
            [finalArr addObject:[[MutationInfo alloc] initWithPos:p andRefChar:originalStr[p] andFoundChars:foundChars andDisplayedPos:p andInsertionsArr:insArr heteroAllowance:heteroAllowance]];//Duplicates it so it doesn't overwrite it (same for below)
        else if (coverageArray[p]<kLowestAllowedCoverage) {
            diffCharsAtPos = 0;
            for (int a = 0; a<kACGTwithInDelsLen; a++) {
                if (posOccArray[a][p]>0)
                    diffCharsAtPos++;
                else if (diffCharsAtPos > 1) {
                    [finalArr addObject:[[MutationInfo alloc] initWithPos:p andRefChar:originalStr[p] andFoundChars:foundChars andDisplayedPos:p andInsertionsArr:insArr heteroAllowance:heteroAllowance]];
                    break;
                }
            }
        }
        else {
            diffCharsAtPos = 0;
            posInFoundChars = 0;
            BOOL alreadyAdded = FALSE;

            for (int a = 0; a<kACGTwithInDelsLen; a++) {
                if (posOccArray[a][p]>=heteroAllowance) {
                    diffCharsAtPos++;
                    foundChars[posInFoundChars] = kACGTwithInDels[a];
                    posInFoundChars++;
                }
               /* else if (diffCharsAtPos > 1) {
                    [finalArr addObject:[[MutationInfo alloc] initWithPos:p andRefChar:originalStr[p] andFoundChars:foundChars andDisplayedPos:p]];
                    alreadyAdded = TRUE;
                    break;
                }*/ //I COMMENTED THIS OUT BECAUSE IT LEFT THE LOOP TOO EARLY, BECAUSE WHAT IF diffCharsAtPos == 3 or 4? and the foundChars were A,G,T?
            }
            foundChars[posInFoundChars] = '\0';
            if ((diffCharsAtPos > 1 || foundChars[0] != originalStr[p]) && !alreadyAdded) //We compare foundChars to originalStr because if foundChars has 1 character, then that means at least one other character was also at that position, but that character had an occurence value below the hetero threshold. Also, on a separate note, in case the pos was an insertion, the above for loop wouldn't add it to the finalArr obj, so it is added here
                [finalArr addObject:[[MutationInfo alloc] initWithPos:p andRefChar:originalStr[p] andFoundChars:foundChars andDisplayedPos:p andInsertionsArr:insArr heteroAllowance:heteroAllowance]];
        }
        for (int t = 0; t < kACGTLen + 2; t++) {
            if (foundChars[t] == 0)
                break;
            else
                foundChars[t] = 0;
        }
        
        posInFoundChars = 0;
    }

    free(foundChars);
    return finalArr;
}

+ (NSMutableArray*)compareFoundMutationsArr:(NSArray *)arr toImptMutationsString:(NSString *)imptMutsStr andCumulativeLenArr:(NSMutableArray*)lenArr andSegmentNameArr:(NSMutableArray*)nameArr {
    
    if ([imptMutsStr isEqualToString:@""])
        return nil;
    
    NSMutableArray *imptMutsMutationInfoArr = [[NSMutableArray alloc] init];
    NSArray *lineArr = [[imptMutsStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:kLineBreak];
    
    //Creates mutation info objects for the important muts str

    for (int i = 0; i < [lineArr count]; i++) {
        NSString *str = [lineArr objectAtIndex:i];
        NSArray *componentsArr = [str componentsSeparatedByString:kImptMutsStrComponentSeparator];
        NSString *segName = [componentsArr objectAtIndex:kImptMutsStrSegmentNameIndex];
        int pos = [[componentsArr objectAtIndex:kImptMutsStrPositionIndex] intValue];
        char refChar = [[componentsArr objectAtIndex:kImptMutsStrRefCharIndex] characterAtIndex:0];
        char* foundChars = strdup([[componentsArr objectAtIndex:kImptMutsStrFoundCharIndex] UTF8String]);
        NSString *details = [componentsArr objectAtIndex:kImptMutsStrDescriptionIndex];
        
        ImportantMutationInfo *info = [[ImportantMutationInfo alloc] initWithPos:0 andRefChar:refChar andFoundChars:foundChars andDisplayedPos:pos andInsertionsArr:NULL heteroAllowance:0];
        
        info.genomeName = segName;
        
        for (int j = 0; j < [nameArr count]; j++) {
            NSString *name = [nameArr objectAtIndex:j];
            if ([name isEqualToString:info.genomeName]) {
                info.indexInSegmentNameArr = j;
                break;
            }
        }
        
        if (info.indexInSegmentNameArr > 0)
            info.pos = [[lenArr objectAtIndex:info.indexInSegmentNameArr-1] intValue]+pos-1;//pos-1 because is inputted as position with first spot as 1 not 0
        else
            info.pos = pos-1;
        
        info.details = details;
        [imptMutsMutationInfoArr addObject:info];
    }
    
    NSMutableArray *matches = [[NSMutableArray alloc] init];
    
    for (int j = 0; j < [imptMutsMutationInfoArr count]; j++) {
        BOOL matchAdded = NO;
        ImportantMutationInfo *imptInfo = [imptMutsMutationInfoArr objectAtIndex:j];
        MutationInfo *sameLocMutation;//Used in case impt and recorded have same pos and segment but have diff fnd (in the case of the impt info, mutated) chars
        for (int i = 0; i < [arr count]; i++) {
            MutationInfo *recordedInfo = [arr objectAtIndex:i];
            if (recordedInfo.pos == imptInfo.pos && [[recordedInfo genomeName] isEqualToString:[imptInfo genomeName]])
                sameLocMutation = recordedInfo;
            if ([MutationInfo mutationInfoObjectsHaveSameContents:recordedInfo :imptInfo]) {
                if (strlen(recordedInfo.foundChars) > 1) {
                    foundGenome[kFoundGenomeArrSize-1][recordedInfo.pos] = kMatchTypeHeterozygousMutationImportant;
                    imptInfo.matchType = kMatchTypeHeterozygousMutationImportant;
                }
                else {
                    foundGenome[kFoundGenomeArrSize-1][recordedInfo.pos] = kMatchTypeHomozygousMutationImportant;
                    imptInfo.matchType = kMatchTypeHomozygousMutationImportant;
                }
                [matches addObject:imptInfo];
                matchAdded = YES;
                break;
            }
        }
        if (!matchAdded) {
            if (foundGenome[kFoundGenomeArrSize-1][imptInfo.pos] == kMatchTypeHomozygousNoMutation || foundGenome[kFoundGenomeArrSize-1][imptInfo.pos] == kMatchTypeHeterozygousNoMutation) {
                foundGenome[kFoundGenomeArrSize-1][imptInfo.pos] = kMatchTypeNoMutationImportant;
                imptInfo.matchType = foundGenome[kFoundGenomeArrSize-1][imptInfo.pos];
            }
            else
                imptInfo.matchType = foundGenome[kFoundGenomeArrSize-1][imptInfo.pos];
            [matches addObject:imptInfo];
        }
    }
    
    return matches;
}

@end
