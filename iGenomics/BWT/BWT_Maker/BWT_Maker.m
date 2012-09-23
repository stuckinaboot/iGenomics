//
//  BWT_Create.m
//  LabProject7
//
//  Created by Stuckinaboot Inc. on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BWT_Maker.h"

@implementation BWT_Maker

- (char*)createBWTFromResFile:(NSString*)fileName andFileExt:(NSString*)fileExt {
    NSString *resFileStr = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:fileExt] encoding:NSUTF8StringEncoding error:nil];
    
    sequence = strdup([resFileStr UTF8String]);
    sequenceLength = strlen(sequence);
    
    indexArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i<strlen(sequence); i++) {
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
    char *bwt = calloc(strlen(sequence), 1);
    int num;
    int length = strlen(sequence);
    for (int i = 0; i<[indexArray count]; i++) {
        num = [[indexArray objectAtIndex:i] intValue]-1;
        if (num<0) {
            num = length-1;
        }
        bwt[i] = sequence[num];
    }

    return bwt;
}

@end
