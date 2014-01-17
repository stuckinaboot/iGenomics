//
//  BWT_Matcher_Approxi.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 4/20/13.
//
//

#import "BWT_Matcher_Approxi.h"

@implementation BWT_Matcher_Approxi

- (NSArray*)approxiMatchForQuery:(char*)query andNumOfSubs:(int)amtOfSubs andIsReverse:(BOOL)isRev andReadLen:(int)queryLength {
    
    if (amtOfSubs == 0)
        return (NSMutableArray*)[self exactMatchForQuery:query andIsReverse:isRev andForOnlyPos:NO];
    
    numOfChunks = amtOfSubs+1;
    
    if (fmod(queryLength, 2) != 0) //Odd
        queryLength++;
    
    sizeOfChunks = queryLength/numOfChunks;
    
    Chunks *chunks[numOfChunks];
    int subsInChunk[numOfChunks], start = 0;
    
    for (int i = 0; i<numOfChunks; i++)
        chunks[i] = [[Chunks alloc] initWithString:query];
    
    positionsArray = [[NSMutableArray alloc] init];
    
    if (amtOfSubs>0) {
        for (int i = 0; i<numOfChunks; i++, start += sizeOfChunks)
            [self setUpChunk:chunks[i] forQuery:query numOfChunks:numOfChunks chunkLen:sizeOfChunks start:start andChunkNum:i];
        
        charsToCheckRight = 0, charsToCheckLeft = 0, numOfSubstitutions = 0;
        
        for (int i = 0; i<numOfChunks; i++) {
            chunks[i].matchedPositions = (NSMutableArray*)[self exactMatchForChunk:chunks[i] andIsReverse:isRev andForOnlyPos:YES];
            
            for (int x = 0; x<[chunks[i].matchedPositions count]; x++) {
                
                charsToCheckLeft = [self figureOutCharsToCheckLeftForI:i andChunkLen:sizeOfChunks andQueryLen:queryLength andNumOfChunks:numOfChunks];
                charsToCheckRight = [self figureOutCharsToCheckRightForI:i andChunkLen:sizeOfChunks andQueryLen:queryLength andNumOfChunks:numOfChunks];
        
                leftStrStart = [[chunks[i].matchedPositions objectAtIndex:x] intValue] - charsToCheckLeft;
                rightStrStart = [[chunks[i].matchedPositions objectAtIndex:x] intValue]+chunks[i].range.length;
                
                for (int l = 0; l<charsToCheckLeft; l++) {
                    if (originalStr[l+leftStrStart] != query[l]) {
                        numOfSubstitutions++;
                        subsInChunk[numOfChunks-(int)floorf((float)(l/sizeOfChunks)+1)-(numOfChunks-i-1)-1]++;
                    }
                }
                
                if (rightStrStart>=dgenomeLen-1)
                    charsToCheckRight = 0;
                for (int l = 0; l<charsToCheckRight && numOfSubstitutions <= amtOfSubs; l++) {
                    if (originalStr[l+rightStrStart] != query[(i+1)*sizeOfChunks+l]) {
                        numOfSubstitutions++;
                        subsInChunk[(int)floorf((float)l/sizeOfChunks)+1+i]++;
                    }
                }
                
                if (numOfSubstitutions<=amtOfSubs) {
                    NSMutableArray *array = [[NSMutableArray alloc] init];
                    for (int r = 0; r<numOfChunks; r++)
                        [array addObject:[NSNumber numberWithInt:subsInChunk[r]]];
                    
                    [self addAlignmentsToPosArrayForFullSubsArr:array chunkNum:i posIndex:x sizeOfChunks:sizeOfChunks matchedChunk:chunks[i] queryLen:queryLength andIsRev:isRev andED:numOfSubstitutions andQuery:query];
                }
                
                numOfSubstitutions = 0;
                for (int r = 0; r<numOfChunks; r++)
                    subsInChunk[r] = 0;
            }
        }
    }
    return positionsArray;
}

- (void)addAlignmentsToPosArrayForFullSubsArr:(NSArray*)subsArr chunkNum:(int)cNum posIndex:(int)x sizeOfChunks:(int)len matchedChunk:(Chunks*)chunk queryLen:(int)qLen andIsRev:(BOOL)isRev andED:(int)distance andQuery:(char*)query {
    if ([self isNotDuplicateAlignment:subsArr andChunkNum:cNum]) {
        int pos = [[chunk.matchedPositions objectAtIndex:x] intValue] - cNum*len;
        
        if (pos+qLen<=dgenomeLen && pos>-1)
            [positionsArray addObject:[[ED_Info alloc] initWithPos:pos editDistance:distance gappedAStr:query gappedBStr:kNoGappedBChar isIns:NO isReverse:isRev]];
    }
}

- (void)setUpChunk:(Chunks*)chunk forQuery:(char*)query numOfChunks:(int)num chunkLen:(int)len start:(int)start andChunkNum:(int)cNum {
    if (cNum < num-1)
        chunk.range = NSMakeRange(start, len);
    else
        chunk.range = NSMakeRange(start, len+1);
    start += len;
}

- (int)figureOutCharsToCheckLeftForI:(int)i andChunkLen:(int)cLen andQueryLen:(int)qLen andNumOfChunks:(int)num {
    int charsToCheck = 0;
    
    if (i>0 && i<num-1) {
        charsToCheck = (i)*cLen;
    }
    else if (i == 0) {
        charsToCheck = 0;
    }
    else if (i == num-1) {
        charsToCheck = (num-1)*cLen;
    }
    
    return charsToCheck;
}

- (int)figureOutCharsToCheckRightForI:(int)i andChunkLen:(int)cLen andQueryLen:(int)qLen andNumOfChunks:(int)num {
    int charsToCheck = 0;
    
    if (i>0 && i<num-1)
        charsToCheck = (qLen-1)-((cLen*i+1)+(cLen-1));
    else if (i == 0)
        charsToCheck = (num-1)*cLen;
        if (qLen%2 != 0)
            charsToCheck -= 1;
    else if (i == num-1)
        charsToCheck = 0;
    
    return charsToCheck;
}
@end
