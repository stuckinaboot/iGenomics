//
//  APTimer.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 9/3/13.
//
//

#import "APTimer.h"

@implementation APTimer

- (void)start {
    recordedTime = CFAbsoluteTimeGetCurrent();
    NSLog(@"TIMER START: CURRENT CF TIME = %f", recordedTime);
}

- (double)stop {
    recordedTime = CFAbsoluteTimeGetCurrent()-recordedTime;
    totalRecordedTime += recordedTime;
    totalTrials++;
    return recordedTime;
}

- (double)stopAndLog {
    recordedTime = CFAbsoluteTimeGetCurrent()-recordedTime;
    printf("%f\n",recordedTime);
    totalRecordedTime += recordedTime;
    totalTrials++;
    return recordedTime;
}

- (void)resetTotalRecordedTime {
    totalRecordedTime = 0;
}

- (double)getTotalRecordedTime {
    return totalRecordedTime;
}

- (double)getTotalTrials {
    return totalTrials;
}

- (double)getAverageTime {
    return totalRecordedTime/totalTrials;
}

- (void)printTotalRecTime {
    printf("%f",[self getTotalRecordedTime]);
}
@end
