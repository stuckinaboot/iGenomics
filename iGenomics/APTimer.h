//
//  APTimer.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 9/3/13.
//
//

#import <Foundation/Foundation.h>

double recordedTime;
@interface APTimer : NSObject {
    
}
+ (void)start;
+ (double)stop;
+ (double)stopAndLog;
@end
