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
    
    int numOfChunks = amtOfSubs+1;
    
    if (fmod(queryLength, 2) != 0) //Odd
        queryLength++;
    
    int sizeOfChunks = queryLength/numOfChunks;
    
    Chunks *chunks[numOfChunks];
    int subsInChunk[numOfChunks], start = 0;
    
    for (int i = 0; i<numOfChunks; i++)
        chunks[i] = [[Chunks alloc] init];
    
    NSMutableArray *positionsArray = [[NSMutableArray alloc] init];
    
    if (amtOfSubs>0) {
        for (int i = 0; i<numOfChunks; i++, start += sizeOfChunks)
            [self setUpChunk:chunks[i] forQuery:query numOfChunks:numOfChunks chunkLen:sizeOfChunks start:start andChunkNum:i];
        
        int charsToCheckRight = 0, charsToCheckLeft = 0, numOfSubstitutions = 0;
        
        for (int i = 0; i<numOfChunks; i++) {
            chunks[i].matchedPositions = (NSMutableArray*)[self exactMatchForQuery:chunks[i].string andIsReverse:isRev andForOnlyPos:YES];
            
            for (int x = 0; x<[chunks[i].matchedPositions count]; x++) {
                
                charsToCheckLeft = [self figureOutCharsToCheckLeftForI:i andChunkLen:sizeOfChunks andQueryLen:queryLength andNumOfChunks:numOfChunks];
                charsToCheckRight = [self figureOutCharsToCheckRightForI:i andChunkLen:sizeOfChunks andQueryLen:queryLength andNumOfChunks:numOfChunks];
        
                int leftStrStart = [[chunks[i].matchedPositions objectAtIndex:x] intValue] - charsToCheckLeft;
                int rightStrStart = [[chunks[i].matchedPositions objectAtIndex:x] intValue]+strlen(chunks[i].string);
                
                for (int l = 0; l<charsToCheckLeft; l++) {
                    if (originalStr[l+leftStrStart] != query[l]) {
                        numOfSubstitutions++;
                        subsInChunk[numOfChunks-(int)floorf((float)(l/sizeOfChunks)+1)-(numOfChunks-i-1)-1]++;
                    }
                }
                
                if (rightStrStart>=fileStrLen-1)
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
                    
                    [self addAlignmentsToPosArray:positionsArray fullSubsArr:array chunkNum:i posIndex:x sizeOfChunks:sizeOfChunks matchedChunk:chunks[i] queryLen:queryLength andIsRev:isRev];
                }
                
                numOfSubstitutions = 0;
                for (int r = 0; r<numOfChunks; r++)
                    subsInChunk[r] = 0;
            }
        }
    }
    return positionsArray;
}

- (void)addAlignmentsToPosArray:(NSMutableArray*)positionsArray fullSubsArr:(NSArray*)subsArr chunkNum:(int)cNum posIndex:(int)x sizeOfChunks:(int)len matchedChunk:(Chunks*)chunk queryLen:(int)qLen andIsRev:(BOOL)isRev {
    if ([self isNotDuplicateAlignment:subsArr andChunkNum:cNum]) {
        int pos = [[chunk.matchedPositions objectAtIndex:x] intValue] - cNum*len;
        
        if (pos+qLen<=fileStrLen && pos>-1)
            [positionsArray addObject:[[MatchedReadData alloc] initWithPos:pos isReverse:isRev andEDInfo:NULL andDistance:-2-1]];
    }
}

- (void)setUpChunk:(Chunks*)chunk forQuery:(char*)query numOfChunks:(int)num chunkLen:(int)len start:(int)start andChunkNum:(int)cNum {
    if (cNum < num-1)
        strcpy(chunk.string, strcat(substr(query, start, len),"\0"));
    else
        strcpy(chunk.string, strcat(substr(query, start, len+1),"\0"));
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
