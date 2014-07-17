//
//  Reads.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 12/11/13.
//
//

#import "Read.h"

@implementation Read

@synthesize name, sequence;

- (id)initWithSeq:(char*)s andName:(char*)n {
    if (self = [super init]) {
        sequence = strdup(s);
        name = strdup(n);
    }
    return self;
}

@end