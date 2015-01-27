//
//  FilePickerController.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/4/13.
//
//

#import "FilePickerController.h"

@interface FilePickerController ()

@end

@implementation FilePickerController

@synthesize previewPopoverController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma Set up methods

- (void)viewDidLoad
{
    parametersController = [[ParametersController alloc] init];
    filePickerCurrentlySelecting = kFilePickerSelectingRef;
    
    [self lockContinueBtns];

    [super viewDidLoad];
    
    //Ref
    NSArray *fileTypesDNA = [NSArray arrayWithObjects:kFa, kFq, kFasta, kFastq, nil];
    
    refFileManager = [[FileManager alloc] init];
    UINib *inputViewNib = [UINib nibWithNibName:kFileInputViewNibName bundle:nil];
    refInputView = [[inputViewNib instantiateWithOwner:refInputView options:nil] objectAtIndex:0];
    
    [refFileManager setUpWithDefaultFileNamesPath:kDefaultRefFilesNamesFile ofType:kTxt];
    [refInputView setUpWithFileManager:refFileManager andInstructLblText:kRefInputViewInstructLblTxt andSearchBarPlaceHolderTxt:kRefInputViewSearchPlaceholderTxt andSupportFileTypes:[NSArray arrayWithObjects:kFa, kFasta, nil] andValidationStrings:[NSArray arrayWithObjects:kFilePickerFastaValidationStr, nil] andMaxFileSize:kFileSizeMaxRef];
    [refInputView setDelegate:self];
    
    //Reads
    readsFileManager = [[FileManager alloc] init];
    readsInputView = [[inputViewNib instantiateWithOwner:readsInputView options:nil] objectAtIndex:0];
    
    [readsFileManager setUpWithDefaultFileNamesPath:kDefaultReadsFilesNamesFile ofType:kTxt];
    [readsInputView setUpWithFileManager:readsFileManager andInstructLblText:kReadsInputViewInstructLblTxt andSearchBarPlaceHolderTxt:kReadsInputViewSearchPlaceholderTxt andSupportFileTypes:fileTypesDNA andValidationStrings:[NSArray arrayWithObjects:kFilePickerFastaValidationStr, kFilePickerFastqValidationStr, nil] andMaxFileSize:kFileSizeMaxReads];
    [readsInputView setDelegate:self];
    
    //Impt muts
    NSArray *fileTypesImptMuts = [NSArray arrayWithObjects:kTxt, nil];
    
    imptMutsFileManager = [[FileManager alloc] init];
    imptMutsInputView = [[inputViewNib instantiateWithOwner:imptMutsInputView options:nil] objectAtIndex:0];
    
    [imptMutsFileManager setUpWithDefaultFileNamesPath:kDefaultImptMutsFilesNamesFile ofType:kTxt];
    [imptMutsInputView setUpWithFileManager:imptMutsFileManager andInstructLblText:kImptMutsInputViewInstructLblTxt andSearchBarPlaceHolderTxt:kImptMutsInputViewSearchPlaceholderTxt andSupportFileTypes:fileTypesImptMuts andValidationStrings:nil andMaxFileSize:kFileSizeMaxImptMuts];
    [imptMutsInputView setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
    
    refInputView.frame = CGRectMake(refInputView.frame.origin.x, refInputView.frame.origin.y, refFileInputContainerView.frame.size.width, refFileInputContainerView.frame.size.height);
    [refFileInputContainerView addSubview:refInputView];
    
    readsInputView.frame = CGRectMake(readsInputView.frame.origin.x, readsInputView.frame.origin.y, readsFileInputContainerView.frame.size.width, readsFileInputContainerView.frame.size.height);
    [readsFileInputContainerView addSubview:readsInputView];
    
    imptMutsInputView.frame = CGRectMake(imptMutsInputView.frame.origin.x, imptMutsInputView.frame.origin.y, imptMutsFileInputContainerView.frame.size.width, imptMutsFileInputContainerView.frame.size.height);
    [imptMutsFileInputContainerView addSubview:imptMutsInputView];
    
    [scrollView setContentOffset:CGPointMake(self.view.frame.size.width*filePickerCurrentlySelecting, 0)];
}

- (void)viewDidAppear:(BOOL)animated {
}

- (void)resetScrollViewOffset {
    filePickerCurrentlySelecting = kFilePickerSelectingRef;
    [scrollView setContentOffset:CGPointZero animated:NO];
}

#pragma Button Actions

- (IBAction)showParametersPressed:(id)sender {
    if (![self allSelectedFilesPassedValidation])
        return;
    
    NSString *s = @"";
    NSString *sName = @"";
    NSString *r = @"";
    NSString *rName = @"";
    
    sName = [refInputView nameOfSelectedRow];
    s = [refInputView contentsOfSelectedRow];

    rName = [readsInputView nameOfSelectedRow];
    r = [readsInputView contentsOfSelectedRow];
    
    [parametersController passInSeq:s andReads:r andRefFileName:sName andReadFileName:rName andImptMutsFileContents:[imptMutsInputView contentsOfSelectedRow]];
    [self presentViewController:parametersController animated:YES completion:nil];
}

- (IBAction)analyzePressed:(id)sender {
    if (![self allSelectedFilesPassedValidation])
        return;
    filePickerCurrentlySelecting = kFilePickerSelectingRef;
    if ([refInputView needsInternetToGetFile] || [readsInputView needsInternetToGetFile] || [imptMutsInputView needsInternetToGetFile])
        if (![GlobalVars internetAvailable])
            return;
    parametersController.computingController = [[ComputingController alloc] init];

    [self presentViewController:parametersController.computingController animated:NO completion:nil];
    [self performSelector:@selector(beginActualSequencingPredefinedParameters) withObject:nil afterDelay:kStartSeqDelay];
}

- (IBAction)nextPressedOnIPhone:(id)sender {
    filePickerCurrentlySelecting++;
    
    self.view.userInteractionEnabled = NO;//Prevents double tapping of btns
    
    [UIView animateWithDuration:kFilePickerScrollViewAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut  animations:^{
        [scrollView setContentOffset:CGPointMake(filePickerCurrentlySelecting*self.view.frame.size.width, 0) animated:NO];
    } completion:^(BOOL finished){
        self.view.userInteractionEnabled = YES;
    }];
    
//    [scrollView setContentOffset:CGPointMake(filePickerCurrentlySelecting*self.view.frame.size.width, 0) animated:YES];

    if ([refInputView nameOfSelectedRow] == nil)
        [self lockContinueBtns];
}

- (void)lockContinueBtns {
    [analyzeBtn setAlpha:kLockedBtnAlpha];
    analyzeBtn.enabled = FALSE;
    [configBtn setAlpha:kLockedBtnAlpha];
    configBtn.enabled = FALSE;
}
- (void)unlockContinueBtns {
    [analyzeBtn setAlpha:1.0f];
    analyzeBtn.enabled = TRUE;
    [configBtn setAlpha:1.0f];
    configBtn.enabled = TRUE;
}

- (void)beginActualSequencingPredefinedParameters {
    NSLog(@"Entered beginActualSequencingPredefinedParameters");
    
    NSString *s = @"";
    NSString *sName = @"";
    NSString *r = @"";
    NSString *rName = @"";
    
    NSString *refFilePath = @"";
    
    sName = [refInputView nameOfSelectedRow];
    s = [refInputView contentsOfSelectedRow];
    
    rName = [readsInputView nameOfSelectedRow];
    r = [readsInputView contentsOfSelectedRow];

    [parametersController passInSeq:s andReads:r andRefFileName:sName andReadFileName:rName andImptMutsFileContents:[imptMutsInputView contentsOfSelectedRow]];
    s = parametersController.seq;
    r = parametersController.reads;
    sName = parametersController.refFileSegmentNames;
    rName = parametersController.readFileName;
    
    //Loads past parameters, if they are null set a default set of parameters
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arr = [defaults objectForKey:kLastUsedParamsSaveKey];
    
    
    NSString *ext = [GlobalVars extFromFileName:rName];
    if ([ext caseInsensitiveCompare:kFq] != NSOrderedSame && [ext caseInsensitiveCompare:kFastq] != NSOrderedSame) {
        arr = [arr mutableCopy];
        [arr setObject:[NSNumber numberWithInt:kTrimmingOffVal] atIndexedSubscript:kParameterArrayTrimmingValIndex];//Disables trimming for non-Fq files
    }
    
    if (arr == NULL) {
        arr = (NSMutableArray*)[NSArray arrayWithObjects:[NSNumber numberWithInt:2/*Subs and In/Dels*/], [NSNumber numberWithInt:2] /*ED*/, [NSNumber numberWithInt:1] /*Alignment type (forward and reverse)*/, [NSNumber numberWithInt:2] /*Mut support*/, [NSNumber numberWithInt:kTrimmingOffVal] /*Trimming*/, [NSString stringWithFormat:@"%c",kTrimmingRefChar0], nil];//Contains everything except refFileName and readFileName
        [defaults setObject:arr forKey:kLastUsedParamsSaveKey];
        [defaults synchronize];
    }
    
    if (([ext caseInsensitiveCompare:kFq] == NSOrderedSame || [ext caseInsensitiveCompare:kFastq] == NSOrderedSame) && [[arr objectAtIndex:kParameterArrayTrimmingValIndex] intValue] == kTrimmingOffVal)
        r = [parametersController readsByRemovingQualityValFromReads:r];
    
    [parametersController.computingController setUpWithReads:r andSeq:s andParameters:[arr arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:sName, rName, nil]] andRefFilePath:refFilePath andImptMutsFileContents:[imptMutsInputView contentsOfSelectedRow]];
}

- (IBAction)backPressed:(id)sender {
    if ([GlobalVars isIpad])
        [self dismissViewControllerAnimated:YES completion:nil];
    else {
        if (filePickerCurrentlySelecting > kFilePickerSelectingRef) {
            filePickerCurrentlySelecting--;
            [scrollView setContentOffset:CGPointMake(filePickerCurrentlySelecting*self.view.frame.size.width, 0) animated:YES];
        }
        else
            [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (BOOL)allSelectedFilesPassedValidation {
    return ([refInputView selectedFilePassedValidation] && [readsInputView selectedFilePassedValidation] && [imptMutsInputView selectedFilePassedValidation]);
}

- (void)displayPopoverOutOfCellWithContents:(NSString *)contents atLocation:(CGPoint)loc {
    if (previewPopoverController.isPopoverVisible)
        return;
    FilePreviewPopoverController *controller = [[FilePreviewPopoverController alloc] init];
    [controller updateTxtViewContents:contents];
    
    if ([GlobalVars isIpad]) {
        previewPopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        [previewPopoverController setPopoverContentSize:controller.txtView.frame.size];
        [previewPopoverController presentPopoverFromRect:CGRectMake(loc.x, loc.y, 1, 1) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown animated:YES];
    }
    else {
        IPhonePopoverHandler *handler = [[IPhonePopoverHandler alloc] init];
        [handler addChildViewController:controller];
        [handler setMainViewController:controller andTitle:kFilePreviewPopoverTitleInIPhonePopoverHandler];
        [controller didMoveToParentViewController:handler];
        [self presentViewController:handler animated:YES completion:nil];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
}

- (NSUInteger)supportedInterfaceOrientations {
    if (![GlobalVars isIpad])
        return UIInterfaceOrientationMaskPortrait;
    else
        return UIInterfaceOrientationMaskLandscape;
}

#pragma File Input View Delegate
- (void)displayFilePreviewPopoverWithContents:(NSString*)contents atLocation:(CGPoint)loc fromFileInputView:(FileInputView *)fileInputView {
    CGPoint location = [self.view convertPoint:loc fromView:fileInputView];
    [self displayPopoverOutOfCellWithContents:contents atLocation:location];
}

- (UIViewController*)getVC {
    return self;
}

- (void)fileSelected:(BOOL)isSelected InFileInputView:(UIView*)inputView {
    if ([inputView isEqual:refInputView])
        refSelected = isSelected;
    else if ([inputView isEqual:readsInputView])
        readsSelected = isSelected;
    if (readsSelected && refSelected)
        [self unlockContinueBtns];
    else
        [self lockContinueBtns];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
