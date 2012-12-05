//
//  EditDistance.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 10/15/12.
//
//

#import "EditDistance.h"

@implementation EditDistance

@synthesize charA,charB, distance;

- (id)init {
    charA = calloc(kDefaultEditDistStrSize, 1);
    charB = calloc(kDefaultEditDistStrSize, 1);
    return self;
}

- (void)computeEditDistance:(char *)a andB:(char *)b lenA:(int)lenA andLenB:(int)lenB andEditDistForCell:(CGPoint)cellpos {
    
    int editDistanceTable[lenA][lenB];
    int arrowTable[lenA][lenB];//0 is left, 1 is diag, 2 is up, 3 is created
    int gapsInA = 0, gapsInB = 0;
    
    for (int i = 0; i<lenA; i++) {
        for (int j = 0; j<lenB; j++) {
            if (i == 0) {
                editDistanceTable[i][j] = j;
                arrowTable[i][j] = 3;
            }
            else if (j == 0) {
                editDistanceTable[i][j] = i;
                arrowTable[i][j] = 3;
            }
            else {
                int min = editDistanceTable[i-1][j]+1;
                arrowTable[i][j] = 2;
                
                int possibleMin = editDistanceTable[i][j-1]+1;
                if (possibleMin<min) {
                    min = possibleMin;
                    arrowTable[i][j] = 0;
                }
                
                possibleMin = editDistanceTable[i-1][j-1] + ((a[i] == b[j]) ? 0 : 1);
                if (possibleMin<=min) {
                    min = possibleMin;
                    arrowTable[i][j] = 1;
                }
                
                editDistanceTable[i][j] = min;
            }
        }
    }
    
    distance = editDistanceTable[(int)cellpos.x-1][(int)cellpos.y-1];

    int i = lenA-1;
    int j = lenB-1;
    
    while (i > 0 || j > 0) {
        if (arrowTable[i][j] == 0) {
            j -= 1;
            gapsInA++;
        }
        else if (arrowTable[i][j] == 2) {
            i -= 1;
            gapsInB++;
        }
        else if (arrowTable[i][j] == 1) {
            i -= 1;
            j -= 1;
        }
        else if (arrowTable[i][j] == 3) {
            if (i>0) {
                gapsInB += i;
            }
            else if (j>0) {
                gapsInA += j;
            }
            break;
        }
    }
    
    int gappedLength = (lenA+gapsInA>lenB+gapsInB) ? lenA+gapsInA : lenB+gapsInB;
    charA[gappedLength] = '\0';
    charB[gappedLength] = '\0';
    int pos = gappedLength-2;//Check -2, but it is because subtracting the space in the beginning " GA..." and gets to the last position
    
    i = lenA-1;
    j = lenB-1;

    while (i > 0 || j > 0) {
        if (arrowTable[i][j] == 0) {
            charA[pos] = '-';
            charB[pos] = b[j];
            j -= 1;
        }
        else if (arrowTable[i][j] == 2) {
            charB[pos] = '-';
            charA[pos] = a[i];
            i -= 1;
        }
        else if (arrowTable[i][j] == 1) {
            charA[pos] = a[i];
            charB[pos] = b[j];
            i -= 1;
            j -= 1;
        }
        else if (arrowTable[i][j] == 3) {
            if (i>0) {
                for (int t = 0; t<i; t++) {
                    charA[pos] = a[i-t];
                    charB[pos] = '-';
                    pos--;
                }
            }
            else if (j>0) {
                for (int t = 0; t<j; t++) {
                    charA[pos] = '-';
                    charB[pos] = b[j-t];
                    pos--;
                }
            }
            break;
        }
        pos--;
    }
    printf("");
}

- (ED_Info*)editDistanceForInfo:(char *)a andB:(char *)b andChunkNum:(int)chunkNum andChunkSize:(int)chunkSize andMaxED:(int)maxED {
    int lenA = strlen(a), lenB = strlen(b);
    int editDistanceTable[lenA][lenB];
    int arrowTable[lenA][lenB];//0 is left, 1 is diag, 2 is up, 3 is created
    int gapsInA = 0, gapsInB = 0;
    
    for (int i = 0; i<lenA; i++) {
        for (int j = 0; j<lenB; j++) {
            if (i == 0) {
                editDistanceTable[i][j] = 0;//j
                arrowTable[i][j] = 3;
            }
            else if (j == 0) {
                editDistanceTable[i][j] = i;
                arrowTable[i][j] = 2;
            }
            else {
                if (i == lenA-1 && j == lenB-1) {
                    printf("");
                }
                int min = editDistanceTable[i-1][j]+1;
                arrowTable[i][j] = 2;
                
                int possibleMin = editDistanceTable[i][j-1]+1;
                if (possibleMin<min) {
                    min = possibleMin;
                    arrowTable[i][j] = 0;
                }
                
                possibleMin = editDistanceTable[i-1][j-1] + ((a[i] == b[j]) ? 0 : 1);
                if (possibleMin<=min) {
                    min = possibleMin;
                    arrowTable[i][j] = 1;
                }
                
                editDistanceTable[i][j] = min;
            }
        }
    }
    
    int i = lenA-1;
    int j = lenB-1;
    
    while (i > 0 || j > 0) {
        if (arrowTable[i][j] == 0) {
            j -= 1;
            gapsInA++;
        }
        else if (arrowTable[i][j] == 2) {
            i -= 1;
            gapsInB++;
        }
        else if (arrowTable[i][j] == 1) {
            i -= 1;
            j -= 1;
        }
        else if (arrowTable[i][j] == 3) {
            if (i>0) {
                gapsInB += i;
            }
            else if (j>0) {
                gapsInA += j;
            }
            break;
        }
    }
    
    //ED = Edit Distance, Starts out being smallestEditDistance than becomes the pos of smallest edit distance
    int smallestED = editDistanceTable[lenA-1][0];//-2 to account for ' ' in beginning
    int smallestEDPos = 0;
    
    for (int t = 0; t<lenB; t++) {
        smallestED = MIN(editDistanceTable[lenA-1][t], smallestED);
        if (smallestED == editDistanceTable[lenA-1][t]) {
            smallestEDPos = t;
        }
        if (smallestED == 0) {
            smallestEDPos = t;
            break;
        }
    }
    
    int gappedLength =/* (lenA+gapsInA>lenB+gapsInB) ? lenA+gapsInA :*/ smallestEDPos+smallestED;//previously smallestEDPos+gapsInB
    charA[gappedLength] = '\0';
    charB[gappedLength] = '\0';
    int pos = gappedLength-1;//Check -2, but it is because subtracting the space in the beginning " GA..." and gets to the last position
    /*
    for (int r = 0; r<lenA; r++) {
        for (int c = 0; c<lenB; c++) {
            printf("%i ",editDistanceTable[r][c]);
        }
        printf("\n");
    }
    printf("\n");
    
    for (int r = 0; r<lenA; r++) {
        for (int c = 0; c<lenB; c++) {
            printf("%i ",arrowTable[r][c]);
        }
        printf("\n");
    }
    printf("\n");
    */
    i = lenA-1;
    j = smallestEDPos;
    
    while (i > 0 || j > 0) {
        if (arrowTable[i][j] == 0) {
            charA[pos] = '-';
            charB[pos] = b[j];
            j -= 1;
        }
        else if (arrowTable[i][j] == 2) {
            charB[pos] = '-';
            charA[pos] = a[i];
            i -= 1;
        }
        else if (arrowTable[i][j] == 1) {
            charA[pos] = a[i];
            charB[pos] = b[j];
            i -= 1;
            j -= 1;
        }
        else if (i == 0)
            break;
        
        pos--;
        
        if (pos == 0 && !(i>0 || j>0)) {
            charA[pos] = a[i];
            charB[pos] = b[j];
        }
    }
    
    
    
    ED_Info *edInfo = [[ED_Info alloc] init];
    
    if (chunkNum == 0) {
        edInfo.position = pos;//0
    }
    else {
        edInfo.position = pos;//Not positive about this
    }
    
    edInfo.distance = smallestED;
    
//    Properly shift gappedA and gappedB to remove extra chars
    edInfo.gappedA = calloc(gappedLength-j, 1);
    memcpy(edInfo.gappedA, charA+j, gappedLength-j);
    edInfo.gappedB = calloc(gappedLength-j, 1);
    memcpy(edInfo.gappedB, charB+j, gappedLength-j);
    
    return edInfo;
}

/*
- (void)findInDels:(char *)a andB:(char *)b lenA:(int)lenA andLenB:(int)lenB andChunks:(NSMutableArray*)chunkArray {
    int editDistanceTable[lenA][lenB];
    int arrowTable[lenA][lenB];//0 is left, 1 is diag, 2 is up, 3 is created
    int gapsInA = 0, gapsInB = 0;
    
    for (int i = 0; i<lenA; i++) {
        for (int j = 0; j<lenB; j++) {
            if (i == 0) {
                editDistanceTable[i][j] = 0;//j
                arrowTable[i][j] = 3;
            }
            else if (j == 0) {
                editDistanceTable[i][j] = i;
                arrowTable[i][j] = 3;
            }
            else {
                int min = editDistanceTable[i-1][j]+1;
                arrowTable[i][j] = 2;
                
                int possibleMin = editDistanceTable[i][j-1]+1;
                if (possibleMin<min) {
                    min = possibleMin;
                    arrowTable[i][j] = 0;
                }
                
                possibleMin = editDistanceTable[i-1][j-1] + ((a[i] == b[j]) ? 0 : 1);
                if (possibleMin<=min) {
                    min = possibleMin;
                    arrowTable[i][j] = 1;
                }
                
                editDistanceTable[i][j] = min;
            }
        }
    }
    
    int i = lenA-1;
    int j = lenB-1;
    
    while (i > 0 || j > 0) {
        if (arrowTable[i][j] == 0) {
            j -= 1;
            gapsInA++;
        }
        else if (arrowTable[i][j] == 2) {
            i -= 1;
            gapsInB++;
        }
        else if (arrowTable[i][j] == 1) {
            i -= 1;
            j -= 1;
        }
        else if (arrowTable[i][j] == 3) {
            if (i>0) {
                gapsInB += i;
            }
            else if (j>0) {
                gapsInA += j;
            }
            break;
        }
    }
    
    //ED = Edit Distance, Starts out being smallestEditDistance than becomes the pos of smallest edit distance
    int smallestED = editDistanceTable[lenA-1][0];
    int smallestEDPos = 0;
    
    for (int t = 0; t<lenB; t++) {
        smallestED = MIN(editDistanceTable[lenA-1][t], smallestED);
        if (smallestED == editDistanceTable[lenA-1][t]) {
            smallestEDPos = t;
        }
        if (smallestED == 0) {
            smallestEDPos = t;
            break;
        }
    }
    
    int gappedLength = **(lenA+gapsInA>lenB+gapsInB) ? lenA+gapsInA :** smallestEDPos+gapsInB;
    charA[gappedLength] = '\0';
    charB[gappedLength] = '\0';
    int pos = gappedLength;//Check -2, but it is because subtracting the space in the beginning " GA..." and gets to the last position
    
    for (int r = 0; r<lenA; r++) {
        for (int c = 0; c<lenB; c++) {
            printf("%i ",editDistanceTable[r][c]);
        }
        printf("\n");
    }
    
    i = lenA-1;
    j = smallestEDPos;
    
    while (i > 0 || j > 0) {
        if (arrowTable[i][j] == 0) {
            charA[pos] = '-';
            charB[pos] = b[j];
            j -= 1;
        }
        else if (arrowTable[i][j] == 2) {
            charB[pos] = '-';
            charA[pos] = a[i];
            i -= 1;
        }
        else if (arrowTable[i][j] == 1) {
            charA[pos] = a[i];
            charB[pos] = b[j];
            i -= 1;
            j -= 1;
        }
        else if (i == 0)
            break;
        
        pos--;
    }
    
//    At this point the pos variable is the start position of the matched sequence, and it (pos) will remain equal to that.....ALSO: Use 't' or 'r' in for loops instead of i
    Chunks *chunks[[chunkArray count]];
    int chunkLens[[chunkArray count]];
    
    for (int t = 0; t<[chunkArray count]; t++) {
        chunks[t] = [chunkArray objectAtIndex:t];
        chunkLens[t] = strlen(chunks[t].string);
    }
    
    NSMutableArray *fullyMatchedArr = [[NSMutableArray alloc] init];
    
//    Matching Chunk 1
    for (int t = 0; t<[chunks[0].matchedPositions count]; t++) {

    }
    
//    Matching Chunk 2 to amtOfChunks-1
    for (int t = 0; t<[chunks[1].matchedPositions count]; t++) {

    }
    
//    Matching Final Chunk
    for (int t = 0; t<[chunks[2].matchedPositions count]; t++) {

    }
    printf("");
}

- (ED_Info*)simpleEditDistance:(char *)a andB:(char *)b {
    int lenA = strlen(a);
    int lenB = strlen(b);
    
    int editDistanceTable[lenA][lenB];
    
    for (int i = 0; i<lenA; i++) {
        for (int j = 0; j<lenB; j++) {
            if (i == 0) {
                editDistanceTable[i][j] = 0;//j
            }
            else if (j == 0) {
                editDistanceTable[i][j] = i;
            }
            else {
                int min = editDistanceTable[i-1][j]+1;
                
                int possibleMin = editDistanceTable[i][j-1]+1;
                if (possibleMin<min) {
                    min = possibleMin;
                }
                
                possibleMin = editDistanceTable[i-1][j-1] + ((a[i] == b[j]) ? 0 : 1);
                if (possibleMin<=min) {
                    min = possibleMin;
                }
                
                editDistanceTable[i][j] = min;
            }
        }
    }
    
    int smallestED = editDistanceTable[lenA-1][0];
    int smallestEDPos = 0;
    
    for (int t = 0; t<lenB; t++) {
        smallestED = MIN(editDistanceTable[lenA-1][t], smallestED);
        if (smallestED == editDistanceTable[lenA-1][t]) {
            smallestEDPos = t;
        }
        if (smallestED == 0) {
            smallestEDPos = t;
            break;
        }
    }

    return editDistanceTable[lenA-1][smallestEDPos];
}
*/
char *substring(const char *pstr, int start, int numchars)
{
    char *pnew = malloc(numchars+1);
    strncpy(pnew, pstr + start, numchars);
    pnew[numchars] = '\0';
    return pnew;
}
@end
