//
//  MatchedReadData.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 4/28/13.
//
//

#import "MatchedReadData.h"

@implementation MatchedReadData

@synthesize pos, isReverse, info;

- (id)initWithPos:(int)p isReverse:(BOOL)isRev andEDInfo:(ED_Info*)inf {
    if (self = [super init]) {
        pos = p;
        isReverse = isRev;
        info = inf;
    }
    return self;
}

@end
