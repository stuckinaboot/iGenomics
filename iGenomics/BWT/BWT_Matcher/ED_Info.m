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

+ (ED_Info*)mergedED_Infos:(ED_Info *)ed1 andED2:(ED_Info *)ed2 {
    
    if (ed1.gappedA && !ed2.gappedA)
        return [ED_Info copyOfEDInfo:ed1];
    else if (ed2.gappedA && !ed1.gappedA)
        return [ED_Info copyOfEDInfo:ed2];
    else if (!ed1.gappedA && !ed2.gappedA)
        return NULL;
    
    int ed1ALen = (int)strlen(ed1.gappedA);
    int ed2ALen = (int)strlen(ed2.gappedA);
    int combinedLen = ed1ALen+ed2ALen;
    
    char *newGappedA = malloc(combinedLen+1);
    newGappedA[combinedLen] = '\0';
    char *newGappedB = malloc(combinedLen+1);
    newGappedB[combinedLen] = '\0';
    strcpy(newGappedA, ed1.gappedA);
    strcat(newGappedA, ed2.gappedA);
    strcpy(newGappedB, (ed1.gappedB[0] == kNoGappedBChar[0]) ? ed1.gappedA : ed1.gappedB);
    strcat(newGappedB, (ed2.gappedB[0] == kNoGappedBChar[0]) ? ed2.gappedA : ed2.gappedB);
    
    ED_Info *finalInfo = [[ED_Info alloc] initWithPos:ed1.position editDistance:ed1.distance+ed2.distance gappedAStr:newGappedA gappedBStr:newGappedB isIns:(ed1.insertion || ed2.insertion) isReverse:(ed1.isRev && ed2.isRev)];
    finalInfo.numOfInsertions = ed1.numOfInsertions+ed2.numOfInsertions;
    return finalInfo;
}

+ (ED_Info*)copyOfEDInfo:(ED_Info*)info {
    ED_Info *inf = [[ED_Info alloc] initWithPos:info.position editDistance:info.distance gappedAStr:info.gappedA gappedBStr:info.gappedB isIns:info.insertion isReverse:info.isRev];
    inf.numOfInsertions = info.numOfInsertions;
    return inf;
}

- (int)intValue {
    return position;
}

- (void)freeUsedMemory {
    free(gappedA);
    free(gappedB);
}

@end
