//
//  MutationInfo.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 6/23/13.
//
//

#import "MutationInfo.h"

@implementation MutationInfo

@synthesize pos, displayedPos, refChar, foundChars, genomeName, indexInSegmentNameArr;

- (id)initWithPos:(int)p andRefChar:(char)refC andFoundChars:(char *)foundC andDisplayedPos:(int)dispP {
    self = [super init];
    pos = p;
    displayedPos = dispP;
    refChar = refC;
    foundChars = strdup(foundC);
    return self;
}

+ (char*)createMutStrFromOriginalChar:(char)originalC andFoundChars:(char*)fc {
    int s = strlen(fc);
    char *mutStr = calloc(2+ ((s > 1) ? (s*2)-1 : 1) + 1, 1);//+1 at the end because of null terminator
    mutStr[0] = originalC;
    mutStr[1] = '>';
    
    int pos = 2;
    for (int i = 0; i<s; i++) {
        mutStr[pos] = fc[i];
        pos++;
        if (i+1 < s) {
            mutStr[pos] = '/';
            pos++;
        }
    }
    mutStr[pos] = '\0';
    return mutStr;
}

+ (char*)createMutCovStrFromFoundChars:(char*)fc andPos:(int)pos {
    int len = strlen(fc);
    int covArr[len];
    
    NSMutableString *covStr = [[NSMutableString alloc] init];
    for (int i = 0; i < len; i++) {
        covArr[i] = posOccArray[[BWT_MatcherSC whichChar:fc[i] inContainer:acgt]][pos];
        [covStr appendFormat:kCovStrFormat,fc[i],covArr[i]];
    }
    return (char*)[[covStr stringByReplacingCharactersInRange:NSMakeRange(covStr.length-1, 1) withString:@""] UTF8String];//Replaces the final / with nothing
}

+ (BOOL)mutationInfoObjectsHaveSameContents:(MutationInfo *)info1 :(MutationInfo *)info2 {
    BOOL sameFoundChars = NO;
    int len = (int)strlen(info1.foundChars);
    if (len > 1 && foundGenome[kFoundGenomeArrSize-1][info1.pos] != kMatchTypeHomozygousMutationNormal && foundGenome[kFoundGenomeArrSize-1][info1.pos] != kMatchTypeHomozygousNoMutation) {
        for (int i = 0; i < len; i++) {
            if (info2.foundChars[0] == info1.foundChars[i]) {
                sameFoundChars = YES;
                break;
            }
        }
    }
    else if (len == 1)
        sameFoundChars = (info1.foundChars[0] == info2.foundChars[0]);
    return ((info1.pos == info2.pos) && (info1.refChar == info2.refChar) && sameFoundChars && [info1.genomeName isEqualToString:info2.genomeName]);//Checks if a bunch of factors are equal, foundChars[0] because is just checking first character...may change in future to strcmp
}
@end
