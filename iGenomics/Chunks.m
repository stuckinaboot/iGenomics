//
//  Chunks.m
//  LabProject7
//
//  Created by Stuckinaboot Inc. on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Chunks.h"

@implementation Chunks

@synthesize numOfSubs, matchedPositions, string;

- (id)init {
    self = [super init];
    string = calloc(kMaxChunkSize, 1);
    matchedPositions = [[NSMutableArray alloc] init];
//        subsAtMatchedPositionsArray = [[NSMutableArray alloc] init];
    return self;
}

@end
