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
    char *str;
    NSRange range;
    NSMutableArray *matchedPositions;
}
@property (nonatomic) NSRange range;
@property (nonatomic) char* str;
@property (nonatomic) int numOfSubs;
@property (nonatomic, retain) NSMutableArray *matchedPositions;
- (id)initWithString:(char*)string;
@end
