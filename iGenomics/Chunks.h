//
//  Chunks.h
//  LabProject7
//
//  Created by Stuckinaboot Inc. on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Chunks : NSObject {
    int numOfSubs;
    char *string;
    NSMutableArray *matchedPositions;
//    NSMutableArray *subsAtMatchedPositionsArray;
}
@property (nonatomic) char* string;
@property (nonatomic) int numOfSubs;
@property (nonatomic, retain) NSMutableArray *matchedPositions;
//@property (nonatomic, retain) NSMutableArray *subsAtMatchedPositionsArray;
@end
