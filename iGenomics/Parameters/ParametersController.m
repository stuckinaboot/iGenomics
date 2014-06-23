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

@synthesize computingController, seq, reads;

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

- (void)viewDidAppear:(BOOL)animated {
    if (![GlobalVars isIpad]) {
        UIToolbar* keyboardToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, kKeyboardToolbarHeight)];
        
        keyboardToolbar.items = [NSArray arrayWithObjects:
                               [[UIBarButtonItem alloc]initWithTitle:kKeyboardDoneBtnTxt style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard:)],
                               nil];
        maxEDTxtFld.inputAccessoryView = keyboardToolbar;
        mutationSupportTxtFld.inputAccessoryView = keyboardToolbar;
    }
    
    if ([[self extFromFileName:readFileName] caseInsensitiveCompare:kFq] == NSOrderedSame) {
        [self setTrimmingAllowed:YES];
        [self trimmingValueChanged:nil];
        [trimmingRefCharCtrl setTitle:[NSString stringWithFormat:@"%c",kTrimmingRefChar0] forSegmentAtIndex:kTrimmingRefChar0Index];
        [trimmingRefCharCtrl setTitle:[NSString stringWithFormat:@"%c",kTrimmingRefChar1] forSegmentAtIndex:kTrimmingRefChar1Index];
    }
    else
        [self setTrimmingAllowed:NO];
    [self mutationSupportValueChanged:nil];
    [self maxEDValueChanged:nil];
}

- (IBAction)dismissKeyboard:(id)sender {
    [mutationSupportTxtFld resignFirstResponder];
    [maxEDTxtFld resignFirstResponder];
}

- (IBAction)matchTypeChanged:(id)sender {
    if (matchTypeCtrl.selectedSegmentIndex > 0) {
        //Show ED picker
        maxEDLbl.hidden = FALSE;
        maxEDStpr.hidden = FALSE;
        maxEDTxtFld.hidden = FALSE;
    }
    else {
        maxEDLbl.hidden = TRUE;
        maxEDStpr.hidden = TRUE;
        maxEDTxtFld.hidden = TRUE;
    }
}

- (void)setTrimmingAllowed:(BOOL)allowed {
    trimmingLbl.hidden = !allowed;
    trimmingStpr.hidden = !allowed;
    trimmingRefCharCtrl.hidden = !allowed;
    trimmingRefCharLbl.hidden = !allowed;
}

- (IBAction)mutationSupportValueChanged:(id)sender {
    mutationSupportLbl.text = [NSString stringWithFormat:kMutSupportLblTxt,(int)mutationSupportStpr.value];
}
- (IBAction)maxEDValueChanged:(id)sender {
    maxEDLbl.text = [NSString stringWithFormat:kMaxEDLblTxt,(int)maxEDStpr.value];
}

- (IBAction)trimmingValueChanged:(id)sender {
    trimmingLbl.text = [NSString stringWithFormat:kTrimmingStprLblTxt,(int)trimmingStpr.value];
}

- (void)passInSeq:(NSString*)mySeq andReads:(NSString*)myReads andRefFileName:(NSString *)refN andReadFileName:(NSString *)readN {
    seq = mySeq;
    reads = myReads;
    refFileName = refN;
    readFileName = readN;
    [self fixGenomeForGenomeFileName:refFileName];
    [self fixReadsForReadsFileName:readFileName];
}

- (IBAction)startSequencingPressed:(id)sender {
    [self presentViewController:computingController animated:YES completion:nil];
    
    [self performSelector:@selector(beginActualSequencing) withObject:nil afterDelay:kStartSeqDelay];
}

- (void)beginActualSequencing {
    int i = (alignmentTypeCtrl.selectedSegmentIndex>0) ? alignmentTypeCtrl.selectedSegmentIndex-1 : alignmentTypeCtrl.selectedSegmentIndex+1;//Because I switched the two in the uisegmentedcontrol and this would require me to change the least amt of code
    
    NSString *trimRefChar;
    if (trimmingRefCharCtrl.selectedSegmentIndex == kTrimmingRefChar0Index)
        trimRefChar = [NSString stringWithFormat:@"%c",kTrimmingRefChar0];
    else if (trimmingRefCharCtrl.selectedSegmentIndex == kTrimmingRefChar1Index)
        trimRefChar = [NSString stringWithFormat:@"%c",kTrimmingRefChar1];
    
    NSArray *arr = [NSArray arrayWithObjects:[NSNumber numberWithInt:matchTypeCtrl.selectedSegmentIndex], [NSNumber numberWithInt:(matchTypeCtrl.selectedSegmentIndex > 0) ? (int)maxEDStpr.value : 0], [NSNumber numberWithInt:i], [NSNumber numberWithInt:(int)mutationSupportStpr.value], [NSNumber numberWithInt:(!trimmingLbl.hidden) ? trimmingStpr.value : kTrimmingOffVal], trimRefChar,nil];//contains everything except refFilename and readsFileName
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:arr forKey:kLastUsedParamsSaveKey];
    [defaults synchronize];

    [computingController setUpWithReads:reads andSeq:seq andParameters:[arr arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:refFileName, readFileName, nil]]];
}

- (IBAction)backPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString*)fixReadsForReadsFileName:(NSString *)name {
    NSString *ext = [self extFromFileName:name];
    
    if ([ext isEqualToString:kTxt])
        return reads;
    
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:[reads componentsSeparatedByString:kLineBreak]];
    [arr removeLastObject];//Need to make sure is correct for all files
    NSMutableString *newReads = [[NSMutableString alloc] init];
    
    int interval = 0;
    
    if ([ext caseInsensitiveCompare:kFa] == NSOrderedSame)
        interval = kFaInterval;//Look at .fa file and this makes sense
    else if ([ext caseInsensitiveCompare:kFq] == NSOrderedSame)
        interval = kFqInterval;//Look at .fq file and this makes sense
    
    if (interval > 0) {
        for (int i = 0; i < [arr count]; i+= interval) {
            [newReads appendFormat:@"%@\n",[[arr objectAtIndex:i] stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""]];//Read name, takes away the '>' or '@'
            [newReads appendFormat:@"%@\n",[arr objectAtIndex:i+1]];//Read
            if (interval == kFqInterval)
                [newReads appendFormat:@"%@\n",[arr objectAtIndex:i+3]];//Adds the quality values
        }
        reads = [newReads stringByReplacingCharactersInRange:NSMakeRange(newReads.length-1, 1) withString:@""];//Takes away the trailing line break
    }
    return reads;
}
- (NSString*)fixGenomeForGenomeFileName:(NSString *)name {
    NSString *ext = [self extFromFileName:name];
    if ([ext caseInsensitiveCompare:kFa] == NSOrderedSame) {
        //Remove every line break, and remove the first line because it just has random stuff
        //Finds first line break and removes characters up to and including that point
        int index = [seq rangeOfString:kLineBreak].location;
        seq = [seq stringByReplacingCharactersInRange:NSMakeRange(0, index+1) withString:@""];
        seq = [seq stringByReplacingOccurrencesOfString:kLineBreak withString:@""];
    }
    int len = seq.length;
    if ([seq characterAtIndex:len-1] != '$')
        seq = [NSString stringWithFormat:@"%@$",seq];
    return seq;
}
- (NSString*)extFromFileName:(NSString *)name {
    return [name substringFromIndex:[name rangeOfString:@"." options:NSBackwardsSearch].location+1];
}

- (NSUInteger)supportedInterfaceOrientations {
    if (![GlobalVars isIpad])
        return UIInterfaceOrientationMaskPortrait;
    else
        return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
