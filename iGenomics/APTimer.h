//
//  APTimer.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 9/3/13.
//
//

#import <Foundation/Foundation.h>

//Add function that sums up all of the times

@interface APTimer : NSObject {
    double recordedTime;
    double totalRecordedTime;
    double totalTrials;
}
- (void)start;
- (double)stop;
- (double)stopAndLog;
- (double)getAverageTime;
- (double)getTotalTrials;
- (double)getTotalRecordedTime;
- (void)printTotalRecTime;
@end
