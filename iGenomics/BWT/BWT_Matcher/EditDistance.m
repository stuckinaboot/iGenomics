//
//  EditDistance.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 10/15/12.
//
//

#import "EditDistance.h"

@implementation EditDistance

- (id)init {
    return self;
}

//Attempting banding

/*- (ED_Info*)editDistanceForInfoWithFullA:(char *)a rangeInA:(NSRange)rangeA andFullB:(char *)b rangeInB:(NSRange)rangeB andMaxED:(int)maxED {
    int lenA = rangeA.length, lenB = rangeB.length+1;//First char (range.location-1) will be a "space"
    
    int* editDistanceTable = (int*)calloc(lenA*lenB, sizeof(int));
    
    char* arrowTable = (char*)calloc(lenA*lenB, sizeof(char));
    int gapsInA = 0, gapsInB = 0;
    
    
    for (int j = 0; j < lenB; j++) {
        editDistanceTable[j] = 0;//j
        arrowTable[j] = kInitialize;
    }
    
    for (int i = 0; i < lenA; i++) {
        editDistanceTable[i*lenB] = i;//j
        arrowTable[i*lenB] = kUp;
    }
    
    int n = maxED;//n = max ED
    int i = 1, j = 1;
    while (i + n < lenA && j + n < lenB) {
        for (int k = i; k <= i + n; k++) {
            int min = editDistanceTable[(k-1)*lenB+(j-1)] + ((a[rangeA.location+k] == b[rangeB.location+j-1]) ? 0 : 1);
            arrowTable[k*lenB+j] = kDiag;
            
            int possibleMin = min;
            if (k <= (i-1 + n)) {
                possibleMin = editDistanceTable[(k*lenB)+(j-1)]+1;
                if (possibleMin < min) {
                    min = possibleMin;
                    arrowTable[k*lenB+j] = kLeft;
                }
            }
            
            possibleMin = editDistanceTable[(k-1)*lenB+j]+1;
            if (possibleMin < min) {
                min = possibleMin;
                arrowTable[k*lenB+j] = kUp;
            }
            
            
            editDistanceTable[k*lenB+j] = min;
        }
        for (int k = j; k <= j + n; k++) {
            int min = editDistanceTable[(i-1)*lenB+(k-1)] + ((a[rangeA.location+i] == b[rangeB.location+k-1]) ? 0 : 1);
            arrowTable[i*lenB+k] = kDiag;
            
            int possibleMin;
            
            //				if (k <= (i-1 + n)) {
            possibleMin = editDistanceTable[(i*lenB)+(k-1)]+1;
            if (possibleMin < min) {
                min = possibleMin;
                arrowTable[i*lenB+k] = kLeft;
            }
            //				}
            
            if (k <= (j-1)+n) {
                possibleMin = editDistanceTable[(i-1)*lenB+k]+1;
                if (possibleMin < min) {
                    min = possibleMin;
                    arrowTable[i*lenB+k] = kUp;
                }
            }
            
            editDistanceTable[i*lenB+k] = min;
        }
        i++;
        j++;
    }
    
    int transitionPt = j;
    
    for (int c = i; c < lenA; c++) {
        for (int d = j; d < lenB; d++) {
            int min = editDistanceTable[(c-1)*lenB+(d-1)] + ((a[rangeA.location+c] == b[rangeB.location+d-1]) ? 0 : 1);
            arrowTable[c*lenB+d] = kDiag;
            
            int possibleMin = editDistanceTable[(c*lenB)+(d-1)]+1;
            if (possibleMin < min) {
                min = possibleMin;
                arrowTable[c*lenB+d] = kLeft;
            }
            
            possibleMin = editDistanceTable[(c-1)*lenB+d]+1;
            if (possibleMin < min) {
                min = possibleMin;
                arrowTable[c*lenB+d] = kUp;
            }
            
            editDistanceTable[c*lenB+d] = min;
        }
    }
    
    //ED = Edit Distance, Starts out being smallestEditDistance than becomes the pos of smallest edit distance
    int smallestED = editDistanceTable[(lenA-1)*lenB];//-2 to account for ' ' in beginning
    
    int smallestEDPos = 0;
    
    for (int t = transitionPt; t<lenB; t++) {
        smallestED = MIN(editDistanceTable[(lenA-1)*lenB+t], smallestED);
        if (smallestED == editDistanceTable[(lenA-1)*lenB+t]) {
            smallestEDPos = t;
        }
        if (smallestED == 0) {
            smallestEDPos = t;
            break;
        }
    }
    
    if (smallestED > maxED) {
        free(editDistanceTable);
        free(arrowTable);
        return NULL;
    }
    
    i = lenA-1;
    j = smallestEDPos;
    
    ED_Info *edInfo = [[ED_Info alloc] init];
    
    while (i > 0 || j > 0) {
        if (arrowTable[i*lenB+j] == kLeft) {
            j -= 1;
            gapsInA++;
        }
        else if (arrowTable[i*lenB+j] == kUp) {
            edInfo.insertion = TRUE;
            edInfo.numOfInsertions++;
            i -= 1;
            gapsInB++;
        }
        else if (arrowTable[i*lenB+j] == kDiag) {
            i -= 1;
            j -= 1;
        }
        else if (arrowTable[i*lenB+j] == kInitialize) {
            if (i>0) {
                gapsInB += i;
            }
            break;
        }
    }
    
    int gappedLength = lenA+gapsInA-1;
    
    edInfo.gappedA = calloc(gappedLength+1, 1);
    edInfo.gappedB = calloc(gappedLength+1, 1);
    
    edInfo.gappedA[gappedLength] = '\0';
    edInfo.gappedB[gappedLength] = '\0';
    
    int pos = gappedLength-1;//Check -2, but it is because subtracting the space in the beginning " GA..." and gets to the last position
    
    i = lenA-1;
    j = smallestEDPos;
    
    while (i > 0 || j > 0) {
        if (arrowTable[i*lenB+j] == kLeft) {
            edInfo.gappedA[pos] = '-';
            edInfo.gappedB[pos] = b[rangeB.location+j-1];
            j -= 1;
        }
        else if (arrowTable[i*lenB+j] == kUp) {
            edInfo.gappedB[pos] = '-';
            edInfo.gappedA[pos] = a[rangeA.location+i];
            i -= 1;
        }
        else if (arrowTable[i*lenB+j] == kDiag) {
            edInfo.gappedA[pos] = a[rangeA.location+i];
            edInfo.gappedB[pos] = b[rangeB.location+j-1];
            i -= 1;
            j -= 1;
        }
        else if (i == 0)
            break;
        
        pos--;
    }
    
    edInfo.distance = smallestED;
    edInfo.position = j;
    
    free(editDistanceTable);
    free(arrowTable);
    
    return edInfo;
}*/

//End banding attempt

//New Stuff

- (ED_Info*)editDistanceForInfoWithFullA:(char *)a rangeInA:(NSRange)rangeA andFullB:(char *)b rangeInB:(NSRange)rangeB andMaxED:(int)maxED {
    int lenA = rangeA.length, lenB = rangeB.length+1;//First char (range.location-1) will be a "space"
    
    int* editDistanceTable = (int*)calloc(lenA*lenB, sizeof(int));

    char* arrowTable = (char*)calloc(lenA*lenB, sizeof(char));
    int gapsInA = 0, gapsInB = 0;
    
    for (int j = 0; j < lenB; j++) {
        editDistanceTable[j] = 0;//j
        arrowTable[j] = kInitialize;
    }

    for (int i = 0; i < lenA; i++) {
        editDistanceTable[i*lenB] = i;//j
        arrowTable[i*lenB] = kUp;
    }
    
    for (int i = 1; i<lenA; i++) {
        for (int j = 1; j<lenB; j++) {
            
            int min = editDistanceTable[(i-1)*lenB+(j-1)] + ((a[rangeA.location+i] == b[rangeB.location+j-1]) ? 0 : 1);
            arrowTable[i*lenB+j] = kDiag;
            
            int possibleMin = editDistanceTable[(i*lenB)+(j-1)]+1;
            if (possibleMin < min) {
                min = possibleMin;
                arrowTable[i*lenB+j] = kLeft;
            }
            
            possibleMin = editDistanceTable[(i-1)*lenB+j]+1;
            if (possibleMin < min) {
                min = possibleMin;
                arrowTable[i*lenB+j] = kUp;
            }
            
            editDistanceTable[i*lenB+j] = min;
        }
    }
    
    //ED = Edit Distance, Starts out being smallestEditDistance than becomes the pos of smallest edit distance
    int smallestED = editDistanceTable[(lenA-1)*lenB];//-2 to account for ' ' in beginning
    
    int smallestEDPos = 0;
    
    for (int t = 0; t<lenB; t++) {
        smallestED = MIN(editDistanceTable[(lenA-1)*lenB+t], smallestED);
        if (smallestED == editDistanceTable[(lenA-1)*lenB+t]) {
            smallestEDPos = t;
        }
        if (smallestED == 0) {
            smallestEDPos = t;
            break;
        }
    }
    
    if (smallestED > maxED) {
        free(editDistanceTable);
        free(arrowTable);
        return NULL;
    }
    
    int i = lenA-1;
    int j = smallestEDPos;
    
    ED_Info *edInfo = [[ED_Info alloc] init];
    
    while (i > 0 || j > 0) {
        if (arrowTable[i*lenB+j] == kLeft) {
            j -= 1;
            gapsInA++;
        }
        else if (arrowTable[i*lenB+j] == kUp) {
            edInfo.insertion = TRUE;
            edInfo.numOfInsertions++;
            i -= 1;
            gapsInB++;
        }
        else if (arrowTable[i*lenB+j] == kDiag) {
            i -= 1;
            j -= 1;
        }
        else if (arrowTable[i*lenB+j] == kInitialize) {
            if (i>0) {
                gapsInB += i;
            }
            break;
        }
    }
    
    int gappedLength = lenA+gapsInA-1;
    
    edInfo.gappedA = calloc(gappedLength+1, 1);
    edInfo.gappedB = calloc(gappedLength+1, 1);
    
    edInfo.gappedA[gappedLength] = '\0';
    edInfo.gappedB[gappedLength] = '\0';
    
    int pos = gappedLength-1;//Check -2, but it is because subtracting the space in the beginning " GA..." and gets to the last position
    
    i = lenA-1;
    j = smallestEDPos;
    
    while (i > 0 || j > 0) {
        if (arrowTable[i*lenB+j] == kLeft) {
            edInfo.gappedA[pos] = '-';
            edInfo.gappedB[pos] = b[rangeB.location+j-1];
            j -= 1;
        }
        else if (arrowTable[i*lenB+j] == kUp) {
            edInfo.gappedB[pos] = '-';
            edInfo.gappedA[pos] = a[rangeA.location+i];
            i -= 1;
        }
        else if (arrowTable[i*lenB+j] == kDiag) {
            edInfo.gappedA[pos] = a[rangeA.location+i];
            edInfo.gappedB[pos] = b[rangeB.location+j-1];
            i -= 1;
            j -= 1;
        }
        else if (i == 0)
            break;
        
        pos--;
    }
    
    edInfo.distance = smallestED;
    edInfo.position = j;
    
    free(editDistanceTable);
    free(arrowTable);
    
    return edInfo;
}

//End New Stuff

static int counter;

- (ED_Info*)editDistanceForInfo:(char *)a andBFull:(char *)b andRangeOfActualB:(NSRange)range andChunkNum:(int)chunkNum andChunkSize:(int)chunkSize andMaxED:(int)maxED andKillIfLargerThanDistance:(int)minDist {
    
    BOOL shouldKillIfLargerThanMinDist = minDist != kEditDistanceDoNotKill;
    
    //printf("DK: creating/filling arrowTable and editDistanceTable\n");
    
    int lenA = strlen(a), lenB = range.length+1;//First char (range.location-1) will be a "space"
    
    counter++;
    
//    int editDistanceTable[lenA][lenB];
    int* editDistanceTable = (int*)calloc(lenA*lenB, sizeof(int));
//    int arrowTable[lenA][lenB];//0 is left, 1 is diag, 2 is up, 3 is created
    
    char* arrowTable = (char*)calloc(lenA*lenB, sizeof(char));
    int gapsInA = 0, gapsInB = 0;

    
    for (int j = 0; j < lenB; j++) {
        editDistanceTable[j] = 0;//j
        arrowTable[j] = kInitialize;
    }
    
    for (int i = 0; i < lenA; i++) {
        editDistanceTable[i*lenB] = i;//j
        arrowTable[i*lenB] = kUp;
    }
    
    for (int i = 1; i<lenA; i++) {
        for (int j = 1; j<lenB; j++) {
            
            int min = editDistanceTable[(i-1)*lenB+(j-1)] + ((a[i] == b[range.location+j-1]) ? 0 : 1);
            arrowTable[i*lenB+j] = kDiag;
            
            int possibleMin = editDistanceTable[(i*lenB)+(j-1)]+1;
            if (possibleMin < min) {
                min = possibleMin;
                arrowTable[i*lenB+j] = kLeft;
            }
            
            possibleMin = editDistanceTable[(i-1)*lenB+j]+1;
            if (possibleMin < min) {
                min = possibleMin;
                arrowTable[i*lenB+j] = kUp;
            }
            
            editDistanceTable[i*lenB+j] = min;
        }
    }
    
    
    //ED = Edit Distance, Starts out being smallestEditDistance than becomes the pos of smallest edit distance
    int smallestED = editDistanceTable[(lenA-1)*lenB];//-2 to account for ' ' in beginning
    
    int smallestEDPos = 0;
    
    for (int t = 0; t<lenB; t++) {
        smallestED = MIN(editDistanceTable[(lenA-1)*lenB+t], smallestED);
        if (smallestED == editDistanceTable[(lenA-1)*lenB+t]) {
            smallestEDPos = t;
        }
        if (smallestED == 0) {
            smallestEDPos = t;
            break;
        }
    }
    
    if (shouldKillIfLargerThanMinDist && minDist < smallestED) {
        free(editDistanceTable);
        free(arrowTable);
        return NULL;
    }
    else if (smallestED > maxED) {
        free(editDistanceTable);
        free(arrowTable);
        return NULL;
    }
    
    int i = lenA-1;
    int j = smallestEDPos;
    
    ED_Info *edInfo = [[ED_Info alloc] init];
    
    while (i > 0 || j > 0) {
        if (arrowTable[i*lenB+j] == kLeft) {
            j -= 1;
            gapsInA++;
        }
        else if (arrowTable[i*lenB+j] == kUp) {
            edInfo.insertion = TRUE;
            edInfo.numOfInsertions++;
            i -= 1;
            gapsInB++;
        }
        else if (arrowTable[i*lenB+j] == kDiag) {
            i -= 1;
            j -= 1;
        }
        else if (arrowTable[i*lenB+j] == kInitialize) {
            if (i>0) {
                gapsInB += i;
            }
            break;
        }
    }
    
    //printf("DK: Adding null terminators to edInfo.gappedA/B\n");
    
    int gappedLength = lenA+gapsInA-1;
    
    edInfo.gappedA = calloc(gappedLength+1, 1);
    edInfo.gappedB = calloc(gappedLength+1, 1);
    
//    if (gappedLength >= lenB+1)
        //printf("DK: FUDGE...Gapped Len: %i, LenB+1:%i\n",gappedLength, lenB+1);
//    else
        //printf("DK: AJKLF...Gapped Len: %i, %i\n",gappedLength, gappedLength < lenB+1);
    edInfo.gappedA[gappedLength] = '\0';
    edInfo.gappedB[gappedLength] = '\0';
    
    int pos = gappedLength-1;//Check -2, but it is because subtracting the space in the beginning " GA..." and gets to the last position

    i = lenA-1;
    j = smallestEDPos;
    
    while (i > 0 || j > 0) {
        if (arrowTable[i*lenB+j] == kLeft) {
            edInfo.gappedA[pos] = '-';
            edInfo.gappedB[pos] = b[range.location+j-1];
            j -= 1;
        }
        else if (arrowTable[i*lenB+j] == kUp) {
            edInfo.gappedB[pos] = '-';
            edInfo.gappedA[pos] = a[i];
            i -= 1;
        }
        else if (arrowTable[i*lenB+j] == kDiag) {
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
    
    free(editDistanceTable);
    free(arrowTable);
    
    return edInfo;
}

- (ED_Info*)editDistanceForInfo:(char *)a andB:(char *)b andChunkNum:(int)chunkNum andChunkSize:(int)chunkSize andMaxED:(int)maxED {
    int lenA = strlen(a), lenB = strlen(b);
    
    char *newb = calloc(lenB, 1);
    memcpy(newb+1, b, lenB);
    newb[0] = ' ';
    lenB++;
    
    ED_Info *edInfo = [[ED_Info alloc] init];
    edInfo.gappedA = calloc(lenB, 1);
    edInfo.gappedB = calloc(lenB, 1);
    
    
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
            edInfo.numOfInsertions++;
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
    
    free(newb);
    
    edInfo.distance = smallestED;
    
    //    Properly shift gappedA and gappedB to remove extra chars
    //if (!edInfo.insertion) {
    
    edInfo.position = j;
    
    return edInfo;
}
@end