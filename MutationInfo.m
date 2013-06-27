//
//  MutationInfo.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 6/23/13.
//
//

#import "MutationInfo.h"

@implementation MutationInfo

@synthesize pos, refChar, foundChars;

- (id)initWithPos:(int)p andRefChar:(char)refC andFoundChars:(char *)foundC {
    self = [super init];
    pos = p;
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
@end
