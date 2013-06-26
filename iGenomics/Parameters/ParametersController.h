//
//  ParametersController.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/4/13.
//
//

#import <UIKit/UIKit.h>
#import "ComputingController.h"

//------------Max ED is 10-----------------

/*
 SET OF PARAMETERS:
 
 0-Exact match (0), substitution (1), subs + indels (2) | TYPE: int (exact,sub,subs+indels), int (ED)
      +Max ED
 
 1-Forward alignment(0), forward and reverse alignments (1) | TYPE: int
 
 2-Mutation support (num of disagreements before a position is reported as a mutation): (inputted by user) | TYPE: int
 
 3-Trimming (if selected, chop off last x (user is allowed to chose num) bases) | TYPE: int
 
 4-Seed (chunk) length: automatic, manual (user inputs seed length)  | TYPE: int
     +(Advanced feature)       -------NOT IMPLEMENTED YET
 
 5-Ref File Name
 6-Read File Name
 
 */

#define kStartSeqDelay 0.2

@interface ParametersController : UIViewController {
    NSString *seq;
    NSString *reads;
    
    //Parameters
    IBOutlet UISegmentedControl *matchTypeCtrl;
    IBOutlet UILabel *enterMaxEDLbl;
    IBOutlet UITextField *maxEDTxtFld;
    
    IBOutlet UISegmentedControl *alignmentTypeCtrl;
    
    IBOutlet UITextField *mutationSupportTxtFld;//call it "Minimum Mutation Coverage"
    
    IBOutlet UISwitch *trimmingSwitch;
    IBOutlet UILabel *enterTrimmingLbl;
    IBOutlet UITextField *trimmmingTxtFld;
    //Parameters end
    
    ComputingController *computingController;
    
    NSString *refFileName;
    NSString *readFileName;
}
- (IBAction)matchTypeChanged:(id)sender;
- (IBAction)trimmingStateChanged:(id)sender;

- (IBAction)startSequencingPressed:(id)sender;
- (void)beginActualSequencing;
- (void)passInSeq:(NSString*)mySeq andReads:(NSString*)myReads andRefFileName:(NSString*)refN andReadFileName:(NSString*)readN;
- (IBAction)backPressed:(id)sender;
@end
