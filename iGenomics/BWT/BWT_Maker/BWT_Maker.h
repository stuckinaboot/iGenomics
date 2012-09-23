//
//  BWT_Create.h
//  LabProject7
//
//  Created by Stuckinaboot Inc. on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BWT_Maker : NSObject {
    NSMutableArray *indexArray;
    char *sequence;
    int sequenceLength;
}
- (char*)createBWTFromResFile:(NSString*)fileName andFileExt:(NSString*)fileExt;
- (char*)getOriginalString;

- (void)sortIndexArrayUsingQuicksort:(NSMutableArray*)array withStartPos:(int)startPos andEndPos:(int)endpos;

- (int)whichIndex:(int)index1 isSmaller:(int)index2;
- (char*)bwtFinalProduct;//The finished BWT

//CALL readyUp and than FinalProduct to perform the create
@end