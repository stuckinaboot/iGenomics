//
//  ED_Info.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 11/11/12.
//
//

#import "ED_Info.h"

@implementation ED_Info

@synthesize gappedA, gappedB, readName, position, distance, insertion, isRev, rowInAlignmentGrid, numOfInsertions;

- (id)initWithPos:(int)pos editDistance:(int)dist gappedAStr:(char*)gA gappedBStr:(char*)gB isIns:(BOOL)ins isReverse:(BOOL)isReverse {
    self = [super init];
    position = pos;
    distance = dist;
    gappedA = strdup(gA);
    gappedB = strdup(gB);
    insertion = ins;
    isRev = isReverse;
    return self;
}

+ (BOOL)areEqualEditDistance1:(ED_Info *)ed1 andEditDistance2:(ED_Info *)ed2 {
    return (ed1.position == ed2.position && ed1.isRev == ed2.isRev && strcmp(ed1.gappedA, ed2.gappedA) == 0 && strcmp(ed1.gappedB, ed2.gappedB) == 0 && ed1.distance == ed2.distance);
}

- (int)intValue {
    return position;
}

- (void)freeUsedMemory {
    free(gappedA);
    free(gappedB);
}

@end
