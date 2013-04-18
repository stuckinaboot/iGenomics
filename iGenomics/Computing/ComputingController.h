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

#define kPrintReadProcessedInConsole 1

@interface ComputingController : UIViewController <BWT_Delegate> {
    IBOutlet UIProgressView *readProgressView;
    int readsProcessed;
    
    BWT *bwt;
    AnalysisController *analysisController;
}
- (void)setUpWithReads:(NSString*)myReads andSeq:(NSString*)mySeq andParameters:(NSArray*)myParameterArray;
@end
