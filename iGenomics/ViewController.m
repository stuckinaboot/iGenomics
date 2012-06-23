//
//  ViewController.m
//  LabProject5
//
//  Created by Stuckinaboot Inc. on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{  
    
    NSMutableString *fileStr = [NSMutableString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"aseq" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
    [fileStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    fileString = calloc(fileStr.length, 1);
    
    strcpy(fileString, [fileStr UTF8String]);
    [fileStr setString:@""];
    
    foundGenome[0] = strdup(fileString);
    
    int fileStrLen = strlen(fileString);
    
    for (int i = 1; i<kACGTLen; i++) {
        foundGenome[i] = calloc(fileStrLen,1);
    }
    
    coverageArray = calloc(fileStrLen, 1);
    
    [self setUpNumberOfOccurencesArray];
    
    char *lastCol = fileString;
    char *firstCol = calloc(strlen(fileString), 1);
    // strcpy(firstCol, lastCol);
    
    firstCol[0] = '$';
    
    int pos = 1;
    for (int x = 0; x<kACGTLen; x++) {
        for (int i = 0; i<acgtTotalOccs[x]; i++) {
            firstCol[pos] = acgt[x];
            pos++;
        }
    }
    
    for (int i = 0; i<kACGTLen; i++) {
        for (int x = 0; x<strlen(fileString); x++) {
            posOccArray[i][x] = 0;
            foundGenome[i][x] = ' ';
        }
    }
    
    char *originalStr = calloc(strlen(fileString), 1);
    strcpy(originalStr, [self unravelCharWithLastColumn:lastCol firstColumn:firstCol]);
    
    /*  NSString *reedsStr = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"reedsFile" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
     
     reedsArray = [[NSMutableArray alloc] initWithArray:[reedsStr componentsSeparatedByString:@"\n"]];
     
     char *sttr;
     for (int i = 0; i<[reedsArray count]; i++) {
     sttr = (char*)[[reedsArray objectAtIndex:i] UTF8String];
     [self approxiMatchForQuery:sttr withLastCol:lastCol andFirstCol:firstCol];
     }*/
    
    //    printf("%s",originalStr);
    /* NSArray *array = [self exactMatchForQuery:"GATTACA\0" withLastCol:lastCol andFirstCol:firstCol];
     
     for (int i = 0; i<[array count]; i++) {
     printf("POS: %i\n",[[array objectAtIndex:i] intValue]);
     }*/
    
    /*NSArray *array = [self approxiMatchForQuery:"GATTACA\0" withLastCol:lastCol andFirstCol:firstCol];
     //    [self buildOccTableWithUnravStr:originalStr];
     [self sortArrayUsingQuicksort:(NSMutableArray*)array withStartPos:0 andEndPos:[array count]-1];
     
     for (int i = 0; i<[array count]; i++) {
     
     int posit = [[array objectAtIndex:i] intValue];
     
     char *subStr = calloc(50, 1);
     subStr = substr(originalStr, posit,7);
     
     //                printf("\nPOS: %i: %s $",posit,subStr);
     printf("\n%i",posit);
     }
     //    for (int x = 0; x<kACGTLen; x++) {
     //        for (int i = 0; i<strlen(originalStr); i++) {
     //            printf("%c: %i ",acgt[x],posOccArray[x][i]);
     //        }
     //    }
     */
    [self matchReedsArray:[self reedsArrayForFileName:@"reeds" andExt:@"txt"] withLastCol:lastCol andFirstCol:firstCol];
    
    NSArray *mutations = [self findMutationsWithOriginalSeq:originalStr];
    
    [self buildOccTableWithUnravStr:originalStr];
    
    int mutPos;
    
    int mutCounter = 0;
    
    char *mutStr[mutations.count];
    char *heteroStr[mutations.count];
    
    for (int i = 0; i<mutations.count; i++) {
        mutStr[i] = calloc(kACGTLen, 1);
        heteroStr[i] = calloc(kACGTLen, 1);
        strcpy(heteroStr[i], "    ");
    }
    
    for (int i = 0; i<mutations.count; i++) {
        int p = [[mutations objectAtIndex:i] intValue];
        int charWMostOccs = 0;
        
        BOOL lessThan5XCoverage = FALSE;
        
        for (int a = 0; a<kACGTLen; a++) {
            printf("\n%i\n",coverageArray[p]);
            if (coverageArray[p]<kLowestAllowedCoverage) {
                lessThan5XCoverage = TRUE;
                if (posOccArray[a][i]>0) {
                    mutStr[i][mutCounter] = foundGenome[a][p];
                    mutCounter++;
                }
            }
            else {
                lessThan5XCoverage = FALSE;
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
                
//                mutStr[i][mutCounter] = foundGenome[0][p];
//                mutCounter++;
            }
            if (posOccArray[a][p]>0) {
//                mutStr[i][mutCounter] = acgt[a];
//                mutCounter++;
                if (posOccArray[a][p]>kHeteroAllowance) {
                    mutStr[i][mutCounter] = acgt[a];
                    mutCounter++;
                    //                    foundGenome[a][p] = acgt[a];
                    heteroStr[i][a] = acgt[a];
                }
            }
        }
        
        if (!lessThan5XCoverage) {
            if (acgt[charWMostOccs] != originalStr[i]) {
                mutStr[i][mutCounter] = acgt[charWMostOccs];
                mutCounter++;
            }
        }
        
        charWMostOccs = 0;
        mutCounter = 0;
    }
    /*
     for (int i = 0; i<kACGTLen; i++) {
     for (int a = 0; a<fileStrLen; a++) {
     if (foundGenome[i][a] != ' ') {
     if (i>0) {
     if (mutStr[i-1] != foundGenome[i][a]) {
     mutStr[i] = foundGenome[i][a];
     }
     }
     else {
     mutStr[i] = foundGenome[i][a];
     }
     }
     }
     }*/
    printf("\n");/*
                  for (int i = 0; i<kACGTLen; i++) {
                  printf("%s\n",foundGenome[i]);
                  }*/
    
    for (int a = 0; a<mutations.count; a++) {
        mutPos = [[mutations objectAtIndex:a] intValue];
        printf("\n%i-%c-%s",mutPos,originalStr[mutPos],mutStr[a]);//MutPos-Original-New//NEED TO DO HETERO (mutPos,originalStr[mutPos],mutStr[a],heteroStr[a])
    }
    
    //    printf("%i",[[[self approxiMatchForQuery:"TACC" withLastCol:lastCol andFirstCol:firstCol] objectAtIndex:0] intValue]);
    
    [super viewDidLoad];
}

- (void)matchReedsArray:(NSArray *)array withLastCol:(char*)lastCol andFirstCol:(char*)firstCol {
    char *reed;
    
    char *originalStr = calloc(strlen(lastCol), 1);
    strcpy(originalStr,  [self unravelCharWithLastColumn:lastCol firstColumn:firstCol]);
    
    for (int i = 0; i < array.count; i++) {
        reed = (char*)[[array objectAtIndex:i] UTF8String];
        
        int a = [self getBestMatchForQuery:reed withLastCol:lastCol andFirstCol:firstCol andNumOfSubs:kNumOfSubs];
        
        if (a > -1) {
            //a matched
            [self updatePosOccsArrayWithRange:NSMakeRange(a, strlen(reed)) andOriginalStr:originalStr andQuery:reed];//a-1 because $ is first
        }
        
        //        reed = (char*)[[array objectAtIndex:i] UTF8String];
    }
    
}

- (NSArray*)findMutationsWithOriginalSeq:(char*)seq {
    NSMutableArray *mutationsArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < strlen(seq); i++) {
        for (int x = 0; x<kACGTLen; x++) {
            if (posOccArray[x][i] > 0 && acgt[x] != seq[i]) {
                [mutationsArray addObject:[NSNumber numberWithInt:i]];
                break;
            }
        }
    }
    
    return (NSArray*)mutationsArray;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma UNRAVEL

- (char*)unravelCharWithLastColumn:(char*)lastColumn firstColumn:(char*)firstColumn {
    int i = 0;//index
    int pos = strlen(fileString)-1;
    int occurence = 1;//1 = 1st, etc.
    char *unraveledChar = calloc(strlen(fileString), 1);
    char lastChar = lastColumn[i];
    
    // strcpy(unraveledChar+1, unraveledChar);
    unraveledChar[pos] = lastChar;
    
    i = [self getIndexOfNth:occurence OccurenceOfChar:lastChar inChar:firstColumn];
    
    // printf("%s\n",unraveledChar);
    
    while (strlen(unraveledChar)<strlen(lastColumn)) {
        pos--;
        //Add lastChar to beginning of unraveledChar
        lastChar = lastColumn[i];
        
        // strcpy(unraveledChar+1, unraveledChar);
        // unraveledChar[0] = lastChar;
        unraveledChar[pos] = lastChar;
        
        //   printf("%s\n",unraveledChar);
        
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
        //        occurences+=[[[numberOfOccurencesArray objectAtIndex:i] objectAtIndex:whichChar] intValue];
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
        endPos = strlen(fileString);
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
    int pos = strlen(fileString)-1;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
- (void)setUpNumberOfOccurencesArray {
    int len = strlen(fileString);
    
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
                if (acgt[x] == fileString[i]) {
                    occurences[x]++;
                }
            }
            if (i == pos) {
                for (int l = 0; l<kACGTLen; l++) {
                    acgtOccurences[spotInACGTOccurences][l] = occurences[l];
                }
                spotInACGTOccurences++;
                //                [numberOfOccurencesArray addObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:occurences[0]],[NSNumber numberWithInt:occurences[1]],[NSNumber numberWithInt:occurences[2]],[NSNumber numberWithInt:occurences[3]], nil]];
                for (int x = 0; x<kACGTLen; x++) {
                    occurences[x] = 0;
                }
                pos += kMultipleToCountAt;
            }
            for (int x = 0; x<kACGTLen; x++) {
                if (acgt[x] == fileString[i]) {
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
            //            chunks[i] = calloc(34, 1);
            if (i < numOfChunks-1) {
                strcpy(chunks[i].string, strcat(substr(query, start, sizeOfChunks),"\0"));
            }
            else {
                strcpy(chunks[i].string, strcat(substr(query, start, sizeOfChunks+1),"\0"));
            }
            start += sizeOfChunks;
        }
        
        //        if (kDebugON > 0) {
        for (int i = 0; i<numOfChunks; i++) {
            printf("%s\n",chunks[i].string);
        }
        //        }
        //    NSLog(@"%s, %s, %s",chunks[0],chunks[1],chunks[2]);
        
        //    printf("%s, %s, %s",chunks[0],chunks[1],chunks[2]);
        int charsToCheckRight = 0;
        int charsToCheckLeft = 0;
        
        int counter = 0;
        
        //        char *leftStr = calloc(50, 1);
        //        char *rightStr = calloc(50, 1);
        
        int numOfSubstitutions = 0;
        
        for (int i = 0; i<numOfChunks; i++) {
            chunks[i].matchedPositions = (NSMutableArray*)[self exactMatchForQuery:chunks[i].string withLastCol:lastCol andFirstCol:firstCol];
            
            for (int x = 0; x<[chunks[i].matchedPositions count]; x++) {
                counter++;
                //                printf("%i\n",counter);
                if (i>0 && i<numOfChunks-1) {
                    charsToCheckLeft = (i)*sizeOfChunks;//i+1?
                    charsToCheckRight = (numOfChunks-(i+2))*sizeOfChunks;
                    if (strlen(query)%2 != 0) {
                        //ODD
                        //                    charsToCheckRight-= (numOfChunks*sizeOfChunks)-strlen(query);
                        charsToCheckRight++;
                    }
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
                
                
                //                int po22s = [[chunks[i].matchedPositions objectAtIndex:x] intValue] - i*sizeOfChunks;//QUESTIONABLE HERE
                //                if (po22s == 69905) {
                //                    printf("");
                //                }
                
                for (int l = 0; l<charsToCheckLeft; l++) {
                    if (originalStr[l+leftStrStart] != query[l]) {
                        numOfSubstitutions++;
                        subsInChunk[numOfChunks-(int)floorf((float)(l/sizeOfChunks)+1)-(numOfChunks-i-1)-1]++;//orignially no numofchunk or -1
                    }
                }
                
                if (rightStrStart>=strlen(originalStr)-1) {
                    charsToCheckRight = 0;
                }
                for (int l = 0; l<charsToCheckRight; l++) {
                    //                    printf("\n%c, %c", originalStr[l+rightStrStart],query[(i+1)*sizeOfChunks+l]);//-1
                    if (originalStr[l+rightStrStart] != query[(i+1)*sizeOfChunks+l]) {//-1
                        numOfSubstitutions++;
                        
                        subsInChunk[(int)floorf((float)l/sizeOfChunks)+1+i]++;
                        
                        if (numOfSubstitutions > amtOfSubs) {
                            break;
                        }
                    }
                }
                if (numOfSubstitutions<=amtOfSubs) {
                    //                printf("\n%i",[[matchedChunks[i] objectAtIndex:x] intValue]);
                    NSMutableArray *array = [[NSMutableArray alloc] init];
                    for (int r = 0; r<numOfChunks; r++) {
                        [array addObject:[NSNumber numberWithInt:subsInChunk[r]]];
                    }
                    
                    if ([self isNotDuplicateAlignment:array andChunkNum:i]) {
                        int pos = [[chunks[i].matchedPositions objectAtIndex:x] intValue] - i*sizeOfChunks;//QUESTIONABLE HERE
                        
                        if (pos+strlen(query)<=strlen(fileString)) {
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
    else {
        positionsArray = (NSMutableArray*)[self exactMatchForQuery:query withLastCol:lastCol andFirstCol:firstCol];
        /*int p = 0;
         for (int i = 0; i<[positionsArray count]; i++) {
         p = [[positionsArray objectAtIndex:i] intValue];
         //            int a = strlen(query);
         //            printf("%i",a);
         [self updatePosOccsArrayWithRange:NSMakeRange(p, strlen(query)) andOriginalStr:originalStr andQuery:query]; ____________SAME HERE
         }*/
    }
    //IN PROGRESS
    //
    return positionsArray;
}

- (int)getBestMatchForQuery:(char*)query withLastCol:(char*)lastCol andFirstCol:(char*)firstCol andNumOfSubs:(int)amtOfSubs {
    
    NSArray *arr = [[NSMutableArray alloc] init];
    
    for (int x = 0; x < amtOfSubs+1; x++) {
        arr = [self approxiMatchForQuery:query withLastCol:lastCol andFirstCol:firstCol andNumOfSubs:x];
        
        arr = [arr arrayByAddingObjectsFromArray:[self approxiMatchForQuery:[self getReverseComplementForSeq:query] withLastCol:lastCol andFirstCol:firstCol andNumOfSubs:x]];
        
        if ([arr count] > 0) {
            int v = [[arr objectAtIndex:(int)arc4random()%[arr count]] intValue];
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
    //  printf("Start Pivot: %i, FirstPos: %i, EndPos: %i \n",pivotPos,firstPos,lastPos);
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
    //    printf("End Pivot: %i, StartPos: %i, FirstPos: %i, EndPos: %i LastPos: %i \n",pivotPos,startPos, firstPos, endpos, lastPos);
    if (startPos<lastPos) {//Lastpos is one to left of median
        [self sortArrayUsingQuicksort:array withStartPos:startPos andEndPos:lastPos];
    }
    if (firstPos<endpos) {//firstpos is one to right of median
        [self sortArrayUsingQuicksort:array withStartPos:firstPos andEndPos:endpos];
    }
}

- (void)buildOccTableWithUnravStr:(char*)unravStr {
    for (int i = 0; i<strlen(fileString)-1; i++) {
        printf("  %c",unravStr[i]);
    }
    printf("\n");
    for (int i = 0; i<strlen(fileString)-1; i++) {
        printf("  %i",i);
    }
    printf("\n");
    for (int i = 0; i<kACGTLen; i++) {
        printf("\n%c ",acgt[i]);
        for (int a = 0; a<strlen(fileString)-1; a++) {
            printf("%i  ",posOccArray[i][a]);
        }
    }
    printf("\n\n");
    
    int charWMostOccs;//0,1,2,3 etc. -> A, C, G, T etc.
    int posInFoundGenomeCounter = 1;
    int coverageCounter = 0;
    
    for (int i = 0; i<strlen(fileString)-1; i++) {
        for (int a = 0; a < kACGTLen; a++) {
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
        if (i>0) {//0 is $ sign
            foundGenome[0][i] = acgt[charWMostOccs];
        }
        
        for (int a = 0; a < kACGTLen; a++) {
            if (posOccArray[a][i]>0) { //Character did match, at least 1x coverage was found
                coverageCounter += posOccArray[a][i];
            }
            if (charWMostOccs != a) {
                if (posOccArray[a][i]>kHeteroAllowance) {
                    foundGenome[posInFoundGenomeCounter][i] = acgt[a];
                    posInFoundGenomeCounter++;
                }
            }
        }
        
        if (coverageCounter<kLowestAllowedCoverage) { //Less than 5x coverage, report all matches
            for (int a = 0; a < kACGTLen; a++) {
                if (charWMostOccs != a) {
                    if (posOccArray[a][i]>0) {  //Character did match, report it
                        foundGenome[posInFoundGenomeCounter][i] = acgt[a];
                        posInFoundGenomeCounter++;
                    }
                }
            }
        }
        
        coverageArray[i] = coverageCounter;
//        printf("\n%i\n",coverageArray[i]);
        posInFoundGenomeCounter = 1;
        coverageCounter = 0;
    }
    
    /* for (int i = 0; i<strlen(fileString)-1; i++) {
     printf("  %c",foundGenome[0][i]);
     }*/
    /*  for (int i = 1; i<kACGTLen; i++) {
     for (int a = 0; a<strlen(fileString)-1; a++) {
     printf("  %c",foundGenome[i][a]);
     }
     printf("\n");
     }*/
}

- (NSArray*)reedsArrayForFileName:(NSString*)name andExt:(NSString*)ext {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:ext];
    NSString *file = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    return [file componentsSeparatedByString:@"\n"];
}

- (char*)getReverseComplementForSeq:(char*)seq {
    int len = strlen(seq);
    char *revSeq = calloc(len, 1);
    
    for (int i = 0; i<len; i++) {
        revSeq[len-i-1] = acgt[3-[self whichChar:seq[i] inContainer:acgt]];//len-i-1 because that allows for 0th pos to be set rather than just last pos to be set is 1
    }
    
    return revSeq;
}
@end
