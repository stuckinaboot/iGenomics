//
//  Chunks.m
//  LabProject7
//
//  Created by Stuckinaboot Inc. on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Chunks.h"

@implementation Chunks

@synthesize numOfSubs, matchedPositions, str, range;

- (id)initWithString:(char*)string {
    self = [super init];
    str = string;
    matchedPositions = [[NSMutableArray alloc] init];
    return self;
}

@end
