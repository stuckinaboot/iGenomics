//
//  ParametersController.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/4/13.
//
//

#import "ParametersController.h"

@interface ParametersController ()

@end

@implementation ParametersController

@synthesize computingController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    computingController = [[ComputingController alloc] init];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)matchTypeChanged:(id)sender {
    if (matchTypeCtrl.selectedSegmentIndex > 0) {
        //Show ED picker
        enterMaxEDLbl.hidden = FALSE;
        maxEDTxtFld.hidden = FALSE;
    }
    else {
        enterMaxEDLbl.hidden = TRUE;
        maxEDTxtFld.hidden = TRUE;
    }
}

- (IBAction)trimmingStateChanged:(id)sender {
    if (trimmingSwitch.on) {
        //Show Num of chars to trim
        enterTrimmingLbl.hidden = FALSE;
        trimmmingTxtFld.hidden = FALSE;
    }
    else {
        enterTrimmingLbl.hidden = TRUE;
        trimmmingTxtFld.hidden = TRUE;
    }
}

- (void)passInSeq:(NSString*)mySeq andReads:(NSString*)myReads andRefFileName:(NSString *)refN andReadFileName:(NSString *)readN {
    seq = mySeq;
    reads = myReads;
    refFileName = refN;
    readFileName = readN;
}

- (IBAction)startSequencingPressed:(id)sender {
    [self presentViewController:computingController animated:YES completion:nil];
    
    [self performSelector:@selector(beginActualSequencing) withObject:nil afterDelay:kStartSeqDelay];
}

- (void)beginActualSequencing {
    int i = (alignmentTypeCtrl.selectedSegmentIndex>0) ? alignmentTypeCtrl.selectedSegmentIndex-1 : alignmentTypeCtrl.selectedSegmentIndex+1;//Because I switched the two in the uisegmentedcontrol and this would require me to change the least amt of code
    
    NSArray *arr = [NSArray arrayWithObjects:[NSNumber numberWithInt:matchTypeCtrl.selectedSegmentIndex], [NSNumber numberWithInt:(matchTypeCtrl.selectedSegmentIndex > 0) ? [maxEDTxtFld.text intValue] : 0], [NSNumber numberWithInt:i], [NSNumber numberWithInt:[mutationSupportTxtFld.text intValue]], [NSNumber numberWithInt:(trimmingSwitch.on) ? [trimmmingTxtFld.text intValue] : 0], nil];//contains everything except refFilename and readsFileName
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:arr forKey:kLastUsedParamsSaveKey];
    [defaults synchronize];

    [computingController setUpWithReads:reads andSeq:seq andParameters:[arr arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:refFileName, readFileName, nil]]];
}

- (IBAction)backPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
