//
//  APTimer.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 9/3/13.
//
//

#import "APTimer.h"

@implementation APTimer

+ (void)start {
    recordedTime = CFAbsoluteTimeGetCurrent();
}

+ (double)stop {
    recordedTime = CFAbsoluteTimeGetCurrent()-recordedTime;
    return recordedTime;
}

+ (double)stopAndLog {
    recordedTime = CFAbsoluteTimeGetCurrent()-recordedTime;
    printf("%f\n",recordedTime);
    return recordedTime;
}
@end
