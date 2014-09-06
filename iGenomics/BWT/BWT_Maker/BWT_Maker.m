//
//  BWT_Create.m
//  LabProject7
//
//  Created by Stuckinaboot Inc. on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BWT_Maker.h"

@implementation BWT_Maker

- (char*)createBWTFromResFileContents:(NSString *)contents {
    if (!bwtCreationTimer)
        bwtCreationTimer = [[APTimer alloc] init];
    [bwtCreationTimer start];

    sequence = strdup([contents UTF8String]);
    sequenceLength = strlen(sequence);
    
    indexArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i<sequenceLength; i++) {
        [indexArray addObject:[NSNumber numberWithInt:i]];
    }
    
    [self sortIndexArrayUsingQuicksort:indexArray withStartPos:0 andEndPos:[indexArray count]-1];
    
    return [self bwtFinalProduct];
}

- (char*)getOriginalString {
    return sequence;
}

- (void)sortIndexArrayUsingQuicksort:(NSMutableArray*)array withStartPos:(int)startPos andEndPos:(int)endpos {
    int pivotPos = (arc4random() % (endpos-startPos))+startPos;//rand%amtofthings in array
    int pivot = [[array objectAtIndex:pivotPos] intValue];
    int firstPos = startPos;
    int lastPos = endpos;
    int s = [[array objectAtIndex:firstPos] intValue];
    int e = [[array objectAtIndex:lastPos] intValue];
    
    while (firstPos<lastPos) {
        while ([self whichIndex:s isSmaller:pivot] == 1) {
            firstPos++;
            s = [[array objectAtIndex:firstPos] intValue];
        }
        while ([self whichIndex:e isSmaller:pivot] == 2) {
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
        [self sortIndexArrayUsingQuicksort:array withStartPos:startPos andEndPos:lastPos];
    }
    if (firstPos<endpos) {//firstpos is one to right of median
        [self sortIndexArrayUsingQuicksort:array withStartPos:firstPos andEndPos:endpos];
    }
}

- (int)whichIndex:(int)index1 isSmaller:(int)index2 {
    
    NSAssert(sequence[sequenceLength-1] == '$', @"Expected $ at the end of the sequence");
    if (index1 == index2)
        return 0;//NEW CHANGE, THIS DOES WORK, MAKES THE BWT COMPUTING 10x faster
    for (int i = 0; i<sequenceLength; i++) {
        if (sequence[index1+i]<sequence[index2+i]) {
            return 1;
        }
        if (sequence[index1+i]>sequence[index2+i]) {
            return 2;
        }
    }
    return 0;
}

- (char*)bwtFinalProduct {
    char *bwt = calloc(sequenceLength+1, 1);
    int num;
    for (int i = 0; i<[indexArray count]; i++) {
        num = [[indexArray objectAtIndex:i] intValue]-1;
        benchmarkPositions[i] = num+1;//Not sure why + 1
        if (num<0) {
            num = sequenceLength-1;
        }
        bwt[i] = sequence[num];
    }
    bwt[sequenceLength] = '\0';
    [bwtCreationTimer stopAndLog];
    return bwt;
}

@end
