//
//  GlobalVars.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/19/13.
//
//

#import "GlobalVars.h"

int bytesForIndexer;
int dgenomeLen;
char *originalStr;
char *refStrBWT;
char *firstCol;
char *acgt;
int acgtOccurences[kMaxBytesForIndexer][kACGTLen];//Occurences for up to each multiple to count at
int benchmarkPositions[kMaxBytesForIndexer*kMultipleToCountAt];
int acgtTotalOccs[kACGTLen];
NSMutableArray *readAlignmentsArr;

@implementation GlobalVars

+ (void)sortArrayUsingQuicksort:(NSMutableArray*)array withStartPos:(int)startPos andEndPos:(int)endpos {
    int pivotPos = (arc4random() % (endpos-startPos))+startPos;//rand%amtofthings in array
    int pivot = [[array objectAtIndex:pivotPos] intValue];
    int firstPos = startPos;
    int lastPos = endpos;
    int s = [[array objectAtIndex:firstPos] intValue];
    int e = [[array objectAtIndex:lastPos] intValue];
    
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
    
    if (startPos<lastPos) {//Lastpos is one to left of median
        [self sortArrayUsingQuicksort:array withStartPos:startPos andEndPos:lastPos];
    }
    if (firstPos<endpos) {//firstpos is one to right of median
        [self sortArrayUsingQuicksort:array withStartPos:firstPos andEndPos:endpos];
    }
}

+ (BOOL)internetAvailable {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus != NotReachable)
        return YES;
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kNoInternetAlertTitle message:kNoInternetAlertMsg delegate:self cancelButtonTitle:kNoInternetAlertBtn otherButtonTitles:nil];
        [alert show];
        return NO;
    }
}

+ (BOOL)isIpad {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

+ (BOOL)isOldIPhone {
    return [[UIScreen mainScreen] bounds].size.height == kOldIPhoneScreenSize;
}

+ (NSString*)extFromFileName:(NSString *)name {
    NSRange range = [name rangeOfString:@"." options:NSBackwardsSearch];
    return [name substringWithRange:NSMakeRange(range.location+1,name.length-range.location-1)];
}
/*
+ (void)displayReadAlignmentDataInConsole {
    for (ED_Info *info in readAlignmentsArr) {
        printf("\n\n%i, %s",info.position, info.gappedA);
    }
}*/
@end
