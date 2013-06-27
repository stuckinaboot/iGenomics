//
//  ComputingController.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/11/13.
//
//

#import <UIKit/UIKit.h>
#import "AnalysisController.h"
#import "BWT.h"

#define kPrintReadProcessedInConsole 0

#define kShowAnalysisControllerDelay 1.0f // Wait for viewDidAppear/viewDidDisappear to know the current transition has completed' (error from console), this should fix it

@interface ComputingController : UIViewController <BWT_Delegate> {
    IBOutlet UIProgressView *readProgressView;
    int readsProcessed;
    
    BWT *bwt;
    AnalysisController *analysisController;
    NSMutableString *exportDataStr;
}
- (void)setUpWithReads:(NSString*)myReads andSeq:(NSString*)mySeq andParameters:(NSArray*)myParameterArray;
- (void)showAnalysisController;
@end
