//
//  ParametersController.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/4/13.
//
//

#import <UIKit/UIKit.h>
#import "ComputingController.h"
#import "APTimer.h"
#import "Read.h"

//------------Max ED is 10-----------------

/*
 SET OF PARAMETERS:
 
 0-Exact match (0), substitution (1), subs + indels (2) | TYPE: int (exact,sub,subs+indels), 1-int (ED)
      +Max ED
 
 2-Forward alignment(0), forward and reverse alignments (1) | TYPE: int
 
 3-Mutation support (num of disagreements before a position is reported as a mutation): (inputted by user) | TYPE: int
 
 4-Trimming (if selected, chop off last x (user is allowed to chose num) bases) | TYPE: int
 
 -Seed (chunk) length: automatic, manual (user inputs seed length)  | TYPE: int
     +(Advanced feature)       -------NOT IMPLEMENTED YET
 
 5-Ref File Name
 6-Read File Name
 
 */

//Special File Types End

#define kLastUsedParamsSaveKey @"LastUsedParamsKey"
#define kMaxERLblTxt @"Maximum Error Rate:"
#define kMutSupportLblTxt @"Mutation Coverage: %i"

#define kStartSeqDelay 0.2

#define kTrimmingStprMaxVal 20
#define kTrimmingStprLblTxt @"Value: %i"

@interface ParametersController : UIViewController {
    
    //Parameters
    IBOutlet UISegmentedControl *matchTypeCtrl;
    IBOutlet UILabel *maxERLbl;
    IBOutlet UITextField *maxERTxtFld;
    IBOutlet UISlider *maxERSldr;
    
    IBOutlet UISegmentedControl *alignmentTypeCtrl;
    
    IBOutlet UITextField *mutationSupportTxtFld;//call it "Minimum Mutation Coverage"
    IBOutlet UIStepper *mutationSupportSlider;
    IBOutlet UILabel *mutationSupportLbl;
    
    IBOutlet UIStepper *trimmingStpr;
    IBOutlet UILabel *trimmingLbl;
    IBOutlet UILabel *trimmingRefCharLbl;
    IBOutlet UISegmentedControl *trimmingRefCharCtrl;
    IBOutlet UISwitch *trimmingSwitch;
    IBOutlet UILabel *trimmingEnabledLbl;
    
    IBOutlet UISwitch *seedingSwitch;
    //Parameters end
    
    ComputingController *computingController;
    
    NSArray *refSegmentNames;
    NSArray *refSegmentLens;
}
@property (nonatomic) ComputingController *computingController;
@property (nonatomic) APFile *refFile, *readsFile, *imptMutsFile;
@property (nonatomic) NSString *refFileSegmentNames;
@property (nonatomic) NSArray *refSegmentLens, *refSegmentNames;
- (IBAction)matchTypeChanged:(id)sender;
- (IBAction)dismissKeyboard:(id)sender;
- (IBAction)mutationSupportValueChanged:(id)sender;
- (IBAction)trimmingValueChanged:(id)sender;
- (IBAction)trimmingSwitchValueChanged:(id)sender;
- (IBAction)maxERValueChangedViaSldr:(id)sender;
- (IBAction)maxERValueChangedViaTxtFld:(id)sender;

- (IBAction)useLastUsedParameters:(id)sender;

- (IBAction)startSequencingPressed:(id)sender;
- (void)beginActualSequencing;
- (void)passInRefFile:(APFile*)myRefFile readsFile:(APFile*)myReadsFile andImptMutsFileContents:(APFile*)myImptMutsFile;
- (IBAction)backPressed:(id)sender;

- (void)setTrimmingAllowed:(BOOL)allowed;

- (int)unknownBaseTrimmingIndexForRead:(NSString*)read;//-1 if shouldn't trim at all

- (void)fixReadsFile:(APFile*)file;//Checks for .fa and .fq,returns types NSString so it can be accessed from FilePickerController
- (void)fixGenomeFile:(APFile*)file;//Checks for .fq
- (APFile*)readsFileByRemovingQualityValFromReadsFile:(APFile*)f;
@end
