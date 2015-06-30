//
//  EditDistance.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 10/15/12.
//
//

#import <Foundation/Foundation.h>
#import "ED_Info.h"
#import "Chunks.h"
#import "APTimer.h"

//#define kDefaultEditDistStrSize 150
#define kAllowedNumOfDiffs 10
#define kCharsToLookForAfter 2

#define kEditDistanceDoNotKill -1

#define kLeft 0
#define kDiag 1
#define kUp 2
#define kInitialize 3

@interface EditDistance : NSObject {
    NSMutableArray *deletionPositions;
    NSMutableArray *insertionPositions;
}
- (ED_Info*)editDistanceForInfo:(char *)a andBFull:(char *)b andRangeOfActualB:(NSRange)range andChunkNum:(int)chunkNum andChunkSize:(int)chunkSize andMaxED:(int)maxED andKillIfLargerThanDistance:(int)minDist;
- (ED_Info*)editDistanceForInfo:(char *)a andB:(char *)b andChunkNum:(int)chunkNum andChunkSize:(int)chunkSize andMaxED:(int)maxED;

- (ED_Info*)editDistanceForInfoWithFullA:(char*)a rangeInA:(NSRange)rangeA andFullB:(char *)b rangeInB:(NSRange)rangeB andMaxED:(int)maxED;//backtrackingPosition = -1 if unknown (usually unknown) unless you are not looking for the smallest edit distance
@end
