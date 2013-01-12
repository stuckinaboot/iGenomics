//
//  ParametersController.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/4/13.
//
//

#import <UIKit/UIKit.h>
#import "ComputingController.h"

@interface ParametersController : UIViewController {
    NSString *seq;
    NSString *reads;
    
    ComputingController *computingController;
}
- (IBAction)startSequencingPressed:(id)sender;
- (void)passInSeq:(NSString*)mySeq andReads:(NSString*)myReads;
- (IBAction)backPressed:(id)sender;
@end
