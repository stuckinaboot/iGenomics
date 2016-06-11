//
//  ComputingController.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/11/13.
//
//

#import <UIKit/UIKit.h>
#import "AnalysisController.h"
#import "APFile.h"
#import "BWT.h"
#import "APTimer.h"
#import "CircleProgressBar.h"

#define kPrintReadProcessedInConsole 0
#define kReadProcessedLblTxt @"%i/%i Reads Processed"

#define kComputingTimeRemainingPreCalculatedTxt @"Calculating Time Remaining"
#define kComputingTimeRaminingCalculatedTxt @"%02d:%02d:%02d remaining"

#define kComputingTimeRemainingUpdateInterval 1.0f
#define kComputingTimeRemainingNumOfReadsToBaseTimeOffOf 100
#define kComputingTimeRemainingFracOfReadsToBeginFreqUpdatingAt .5
#define kComputingTimeRemainingNumOfSDsToAddToMeanTimeRemaining 1

#define kShowAnalysisControllerDelay 0 // Wait for viewDidAppear/viewDidDisappear to know the current transition has completed' (error from console), this should fix it

#define kFirstQualValueIndexInReadsToTrim 2
#define kTrimmingOffVal -1
#define kTrimmingRefChar0 '!'
#define kTrimmingRefChar0Index 0
#define kTrimmingRefChar1 '@'
#define kTrimmingRefChar1Index 1

#define kProgressViewFractionFilledFromAligning .9

@interface ComputingController : UIViewController <BWT_Delegate> {
//    IBOutlet UIProgressView *readProgressView;
    IBOutlet CircleProgressBar *readProgressView;
    IBOutlet UILabel *timeRemainingLbl;

    int32_t readsProcessed;
    int32_t readsAligned;
    int timeRemaining;
    double timesToProcessComputingReads[kComputingTimeRemainingNumOfReadsToBaseTimeOffOf];
    
    BWT *bwt;
    AnalysisController *analysisController;
    NSMutableString *exportDataStr;
    
    APTimer *readTimer;
    NSTimer *timeRemainingUpdateTimer;
    
}
- (void)setUpWithReadsFile:(APFile*)myReadsFile andRefFile:(APFile*)myRefFile andParameters:(NSMutableDictionary*)myParameters andImptMutsFile:(APFile*)imptMutsFile;//path is empty if not dropbox
- (NSString*)readsAfterTrimmingForReads:(NSString*)reads andTrimValue:(int)trimValue andReferenceQualityChar:(char)refChar;
- (void)showAnalysisController;
- (void)updateReadsProcessedLblTimeRemaining;

- (void)computeInitialTimeRemaining;
@end
