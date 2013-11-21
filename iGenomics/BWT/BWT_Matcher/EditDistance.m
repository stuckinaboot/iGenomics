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
    return self;
}

- (ED_Info*)editDistanceForInfo:(char *)a andBFull:(char *)b andRangeOfActualB:(NSRange)range andChunkNum:(int)chunkNum andChunkSize:(int)chunkSize andMaxED:(int)maxED {
    int lenA = strlen(a), lenB = range.length+1;//First char (range.location-1) will be a "space"
    
    ED_Info *edInfo = [[ED_Info alloc] init];
    edInfo.gappedA = calloc(kDefaultEditDistStrSize, 1);
    edInfo.gappedB = calloc(kDefaultEditDistStrSize, 1);
    
    
    int editDistanceTable[lenA][lenB];
    int arrowTable[lenA][lenB];//0 is left, 1 is diag, 2 is up, 3 is created
    int gapsInA = 0, gapsInB = 0;
    
    for (int i = 0; i<lenA; i++) {
        for (int j = 0; j<lenB; j++) {
            if (i == 0) {
                editDistanceTable[i][j] = 0;//j
                arrowTable[i][j] = kInitialize;
            }
            else if (j == 0) {
                editDistanceTable[i][j] = i;
                arrowTable[i][j] = kUp;
            }
            else {
                int min = editDistanceTable[i-1][j-1] + ((a[i] == b[range.location+j-1]) ? 0 : 1);
                arrowTable[i][j] = kDiag;
                
                int possibleMin = editDistanceTable[i][j-1]+1;
                if (possibleMin < min) {
                    min = possibleMin;
                    arrowTable[i][j] = kLeft;
                }
                
                possibleMin = editDistanceTable[i-1][j]+1;
                if (possibleMin < min) {
                    min = possibleMin;
                    arrowTable[i][j] = kUp;
                }
                
                editDistanceTable[i][j] = min;
            }
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
    
    int i = lenA-1;
    int j = smallestEDPos;
    
    while (i > 0 || j > 0) {
        if (arrowTable[i][j] == kLeft) {
            j -= 1;
            gapsInA++;
        }
        else if (arrowTable[i][j] == kUp) {
            edInfo.insertion = TRUE;
            i -= 1;
            gapsInB++;
        }
        else if (arrowTable[i][j] == kDiag) {
            i -= 1;
            j -= 1;
        }
        else if (arrowTable[i][j] == kInitialize) {
            if (i>0) {
                gapsInB += i;
            }
            break;
        }
    }
    
    int gappedLength = lenA+gapsInA-1;
    edInfo.gappedA[gappedLength] = '\0';
    edInfo.gappedB[gappedLength] = '\0';
    int pos = gappedLength-1;//Check -2, but it is because subtracting the space in the beginning " GA..." and gets to the last position

    i = lenA-1;
    j = smallestEDPos;
    
    while (i > 0 || j > 0) {
        if (arrowTable[i][j] == kLeft) {
            edInfo.gappedA[pos] = '-';
            edInfo.gappedB[pos] = b[range.location+j-1];
            j -= 1;
        }
        else if (arrowTable[i][j] == kUp) {
            edInfo.gappedB[pos] = '-';
            edInfo.gappedA[pos] = a[i];
            i -= 1;
        }
        else if (arrowTable[i][j] == kDiag) {
            edInfo.gappedA[pos] = a[i];
            edInfo.gappedB[pos] = b[range.location+j-1];
            i -= 1;
            j -= 1;
        }
        else if (i == 0)
            break;
        
        pos--;
    }
    
    edInfo.distance = smallestED;
    edInfo.position = j;
    
    return edInfo;
}

- (ED_Info*)editDistanceForInfo:(char *)a andB:(char *)b andChunkNum:(int)chunkNum andChunkSize:(int)chunkSize andMaxED:(int)maxED {
    int lenA = strlen(a), lenB = strlen(b);
    
    char *newb = calloc(lenB+1, 1);
    memcpy(newb+1, b, lenB);
    newb[0] = ' ';
    lenB++;
    
    ED_Info *edInfo = [[ED_Info alloc] init];
    edInfo.gappedA = calloc(kDefaultEditDistStrSize, 1);
    edInfo.gappedB = calloc(kDefaultEditDistStrSize, 1);
    
    
    int editDistanceTable[lenA][lenB];
    int arrowTable[lenA][lenB];//0 is left, 1 is diag, 2 is up, 3 is created
    int gapsInA = 0, gapsInB = 0;
    
    for (int i = 0; i<lenA; i++) {
        for (int j = 0; j<lenB; j++) {
            if (i == 0) {
                editDistanceTable[i][j] = 0;//j
                arrowTable[i][j] = kInitialize;
            }
            else if (j == 0) {
                editDistanceTable[i][j] = i;
                arrowTable[i][j] = kUp;
            }
            else {
                int min = editDistanceTable[i-1][j-1] + ((a[i] == newb[j]) ? 0 : 1);
                arrowTable[i][j] = kDiag;
                
                int possibleMin = editDistanceTable[i][j-1]+1;
                if (possibleMin<=min) {
                    min = possibleMin;
                    arrowTable[i][j] = kLeft;
                }
                
                possibleMin = editDistanceTable[i-1][j]+1;
                if (possibleMin<=min) {
                    min = possibleMin;
                    arrowTable[i][j] = kUp;
                }
                
                editDistanceTable[i][j] = min;
            }
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
    
    int i = lenA-1;
    int j = smallestEDPos;
    
    while (i > 0 || j > 0) {
        if (arrowTable[i][j] == kLeft) {
            j -= 1;
            gapsInA++;
        }
        else if (arrowTable[i][j] == kUp) {
            edInfo.insertion = TRUE;
            i -= 1;
            gapsInB++;
        }
        else if (arrowTable[i][j] == kDiag) {
            i -= 1;
            j -= 1;
        }
        else if (arrowTable[i][j] == kInitialize) {
            if (i>0) {
                gapsInB += i;
            }
            break;
        }
    }
    
    int gappedLength = lenA+gapsInA-1;
    edInfo.gappedA[gappedLength] = '\0';
    edInfo.gappedB[gappedLength] = '\0';
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
        if (arrowTable[i][j] == kLeft) {
            edInfo.gappedA[pos] = '-';
            edInfo.gappedB[pos] = newb[j];
            j -= 1;
        }
        else if (arrowTable[i][j] == kUp) {
            edInfo.gappedB[pos] = '-';
            edInfo.gappedA[pos] = a[i];
            i -= 1;
        }
        else if (arrowTable[i][j] == kDiag) {
            edInfo.gappedA[pos] = a[i];
            edInfo.gappedB[pos] = newb[j];
            i -= 1;
            j -= 1;
        }
        else if (i == 0)
            break;
        
        pos--;
    }
    
    edInfo.distance = smallestED;
    
    //    Properly shift gappedA and gappedB to remove extra chars
    //if (!edInfo.insertion) {
    
    edInfo.position = j;
    
    return edInfo;
}

char *substring(const char *pstr, int start, int numchars)
{
    char *pnew = malloc(numchars+1);
    strncpy(pnew, pstr + start, numchars);
    pnew[numchars] = '\0';
    return pnew;
}
@end