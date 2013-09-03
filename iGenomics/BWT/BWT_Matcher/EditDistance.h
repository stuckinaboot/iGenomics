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

#define kDefaultEditDistStrSize 1000
#define kAllowedNumOfDiffs 10
#define kCharsToLookForAfter 2

@interface EditDistance : NSObject {
    char *charA;//gappedA
    char *charB;//gappedB
    int distance;
    
    NSMutableArray *deletionPositions;
    NSMutableArray *insertionPositions;
}
- (void)computeEditDistance:(char *)a andB:(char *)b lenA:(int)lenA andLenB:(int)lenB andEditDistForCell:(CGPoint)cellpos;
//- (void)findInDels:(char *)a andB:(char *)b lenA:(int)lenA andLenB:(int)lenB andChunks:(NSMutableArray*)chunkArray;
- (ED_Info*)editDistanceForInfo:(char *)a andB:(char *)b andChunkNum:(int)chunkNum andChunkSize:(int)chunkSize andMaxED:(int)maxED;
@property (nonatomic) char *charA;
@property (nonatomic) char *charB;
@property (nonatomic) int distance;
char *substring(const char *pstr, int start, int numchars);
@end
