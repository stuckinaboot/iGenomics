//
//  BWT_Matcher_InsertionDeletion.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 10/29/12.
//
//

#import "BWT_Matcher_InsertionDeletion.h"
#import "Chunks.h"

@implementation BWT_Matcher_InsertionDeletion

- (NSMutableArray*)setUpWithCharA:(char*)a andCharB:(char*)b andChunks:(NSMutableArray*)chunkArray andMaximumEditDist:(int)maxED andIsReverse:(BOOL)isR {
    matchedInDels = [[NSMutableArray alloc] init];
    editDist = [[EditDistance alloc] init];
    isRev = isR;
    
    //printf("DK: creating newa\n");
    
    //    Add space prior to the chars in "a" and prior to the chars in "b"
    int alen = strlen(a);
    char *newa = calloc(alen+2, 1);
    memcpy(newa+1, a, alen);
    newa[0] = ' ';
    newa[alen+1] = '\0';
    
    /*int blen = strlen(b);
    char *newb = calloc(blen+1, 1);
    memcpy(newb+1, b, blen);
    newb[0] = ' ';*/
    
    maxEditDist = maxED;
    
    //printf("DK: calling findInDels\n");
    
    [self findInDels:newa andCharB:b andChunks:chunkArray];
    
    //    Free memory---NEEDS TO BE DONE
    free(newa);
    
    return matchedInDels;
}

- (void)findInDels:(char*)a andCharB:(char*)b andChunks:(NSMutableArray*)chunkArray {//REMEMBER TO REMOVE SPACE
    int matchedPos = 0;
    int startPos = 0;//+1 is added during substring to account for the space when finding the pos
    int lenA = strlen(a)-1;
    Chunks *chunk = [chunkArray objectAtIndex:0];
    int chunkSize = chunk.range.length;
    ED_Info *edInfo = [[ED_Info alloc] init];

    
    //printf("DK: finding InDels C1\n");
    //    Finding InDels for Chunk 1
    for (int i = 0; i<chunk.matchedPositions.count; i++) {
        matchedPos = [[chunk.matchedPositions objectAtIndex:i] intValue];
        startPos = [self findStartPosForChunkNum:0 andSizeOfChunks:chunkSize andMatchedPos:matchedPos];
        if (startPos>=0) {
            edInfo = [editDist editDistanceForInfo:a andBFull:b andRangeOfActualB:NSMakeRange(startPos, lenA+maxEditDist) andChunkNum:0 andChunkSize:chunkSize andMaxED:maxEditDist];
//            edInfo = [editDist editDistanceForInfo:a andB:substring(b, startPos, lenA+maxEditDist) andChunkNum:0 andChunkSize:chunkSize andMaxED:maxEditDist];//Not sure why +1 yet
            [self checkForInDelMatch:edInfo andMatchedPos:matchedPos andChunkNum:0 andChunkSize:chunkSize];
        }
    }
    
    
    //printf("DK: finding InDels C2 to Cn-1\n");
    //    Finding InDels for Chunk 2 through amtOfChunks-1
    if ([chunkArray count]>2) {
        for (int cNum = 1; cNum<[chunkArray count]-1; cNum++) {
            chunk = [chunkArray objectAtIndex:cNum];
            for (int i = 0; i<chunk.matchedPositions.count; i++) {
                matchedPos = [[chunk.matchedPositions objectAtIndex:i] intValue];
                startPos = [self findStartPosForChunkNum:cNum andSizeOfChunks:chunkSize andMatchedPos:matchedPos];
                if (startPos>=0) {
                    edInfo = [editDist editDistanceForInfo:a andBFull:b andRangeOfActualB:NSMakeRange(startPos-maxEditDist, lenA+(maxEditDist*2)) andChunkNum:cNum andChunkSize:chunkSize andMaxED:maxEditDist];
//                        edInfo = [editDist editDistanceForInfo:a andB:substring(b, startPos-maxEditDist, lenA+(maxEditDist*2)) andChunkNum:cNum andChunkSize:chunkSize andMaxED:maxEditDist];//Not sure why +1
                    [self checkForInDelMatch:edInfo andMatchedPos:matchedPos andChunkNum:cNum andChunkSize:chunkSize];
                }
            }
        }
    }
    
    //printf("DK: finding InDels Cn\n");
    //    Finding InDels for Final Chunk
    if ([chunkArray count]>1) {
        chunk = [chunkArray objectAtIndex:[chunkArray count]-1];
        for (int i = 0; i<chunk.matchedPositions.count; i++) {
            matchedPos = [[chunk.matchedPositions objectAtIndex:i] intValue];
            startPos = [self findStartPosForChunkNum:[chunkArray count]-1 andSizeOfChunks:chunkSize andMatchedPos:matchedPos];
            if (startPos>=0) {
                edInfo = [editDist editDistanceForInfo:a andBFull:b andRangeOfActualB:NSMakeRange(startPos-maxEditDist, lenA+maxEditDist) andChunkNum:[chunkArray count]-1 andChunkSize:chunkSize andMaxED:maxEditDist];
//                    edInfo = [editDist editDistanceForInfo:a andB:substring(b, startPos-maxEditDist, lenA+maxEditDist) andChunkNum:[chunkArray count]-1 andChunkSize:chunkSize andMaxED:maxEditDist];//Not sure why +1
                [self checkForInDelMatch:edInfo andMatchedPos:matchedPos andChunkNum:[chunkArray count]-1 andChunkSize:chunkSize];
            }
        }
    }
    
    if (kPrintInDelPos>0) {
        for (int i = 0; i<[matchedInDels count]; i++) {
            ED_Info *info = [matchedInDels objectAtIndex:i];
            if (kPrintInDelPos == 1)
                printf("\nPOS: %i : A: %s : B: %s",info.position,info.gappedA,info.gappedB);
            else if (kPrintInDelPos == 2)
                printf("\nPOS: %i",info.position);
        }
    }
}

- (void)checkForInDelMatch:(ED_Info*)edInfo andMatchedPos:(int)matchedPos andChunkNum:(int)cNum andChunkSize:(int)cSize {
    if (edInfo.distance<=maxEditDist) {//Match Occurred
        BOOL alreadyRecorded = FALSE;
        //First matchPos needs to be set to the matchedPos w/o gaps, then use edInfo.position to account for gaps
        if (cNum == 0) {
            matchedPos = matchedPos + edInfo.position;
        }
        else if (cNum>0) {
            matchedPos = matchedPos-(cNum*cSize);
            matchedPos = matchedPos + (edInfo.position-maxEditDist);
            //                    Check To See If Match Has Already been recorded
            for (int i = 0; i<[matchedInDels count]; i++) {
                ED_Info *data = [matchedInDels objectAtIndex:i];
                if (data.position == matchedPos) //If pos is the same
                    alreadyRecorded = TRUE;
            }
        }
        
        if (!alreadyRecorded) {
            edInfo.position = matchedPos;
            edInfo.isRev = isRev;
            [matchedInDels addObject:edInfo];
        }
        else
            [edInfo freeUsedMemory];
    }
    else
        [edInfo freeUsedMemory];
}

- (int)findStartPosForChunkNum:(int)cNum andSizeOfChunks:(int)cSize andMatchedPos:(int)mPos {
    if (cNum == 0) {
        return mPos;
    }
    else {
        return mPos-(cNum*cSize);
    }
}
@end