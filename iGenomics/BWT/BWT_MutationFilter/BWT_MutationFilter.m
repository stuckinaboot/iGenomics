//
//  BWT_MutationFilter.m
//  LabProject7
//
//  Created by Stuckinaboot Inc. on 9/15/12.
//
//

#import "BWT_MutationFilter.h"

char *foundGenome[kACGTLen+2];
int coverageArray[kMaxBytesForIndexer*kMaxMultipleToCountAt];

@implementation BWT_MutationFilter

@synthesize kHeteroAllowance;

- (void)setUpMutationFilterWithOriginalStr:(char*)originalSeq andMatcher:(BWT_Matcher*)myMatcher {
    acgt = strdup(kACGTStr);
    refStr = strdup(originalSeq);
    fileStrLen = strlen(refStr);
    
    for (int i = 0; i<kACGTLen+2; i++) {
        foundGenome[i] = calloc(fileStrLen,1);
    }
    
    for (int i = 0; i<kACGTLen+2; i++) {
        for (int x = 0; x<fileStrLen; x++) {
            foundGenome[i][x] = ' ';
        }
    }
    
    strcpy(foundGenome[0], refStr);
    
    matcher = myMatcher;
//    [self setUpPosOccArray];
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
        for (int a = 0; a < kACGTLen+2; a++) {
            
            if (posOccArray[a][i]>0 /*&& a < kACGTLen+1*/) { //Character did match, at least 1x coverage was found, and not an insertion
                coverageCounter += posOccArray[a][i];
            }
            
            if (a == 0) {
                charWMostOccs = 0;
            }
            else if (posOccArray[a][i]>posOccArray[charWMostOccs][i]) {//Greater
                charWMostOccs = a;
            }
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
            /*else if (charWMostOccs == kACGTLen+1)
                foundGenome[0][i] = kInsMarker;*/
        }
        for (int a = 0; a <= kACGTLen+1; a++) {
            if (charWMostOccs != a) {
                if (posOccArray[a][i]>kHeteroAllowance) {
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
        
        posInFoundGenomeCounter = 1;
        coverageCounter = 0;
    }
    
    if (kOnlyPrintFoundGenome == 0) {
        for (int i = 0; i<fileStrLen-1; i++) {
            printf("\nP: %i |R: %c F: %c|  ",i,unravStr[i],foundGenome[0][i]);
            for (int t = 0; t<kACGTLen+2; t++) {
                if (t<kACGTLen)
                    printf("|%c: %i|  ",acgt[t],posOccArray[t][i]);
                else if (t == kACGTLen)//Deletion (-) THIS IS WHERE IN/DELS ARE DISPLAYED
                    printf("|%c: %i|  ",kDelMarker,posOccArray[t][i]);
                else if (t == kACGTLen+1)//Insertion (+)
                    printf("|%c: %i|",kInsMarker,posOccArray[t][i]);
            }
        }
    }
    if (kOnlyPrintFoundGenome<0) {
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
                if (posOccArray[x][i] > kHeteroAllowance && acgt[x] != seq[i]) {
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
        mutStr[i] = calloc(kACGTLen+2, 1);
        heteroStr[i] = calloc(kACGTLen+2, 1);
        strcpy(heteroStr[i], "    ");
    }
    
    
    for (int i = 0; i<mutations.count; i++) {
        int p = [[mutations objectAtIndex:i] intValue];
        if (coverageArray[p]<kLowestAllowedCoverage) {
            for (int a = 0; a<kACGTLen+2; a++) {
                if (posOccArray[a][p]>0) {
                    mutStr[i][mutCounter] = acgt[a];
                    
                    if (a == kACGTLen)
                        mutStr[i][mutCounter] = kDelMarker;
                    
                    mutCounter++;
                }
            }
        }
        else {
            for (int a = 0; a<kACGTLen+2; a++) {
                if (posOccArray[a][p]>kHeteroAllowance) {
                    mutStr[i][mutCounter] = acgt[a];
                    
                    if (a == kACGTLen)
                        mutStr[i][mutCounter] = kDelMarker;
                    
                    mutCounter++;
                    heteroStr[i][a] = acgt[a];
                }
            }
        }
        mutCounter = 0;
    }
    
    printf("\n");
    
    if (kOnlyPrintFoundGenome == 0) {
        for (int a = 0; a<mutations.count; a++) {
            mutPos = [[mutations objectAtIndex:a] intValue];
            printf("\n%i-%c-%s",mutPos,refStr[mutPos],mutStr[a]);//MutPos-Original-New//NEED TO DO HETERO (mutPos,originalStr[mutPos],mutStr[a],heteroStr[a])
        }
    }
    return NULL;
    //RETURN AN ARRAY OF MUTATION DETAILS (THE ABOVE PRINTF)
}
@end
