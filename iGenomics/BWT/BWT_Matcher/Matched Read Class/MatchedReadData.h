//
//  MatchedReadData.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 4/28/13.
//
//

#import <Foundation/Foundation.h>
#import "ED_Info.h"

@interface MatchedReadData : NSObject {

}
@property (nonatomic) int pos;
@property (nonatomic) BOOL isReverse;
@property (nonatomic) ED_Info *info;
- (id)initWithPos:(int)p isReverse:(BOOL)isRev andEDInfo:(ED_Info*)inf;//inf is NULL if not an indel match
- (void)printToConsole:(char*)read andReadNum:(int)readNum;
@end
