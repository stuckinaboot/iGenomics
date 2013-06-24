//
//  MutationInfo.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 6/23/13.
//
//

#import "MutationInfo.h"

@implementation MutationInfo

@synthesize pos, isHetero;

- (id)initWithPos:(int)p andIsHetero:(BOOL)isH {
    self = [super init];
    pos = p;
    isHetero = isH;
    return self;
}

@end
