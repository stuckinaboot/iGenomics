//
//  APTimer.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 9/3/13.
//
//

#import <Foundation/Foundation.h>

//Add function that sums up all of the times

double recordedTime;
@interface APTimer : NSObject {
    
}
+ (void)start;
+ (double)stop;
+ (double)stopAndLog;
@end
