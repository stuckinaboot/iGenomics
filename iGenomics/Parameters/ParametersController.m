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

@synthesize computingController, refFile, readsFile, refFileSegmentNames, imptMutsFile;

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
        maxERTxtFld.inputAccessoryView = keyboardToolbar;
        mutationSupportTxtFld.inputAccessoryView = keyboardToolbar;
    }
    
    
    NSString *ext = readsFile.ext;
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
    maxERSldr.maximumValue = kMaxER;
    [self mutationSupportValueChanged:nil];
    [self maxERValueChangedViaSldr:nil];
}

- (IBAction)dismissKeyboard:(id)sender {
    [mutationSupportTxtFld resignFirstResponder];
    [maxERTxtFld resignFirstResponder];
    [self maxERValueChangedViaTxtFld:nil];
}

- (IBAction)useLastUsedParameters:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *parameters = [defaults objectForKey:kLastUsedParamsSaveKey];
    
    if (!parameters)
        return;
    
    matchTypeCtrl.selectedSegmentIndex = [parameters[kParameterArrayMatchTypeKey] intValue];
    [self matchTypeChanged:nil];
    
    maxERSldr.value = [parameters[kParameterArrayERKey] doubleValue];
    [self maxERValueChangedViaSldr:nil];
    
    mutationSupportStpr.value = [parameters[kParameterArrayMutationCoverageKey] intValue];
    [self mutationSupportValueChanged:nil];
    
    seedingSwitch.on = [parameters[kParameterArraySeedingOnKey] boolValue];
    
    NSString *ext = readsFile.ext;
    if ([ext caseInsensitiveCompare:kFq] == NSOrderedSame || [ext caseInsensitiveCompare:kFastq] == NSOrderedSame) {
        trimmingStpr.value = [parameters[kParameterArrayTrimmingValKey] intValue];
        [self trimmingValueChanged:nil];
        
        NSString *trimmingRefCharStr = parameters[kParameterArrayTrimmingRefCharKey];
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
    
    alignmentTypeCtrl.selectedSegmentIndex = [parameters[kParameterArrayFoRevKey] intValue];
}

- (IBAction)matchTypeChanged:(id)sender {
    if (matchTypeCtrl.selectedSegmentIndex > 0) {
        //Show ED picker
        maxERLbl.hidden = FALSE;
        maxERSldr.hidden = FALSE;
        maxERTxtFld.hidden = FALSE;
    }
    else {
        maxERLbl.hidden = TRUE;
        maxERSldr.hidden = TRUE;
        maxERTxtFld.hidden = TRUE;
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
- (IBAction)maxERValueChangedViaSldr:(id)sender {
    maxERTxtFld.text = [NSString stringWithFormat:@"%.02f", maxERSldr.value];
}

- (IBAction)maxERValueChangedViaTxtFld:(id)sender {
    maxERSldr.value = [maxERTxtFld.text doubleValue];
}

- (IBAction)trimmingValueChanged:(id)sender {
    trimmingLbl.text = [NSString stringWithFormat:kTrimmingStprLblTxt,(int)trimmingStpr.value];
}

- (void)passInRefFile:(APFile*)myRefFile readsFile:(APFile*)myReadsFile andImptMutsFileContents:(APFile*)myImptMutsFile {
    refFile = myRefFile;
    readsFile = myReadsFile;
//    refFileSegmentNames = refN;
    imptMutsFile = myImptMutsFile;
    
//    refFile.name = refFileSegmentNames;//Necessary for some later organization of the diff segments -- could possibly be simplified in the future but I have limited time now (leaving for college soon)
    [self fixGenomeFile:refFile];
    
    [self fixReadsFile:readsFile];
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
    
    NSString *ext = readsFile.ext;
    if (!trimmingSwitch.on && ([ext caseInsensitiveCompare:kFq] == NSOrderedSame || [ext caseInsensitiveCompare:kFastq] == NSOrderedSame)) {
        readsFile = [self readsFileByRemovingQualityValFromReadsFile:readsFile];
    }
    
//    NSArray *arr = [NSArray arrayWithObjects:[NSNumber numberWithInt:matchTypeCtrl.selectedSegmentIndex], [NSNumber numberWithDouble:(matchTypeCtrl.selectedSegmentIndex > 0) ? maxERSldr.value : 0], [NSNumber numberWithInt:i], [NSNumber numberWithInt:(int)mutationSupportStpr.value], [NSNumber numberWithInt:(trimmingSwitch.on) ? trimmingStpr.value : kTrimmingOffVal], trimRefChar, [NSNumber numberWithBool:seedingSwitch.on],nil];//contains everything except refFilename and readsFileName
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    parameters[kParameterArrayMatchTypeKey] = [NSNumber numberWithInt:(int)matchTypeCtrl.selectedSegmentIndex];
    parameters[kParameterArrayERKey] = [NSNumber numberWithDouble:(matchTypeCtrl.selectedSegmentIndex > 0) ? maxERSldr.value : 0];
    parameters[kParameterArrayFoRevKey] = [NSNumber numberWithInt:i];
    parameters[kParameterArrayMutationCoverageKey] = [NSNumber numberWithInt:(int)mutationSupportStpr.value];
    parameters[kParameterArrayTrimmingValKey] = [NSNumber numberWithInt:(trimmingSwitch.on) ? trimmingStpr.value : kTrimmingOffVal];
    parameters[kParameterArrayTrimmingRefCharKey] = trimRefChar;
    parameters[kParameterArraySeedingOnKey] = [NSNumber numberWithBool:seedingSwitch.on];
    parameters[kParameterArrayRefFileSegmentNamesKey] = refFileSegmentNames;
    parameters[kParameterArrayReadFileNameKey] = readsFile.name;
    parameters[kParameterArraySegmentNamesKey] = refSegmentNames;
    parameters[kParameterArraySegmentLensKey] = refSegmentLens;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:parameters forKey:kLastUsedParamsSaveKey];
    [defaults synchronize];

    [computingController setUpWithReadsFile:readsFile andRefFile:refFile andParameters:parameters andImptMutsFile:imptMutsFile];
}

- (IBAction)backPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)fixReadsFile:(APFile *)file {
    NSString *ext = file.ext;
    
    NSString *reads = file.contents;
    
    reads = [reads stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    if ([ext isEqualToString:kTxt])
        return;
    
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
        readsFile.contents = reads;
    }
}
- (void)fixGenomeFile:(APFile *)file {
    NSString *ext = file.ext;
    NSString *seq = file.contents;
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
                [namesArray addObject:[str substringWithRange:NSMakeRange(1, [str rangeOfString:kSeparateGenomeNamesSubstringToIndexStr].location)]];//Removes the >
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
        
        refSegmentNames = namesArray;
        refSegmentLens = lengthArray;
        
        NSMutableString *newRefFileName = [[NSMutableString alloc] initWithFormat:@"%@%@",file.name,kRefFileInternalDivider];
        for (int i = 0; i < [namesArray count]; i++) {
            [newRefFileName appendFormat:@"%@%@%i%@",[namesArray objectAtIndex:i], kRefFileInternalDivider, [[lengthArray objectAtIndex:i] intValue], kRefFileInternalDivider];
        }
        refFileSegmentNames = [newRefFileName stringByReplacingCharactersInRange:NSMakeRange(newRefFileName.length-kRefFileInternalDivider.length, kRefFileInternalDivider.length) withString:@""];//Removes the last divider
        
        seq = [seq stringByReplacingOccurrencesOfString:@"$" withString:@""];//Easier than searching for the dollar sign only if more than one ref is present
    }
    if ([seq characterAtIndex:seq.length-1] != '$')
        seq = [NSString stringWithFormat:@"%@$",seq];
    file.contents = seq;
}

- (int)unknownBaseTrimmingIndexForRead:(NSString *)read {
    for (int i = 0; i < read.length; i++) {
        if ([read characterAtIndex:i] == kBaseUnknownChar) {
            return i;
        }
    }
    return -1;
}

- (APFile*)readsFileByRemovingQualityValFromReadsFile:(APFile *)f {
    NSArray *arr = [f.contents componentsSeparatedByString:kLineBreak];
    NSMutableString *readStr = [[NSMutableString alloc] init];
    
    for (int i = 0; i < [arr count]; i += 3) {
        [readStr appendFormat:@"%@\n%@\n",[arr objectAtIndex:i],[arr objectAtIndex:i+1]];
    }
    readStr = (NSMutableString*)[readStr stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
//    readStr = (NSMutableString*)[readStr stringByReplacingCharactersInRange:NSMakeRange(readStr.length-1, 1) withString:@""];//Removes the last line break
    f.contents = readStr;
    return f;
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
