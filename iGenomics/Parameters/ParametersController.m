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

@synthesize computingController, seq, reads, refFileSegmentNames, readFileName, refFilePath, imptMutsFileContents;

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
    
    trimmingStpr.maximumValue = kTrimmingStprMaxVal;
    [self useLastUsedParameters:nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    if (![GlobalVars isIpad]) {
        UIToolbar* keyboardToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, kKeyboardToolbarHeight)];
        
        keyboardToolbar.items = [NSArray arrayWithObjects:
                               [[UIBarButtonItem alloc]initWithTitle:kKeyboardDoneBtnTxt style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard:)],
                               nil];
        maxEDTxtFld.inputAccessoryView = keyboardToolbar;
        mutationSupportTxtFld.inputAccessoryView = keyboardToolbar;
    }
    
    
    NSString *ext = [GlobalVars extFromFileName:readFileName];
    if ([ext caseInsensitiveCompare:kFq] == NSOrderedSame || [ext caseInsensitiveCompare:kFastq] == NSOrderedSame) {
        [self setTrimmingAllowed:YES];
        [self trimmingValueChanged:nil];
        [trimmingRefCharCtrl setTitle:[NSString stringWithFormat:@"%c",kTrimmingRefChar0] forSegmentAtIndex:kTrimmingRefChar0Index];
        [trimmingRefCharCtrl setTitle:[NSString stringWithFormat:@"%c",kTrimmingRefChar1] forSegmentAtIndex:kTrimmingRefChar1Index];
    }
    else {
        [self setTrimmingAllowed:NO];
        trimmingSwitch.on = NO;
        [self trimmingSwitchValueChanged:nil];
    }
    [self mutationSupportValueChanged:nil];
    [self maxEDValueChanged:nil];
}

- (IBAction)dismissKeyboard:(id)sender {
    [mutationSupportTxtFld resignFirstResponder];
    [maxEDTxtFld resignFirstResponder];
}

- (IBAction)useLastUsedParameters:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arr = [defaults objectForKey:kLastUsedParamsSaveKey];
    
    matchTypeCtrl.selectedSegmentIndex = [[arr objectAtIndex:kParameterArrayMatchTypeIndex] intValue];
    [self matchTypeChanged:nil];
    
    maxEDStpr.value = [[arr objectAtIndex:kParameterArrayEDIndex] intValue];
    [self maxEDValueChanged:nil];
    
    mutationSupportStpr.value = [[arr objectAtIndex:kParameterArrayMutationCoverageIndex] intValue];
    [self mutationSupportValueChanged:nil];
    
    NSString *ext = [GlobalVars extFromFileName:readFileName];
    if ([ext caseInsensitiveCompare:kFq] == NSOrderedSame || [ext caseInsensitiveCompare:kFastq] == NSOrderedSame) {
        trimmingStpr.value = [[arr objectAtIndex:kParameterArrayTrimmingValIndex] intValue];
        [self trimmingValueChanged:nil];
        
        NSString *trimmingRefCharStr = [arr objectAtIndex:kParameterArrayTrimmingRefCharIndex];
        if ([trimmingRefCharStr isEqualToString:[NSString stringWithFormat:@"%c",kTrimmingRefChar0]])
            trimmingRefCharCtrl.selectedSegmentIndex = kTrimmingRefChar0Index;
        else if ([trimmingRefCharStr isEqualToString:[NSString stringWithFormat:@"%c", kTrimmingRefChar1]])
            trimmingRefCharCtrl.selectedSegmentIndex = kTrimmingRefChar1Index;
        
        trimmingSwitch.on = (trimmingStpr.value != kTrimmingOffVal);
        [self trimmingSwitchValueChanged:nil];
    }
    else {
        trimmingSwitch.on = NO;
        [self setTrimmingAllowed:NO];
        [self trimmingSwitchValueChanged:nil];
    }
    
    alignmentTypeCtrl.selectedSegmentIndex = [[arr objectAtIndex:kParameterArrayFoRevIndex] intValue];
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

- (IBAction)trimmingSwitchValueChanged:(id)sender {
    if (trimmingSwitch.on) {
        trimmingLbl.hidden = NO;
        trimmingStpr.hidden = NO;
        trimmingRefCharCtrl.hidden = NO;
        trimmingRefCharLbl.hidden = NO;
    }
    else {
        trimmingLbl.hidden = YES;
        trimmingStpr.hidden = YES;
        trimmingRefCharCtrl.hidden = YES;
        trimmingRefCharLbl.hidden = YES;
    }
}

- (void)setTrimmingAllowed:(BOOL)allowed {
    trimmingSwitch.hidden = !allowed;
    trimmingEnabledLbl.hidden = !allowed;
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

- (void)passInSeq:(NSString*)mySeq andReads:(NSString*)myReads andRefFileName:(NSString *)refN andReadFileName:(NSString *)readN andImptMutsFileContents:(NSString *)imptMutsContents {
    seq = mySeq;
    reads = myReads;
    refFileSegmentNames = refN;
    readFileName = readN;
    imptMutsFileContents = imptMutsContents;
    [self fixGenomeForGenomeFileName:refFileSegmentNames];
    [self fixReadsForReadsFileName:readFileName];
}

- (IBAction)startSequencingPressed:(id)sender {
    [self presentViewController:computingController animated:YES completion:nil];
    
    [self performSelector:@selector(beginActualSequencing) withObject:nil afterDelay:kStartSeqDelay];
}

- (void)beginActualSequencing {
    int i = kAlignmentTypeForwardAndReverse;//alignmentTypeCtrl.selectedSegmentIndex;
    
    NSString *trimRefChar;
    if (trimmingRefCharCtrl.selectedSegmentIndex == kTrimmingRefChar0Index)
        trimRefChar = [NSString stringWithFormat:@"%c",kTrimmingRefChar0];
    else if (trimmingRefCharCtrl.selectedSegmentIndex == kTrimmingRefChar1Index)
        trimRefChar = [NSString stringWithFormat:@"%c",kTrimmingRefChar1];
    
    NSString *ext = [GlobalVars extFromFileName:readFileName];
    if (!trimmingSwitch.on && ([ext caseInsensitiveCompare:kFq] == NSOrderedSame || [ext caseInsensitiveCompare:kFastq] == NSOrderedSame)) {
        reads = [self readsByRemovingQualityValFromReads:reads];
    }
    
    NSArray *arr = [NSArray arrayWithObjects:[NSNumber numberWithInt:matchTypeCtrl.selectedSegmentIndex], [NSNumber numberWithInt:(matchTypeCtrl.selectedSegmentIndex > 0) ? (int)maxEDStpr.value : 0], [NSNumber numberWithInt:i], [NSNumber numberWithInt:(int)mutationSupportStpr.value], [NSNumber numberWithInt:(trimmingSwitch.on) ? trimmingStpr.value : kTrimmingOffVal], trimRefChar,nil];//contains everything except refFilename and readsFileName
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:arr forKey:kLastUsedParamsSaveKey];
    [defaults synchronize];

    [computingController setUpWithReads:reads andSeq:seq andParameters:[arr arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:refFileSegmentNames, readFileName, nil]] andRefFilePath:refFilePath andImptMutsFileContents:imptMutsFileContents];
}

- (IBAction)backPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString*)fixReadsForReadsFileName:(NSString *)name {
    NSString *ext = [GlobalVars extFromFileName:name];
    
    reads = [reads stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    if ([ext isEqualToString:kTxt])
        return reads;
    
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:[reads componentsSeparatedByString:kLineBreak]];
    NSMutableString *newReads = [[NSMutableString alloc] init];
    
    int interval = 0;
    
    if ([ext caseInsensitiveCompare:kFa] == NSOrderedSame || [ext caseInsensitiveCompare:kFasta] == NSOrderedSame)
        interval = kFaInterval;//Look at .fa file and this makes sense
    else if ([ext caseInsensitiveCompare:kFq] == NSOrderedSame || [ext caseInsensitiveCompare:kFastq] == NSOrderedSame)
        interval = kFqInterval;//Look at .fq file and this makes sense
    
    if (interval > 0) {
        for (int i = 0; i < [arr count]; i+= interval) {
            NSString *read = [arr objectAtIndex:i+1];
            int trimIndex = [self unknownBaseTrimmingIndexForRead:read];
            
            if (trimIndex >= kMinReadLength || trimIndex == -1) {
                [newReads appendFormat:@"%@\n",[[arr objectAtIndex:i] stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""]];//Read name, takes away the '>' or '@'
                
                if (trimIndex != -1)
                    [newReads appendFormat:@"%@\n",[read substringToIndex:trimIndex]];//Read
                else
                    [newReads appendFormat:@"%@\n",read];
                if (interval == kFqInterval) {
                    if (trimIndex != -1)
                        [newReads appendFormat:@"%@\n",[[arr objectAtIndex:i+3] substringToIndex:trimIndex]];//Adds the quality values
                    else
                        [newReads appendFormat:@"%@\n",[arr objectAtIndex:i+3]];//Adds the quality values
                }
            }
        }
        reads = [newReads stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];//Takes away trailing line breaks
    }
    return reads;
}
- (NSString*)fixGenomeForGenomeFileName:(NSString *)name {
    NSString *ext = [GlobalVars extFromFileName:name];
    if ([ext caseInsensitiveCompare:kFa] == NSOrderedSame) {
        //Remove every line break, and remove the first line because it just has random stuff
        //Finds first line break and removes characters up to and including that point
        
        NSMutableArray *lengthArray = [[NSMutableArray alloc] init];
        NSMutableArray *namesArray = [[NSMutableArray alloc] init];
        
        NSMutableArray *lineArray = (NSMutableArray*)[[seq stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:kLineBreak];
//        int lineLen = [[lineArray objectAtIndex:1] length];//Length of the first DNA sequence
        
        int prevLenIndex = -1;
        
        NSMutableString *newSeq = [[NSMutableString alloc] init];
        
        int len = 0;
        
        for (int i = 0; i < [lineArray count]; i++) {
            NSString *str = [lineArray objectAtIndex:i];
            if ([str characterAtIndex:0] == kFaFileTitleIndicator) {
                [namesArray addObject:[str substringFromIndex:1]];//Removes the >
                [lineArray removeObjectAtIndex:i];
                if (prevLenIndex != -1)
                    [lengthArray addObject:[NSNumber numberWithInt:len]];//lineLen*(i-prevLenIndex)]];
                prevLenIndex = i;
                i--;
                len = 0;
            }
            else {
                len += str.length;
                [newSeq appendString:str];
            }
        }
        
//        int lineArrCount = [lineArray count];
        [lengthArray addObject:[NSNumber numberWithInt:len]];//Last line may have a different length
        seq = [newSeq stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        NSMutableString *newRefFileName = [[NSMutableString alloc] initWithFormat:@"%@%@",name,kRefFileInternalDivider];
        for (int i = 0; i < [namesArray count]; i++) {
            [newRefFileName appendFormat:@"%@%@%i%@",[namesArray objectAtIndex:i], kRefFileInternalDivider, [[lengthArray objectAtIndex:i] intValue], kRefFileInternalDivider];
        }
        refFileSegmentNames = [newRefFileName stringByReplacingCharactersInRange:NSMakeRange(newRefFileName.length-kRefFileInternalDivider.length, kRefFileInternalDivider.length) withString:@""];//Removes the last divider
        
        seq = [seq stringByReplacingOccurrencesOfString:@"$" withString:@""];//Easier than searching for the dollar sign only if more than one ref is present
    }
    if ([seq characterAtIndex:seq.length-1] != '$')
        seq = [NSString stringWithFormat:@"%@$",seq];
    return seq;
}

- (int)unknownBaseTrimmingIndexForRead:(NSString *)read {
    for (int i = 0; i < read.length; i++) {
        if ([read characterAtIndex:i] == kBaseUnknownChar) {
            return i;
        }
    }
    return -1;
}

- (NSString*)readsByRemovingQualityValFromReads:(NSString*)r {
    NSArray *arr = [r componentsSeparatedByString:kLineBreak];
    NSMutableString *readStr = [[NSMutableString alloc] init];
    
    for (int i = 0; i < [arr count]; i += 3) {
        [readStr appendFormat:@"%@\n%@\n",[arr objectAtIndex:i],[arr objectAtIndex:i+1]];
    }
    readStr = (NSMutableString*)[readStr stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
//    readStr = (NSMutableString*)[readStr stringByReplacingCharactersInRange:NSMakeRange(readStr.length-1, 1) withString:@""];//Removes the last line break
    return (NSString*)readStr;
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
