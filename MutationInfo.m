//
//  MutationInfo.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 6/23/13.
//
//

#import "MutationInfo.h"

@implementation MutationInfo

@synthesize pos, displayedPos, refChar,
    foundChars, genomeName, indexInSegmentNameArr, relevantInsertionsArr;

- (id)initWithPos:(int)p andRefChar:(char)refC andFoundChars:(char *)foundC andDisplayedPos:(int)dispP  andInsertionsArr:(NSArray*)insArr heteroAllowance:(int)heteroAllowance {
    self = [super init];
    pos = p;
    displayedPos = dispP;
    refChar = refC;
    foundChars = strdup(foundC);
    
    NSMutableArray *insertions = [[NSMutableArray alloc] init];
    for (BWT_Matcher_InsertionDeletion_InsertionHolder *holder in insArr) {
        if (pos == holder.pos) {
            [insertions addObject:holder];
        }
    }
    relevantInsertionsArr = insertions;
    return self;
}

+ (char*)createMutStrFromOriginalChar:(char)originalC
                        andFoundChars:(char*)fc pos:(int)pos relevantInsArr:(NSArray*)insertions {
    int s = (int)strlen(fc);
    NSMutableString *mutStr = [[NSMutableString alloc] init];
    [mutStr appendFormat:@"%c",originalC];
    [mutStr appendFormat:@"%c",'>'];
    
    for (int i = 0; i<s; i++) {
        [mutStr appendFormat:@"%c",fc[i]];
        if (i+1 < s) {
            [mutStr appendFormat:@"%c",'/'];
        }
    }
    return strdup([mutStr UTF8String]);
}

+ (char*)createMutCovStrFromFoundChars:(char*)fc
                                andPos:(int)pos relevantInsArr:(NSArray *)insertions {
    int len = (int)strlen(fc);
    int covArr[len];
    
    NSMutableString *covStr = [[NSMutableString alloc] init];
    for (int i = 0; i < len; i++) {
        covArr[i] = posOccArray[[BWT_MatcherSC whichChar:fc[i] inContainer:acgt]][pos];
        if (fc[i] == kInsMarker) {
            NSMutableString *strToAppend = [[NSMutableString alloc] init];
            for (BWT_Matcher_InsertionDeletion_InsertionHolder *holder in insertions) {
                if (holder.pos == pos) {
                    [strToAppend appendFormat:kInsStrFormat,holder.seq,holder.count];
                }
            }
            [covStr appendFormat:kCovStrInsFormat, kInsMarker, strToAppend];
        } else
            [covStr appendFormat:kCovStrFormat,fc[i],covArr[i]];
    }
    return strdup([covStr UTF8String]);//Replaces the final / with nothing
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
