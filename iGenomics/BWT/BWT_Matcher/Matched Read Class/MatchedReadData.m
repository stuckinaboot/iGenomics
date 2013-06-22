//
//  MatchedReadData.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 4/28/13.
//
//

#import "MatchedReadData.h"

@implementation MatchedReadData

@synthesize pos, isReverse, info, distance;

- (id)initWithPos:(int)p isReverse:(BOOL)isRev andEDInfo:(ED_Info*)inf andDistance:(int)dist {
    if (self = [super init]) {
        pos = p;
        isReverse = isRev;
        info = inf;
        distance = dist;
    }
    return self;
}

- (void)printToConsole:(char*)read andReadNum:(int)readNum {
    NSString *gappedA = @"";
    NSString *gappedB = @"";
    if (info == NULL) {
        gappedA = [NSString stringWithFormat:@"%s",read];
        gappedB = @"N/A";
    }
    else {
        gappedA = [NSString stringWithFormat:@"%s",info.gappedA];
        gappedB = [NSString stringWithFormat:@"%s",info.gappedB];
        
    }
    NSString *strToPrint = [NSString stringWithFormat:@"\n%i,%s,%i,%@,%@",readNum,read,pos,gappedA,gappedB];
    printf("%s",[strToPrint UTF8String]);
}

@end
