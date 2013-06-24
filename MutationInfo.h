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
@property (nonatomic) BOOL isHetero;
- (id)initWithPos:(int)p andIsHetero:(BOOL)isH;
@end
