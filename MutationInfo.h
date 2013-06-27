//
//  MutationInfo.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 6/23/13.
//
//

#import <Foundation/Foundation.h>

@interface MutationInfo : NSObject
@property (nonatomic) int pos;
@property (nonatomic) char refChar;
@property (nonatomic) char* foundChars;
- (id)initWithPos:(int)p andRefChar:(char)refC andFoundChars:(char*)foundC;
+ (char*)createMutStrFromOriginalChar:(char)originalC andFoundChars:(char*)fc;
@end
