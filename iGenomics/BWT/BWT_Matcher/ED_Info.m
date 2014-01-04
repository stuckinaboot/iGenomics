//
//  ED_Info.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 11/11/12.
//
//

#import "ED_Info.h"

@implementation ED_Info

@synthesize gappedA, gappedB, readName, position, distance, insertion, isRev;

- (id)initWithPos:(int)pos editDistance:(int)dist gappedAStr:(char*)gA gappedBStr:(char*)gB isIns:(BOOL)ins isReverse:(BOOL)isReverse {
    self = [super init];
    position = pos;
    distance = dist;
    gappedA = gA;
    gappedB = gB;
    insertion = ins;
    isRev = isReverse;
    return self;
}

@end
