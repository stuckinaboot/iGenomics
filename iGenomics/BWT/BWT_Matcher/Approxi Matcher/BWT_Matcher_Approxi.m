//
//  BWT_Matcher_Approxi.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 4/20/13.
//
//

#import "BWT_Matcher_Approxi.h"

@implementation BWT_Matcher_Approxi

- (NSArray*)approxiMatchForQuery:(char*)query withLastCol:(char*)lastCol andFirstCol:(char*)firstCol andNumOfSubs:(int)amtOfSubs andIsReverse:(BOOL)isRev {
    
    if (amtOfSubs == 0)
        return (NSMutableArray*)[self exactMatchForQuery:query withLastCol:lastCol andFirstCol:firstCol andIsReverse:isRev andForOnlyPos:NO];
    
    int numOfChunks = amtOfSubs+1;
    int sizeOfChunks = strlen(query)/numOfChunks;
    int queryLength = strlen(query);
    
    if (fmod(queryLength, 2) != 0) {
        //Odd
        queryLength++;
        sizeOfChunks = (float)queryLength/numOfChunks;
    }
    
    Chunks *chunks[numOfChunks];
    
    for (int i = 0; i<numOfChunks; i++)
        chunks[i] = [[Chunks alloc] init];
    
    int subsInChunk[numOfChunks];
    int start = 0;
    
    NSMutableArray *positionsArray = [[NSMutableArray alloc] init];
    
    if (amtOfSubs>0) {
        for (int i = 0; i<numOfChunks; i++) {
            if (i < numOfChunks-1)
                strcpy(chunks[i].string, strcat(substr(query, start, sizeOfChunks),"\0"));
            else
                strcpy(chunks[i].string, strcat(substr(query, start, sizeOfChunks+1),"\0"));
            start += sizeOfChunks;
        }
        
        if (kDebugOn > 0) {
            for (int i = 0; i<numOfChunks; i++)
                printf("\nCHUNK: %s, %i",chunks[i].string, i);
        }
        int charsToCheckRight = 0;
        int charsToCheckLeft = 0;
        
        int counter = 0;
        
        int numOfSubstitutions = 0;
        
        for (int i = 0; i<numOfChunks; i++) {
            chunks[i].matchedPositions = (NSMutableArray*)[self exactMatchForQuery:chunks[i].string withLastCol:lastCol andFirstCol:firstCol andIsReverse:isRev andForOnlyPos:YES];
            
            if (kDebugOn>0)
                printf("\nNUMBER OF MATCHED POSITIONS FOR CHUNK %i (%s): %i: 1st Matched Pos: %i",i,chunks[i].string,chunks[i].matchedPositions.count,(chunks[i].matchedPositions.count>0)?[[chunks[i].matchedPositions objectAtIndex:0] intValue]:-1);
            
            
            for (int x = 0; x<[chunks[i].matchedPositions count]; x++) {
                counter++;
                
                if (i>0 && i<numOfChunks-1) {
                    charsToCheckLeft = (i)*sizeOfChunks;//i+1?
                    charsToCheckRight = (queryLength-1)-((sizeOfChunks*i+1)+(sizeOfChunks-1));
                }
                else if (i == 0) {
                    charsToCheckLeft = 0;
                    charsToCheckRight = (numOfChunks-1)*sizeOfChunks;
                    if (strlen(query)%2 != 0)
                        charsToCheckRight -= 1;//originally ++
                }
                else if (i == numOfChunks-1) {
                    charsToCheckLeft = (numOfChunks-1)*sizeOfChunks;
                    charsToCheckRight = 0;
                }
                
                int leftStrStart = [[chunks[i].matchedPositions objectAtIndex:x] intValue] - charsToCheckLeft;
                int rightStrStart = [[chunks[i].matchedPositions objectAtIndex:x] intValue]+strlen(chunks[i].string);
                
                
                for (int l = 0; l<charsToCheckLeft; l++) {
                    if (originalStr[l+leftStrStart] != query[l]) {
                        numOfSubstitutions++;
                        subsInChunk[numOfChunks-(int)floorf((float)(l/sizeOfChunks)+1)-(numOfChunks-i-1)-1]++;//orignially no numofchunk or -1
                    }
                }
                
                if (rightStrStart>=fileStrLen-1)
                    charsToCheckRight = 0;
                for (int l = 0; l<charsToCheckRight; l++) {
                    
                    if (originalStr[l+rightStrStart] != query[(i+1)*sizeOfChunks+l]) {//-1
                        numOfSubstitutions++;
                        
                        subsInChunk[(int)floorf((float)l/sizeOfChunks)+1+i]++;
                        
                        if (numOfSubstitutions > amtOfSubs)
                            break;
                    }
                }
                
                if (numOfSubstitutions<=amtOfSubs) {
                    NSMutableArray *array = [[NSMutableArray alloc] init];
                    for (int r = 0; r<numOfChunks; r++) {
                        [array addObject:[NSNumber numberWithInt:subsInChunk[r]]];
                    }
                    
                    if ([self isNotDuplicateAlignment:array andChunkNum:i]) {
                        int pos = [[chunks[i].matchedPositions objectAtIndex:x] intValue] - i*sizeOfChunks;
                        
                        if (pos+strlen(query)<=strlen(refStrBWT) && pos>-1) {
                            [positionsArray addObject:[[MatchedReadData alloc] initWithPos:pos isReverse:isRev andEDInfo:NULL]];
                        }
                    }
                }
                
                numOfSubstitutions = 0;
                for (int r = 0; r<numOfChunks; r++) {
                    subsInChunk[r] = 0;
                }
            }
            
        }
    }
    return positionsArray;
}

@end
