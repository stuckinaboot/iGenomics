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
#import "APTimer.h"

#define kPrintReadProcessedInConsole 0
#define kReadProcessedLblTxt @"%i/%i Reads Processed"

#define kShowAnalysisControllerDelay 1.0f // Wait for viewDidAppear/viewDidDisappear to know the current transition has completed' (error from console), this should fix it

#define kFirstQualValueIndexInReadsToTrim 2
#define kTrimmingOffVal -1
#define kTrimmingRefChar0 '!'
#define kTrimmingRefChar0Index 0
#define kTrimmingRefChar1 '@'
#define kTrimmingRefChar1Index 1

@interface ComputingController : UIViewController <BWT_Delegate> {
    IBOutlet UIProgressView *readProgressView;
    IBOutlet UILabel *readsProcessedLbl;
    int readsProcessed;
    
    BWT *bwt;
    AnalysisController *analysisController;
    NSMutableString *exportDataStr;
}
- (void)setUpWithReads:(NSString*)myReads andSeq:(NSString*)mySeq andParameters:(NSArray*)myParameterArray andRefFilePath:(NSString*)path;//path is empty if not dropbox
- (NSString*)readsAfterTrimmingForReads:(NSString*)reads andTrimValue:(int)trimValue andReferenceQualityChar:(char)refChar;
- (void)showAnalysisController;
@end
