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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadExternalFileWithDict:) name:kFilePickerControllerNotificationExternalFileLoadedKey object:nil];
    
    parametersController = [[ParametersController alloc] init];
    filePickerCurrentlySelecting = kFilePickerSelectingRef;
    
    [self lockContinueBtns];
    
    [FileManager initializeFileSystems];
    
    NSArray *fileTypesDNA = [NSArray arrayWithObjects:kFa, kFq, kFasta, kFastq, nil];
    
    //Ref
    CGRect inputViewRect = CGRectMake(0, 0, refFileInputContainerView.frame.size.width, refFileInputContainerView.frame.size.height);
    
    refInputView = [[AdvancedFileInputView alloc] initWithFrame:inputViewRect];
    [refInputView setDelegate:self];
    [refInputView loadWithFileTypeSelectionOption:FileTypeSelectionOptionRef containingController:self validationExts:fileTypesDNA];
    [refInputView setLocalFiles:[FileManager getLocalFileWithoutContentsArrayFromDirectory:kLocalRefFilesDirectoryName]];
    
    //Reads
    inputViewRect = CGRectMake(0, 0, readsFileInputContainerView.frame.size.width, readsFileInputContainerView.frame.size.height);
    
    readsInputView = [[AdvancedFileInputView alloc] initWithFrame:inputViewRect];
    [readsInputView setDelegate:self];
    [readsInputView loadWithFileTypeSelectionOption:FileTypeSelectionOptionReads containingController:self validationExts:fileTypesDNA];
    [readsInputView setLocalFiles:[FileManager getLocalFileWithoutContentsArrayFromDirectory:kLocalReadsFilesDirectoryName]];
    
    //Impt muts
    NSArray *fileTypesImptMuts = [NSArray arrayWithObjects:kImptMutsFileExt, nil];
    
    inputViewRect = CGRectMake(0, 0, imptMutsFileInputContainerView.frame.size.width, imptMutsFileInputContainerView.frame.size.height);
    
    imptMutsInputView = [[AdvancedFileInputView alloc] initWithFrame:inputViewRect];
    [imptMutsInputView setDelegate:self];
    [imptMutsInputView loadWithFileTypeSelectionOption:FileTypeSelectionOptionImptMuts containingController:self validationExts:fileTypesImptMuts];
    [imptMutsInputView setLocalFiles:[FileManager getLocalFileWithoutContentsArrayFromDirectory:kLocalImptMutsFilesDirectoryName]];
    
    [refFileInputContainerView addSubview:refInputView];
    
    readsInputView.frame = CGRectMake(readsInputView.frame.origin.x, readsInputView.frame.origin.y, readsFileInputContainerView.frame.size.width, readsFileInputContainerView.frame.size.height);
    [readsFileInputContainerView addSubview:readsInputView];
    
    imptMutsInputView.frame = CGRectMake(imptMutsInputView.frame.origin.x, imptMutsInputView.frame.origin.y, imptMutsFileInputContainerView.frame.size.width, imptMutsFileInputContainerView.frame.size.height);
    [imptMutsFileInputContainerView addSubview:imptMutsInputView];
    
    [scrollView setContentOffset:CGPointMake(self.view.frame.size.width*filePickerCurrentlySelecting, 0)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    
    refInputView.frame = CGRectMake(refInputView.frame.origin.x, refInputView.frame.origin.y, refFileInputContainerView.frame.size.width, refFileInputContainerView.frame.size.height);
    [refFileInputContainerView addSubview:refInputView];
    
    readsInputView.frame = CGRectMake(readsInputView.frame.origin.x, readsInputView.frame.origin.y, readsFileInputContainerView.frame.size.width, readsFileInputContainerView.frame.size.height);
    [readsFileInputContainerView addSubview:readsInputView];
    
    imptMutsInputView.frame = CGRectMake(imptMutsInputView.frame.origin.x, imptMutsInputView.frame.origin.y, imptMutsFileInputContainerView.frame.size.width, imptMutsFileInputContainerView.frame.size.height);
    [imptMutsFileInputContainerView addSubview:imptMutsInputView];
    
    [scrollView setContentOffset:CGPointMake(self.view.frame.size.width*filePickerCurrentlySelecting, 0)];
}

- (void)resetScrollViewOffset {
    filePickerCurrentlySelecting = kFilePickerSelectingRef;
    [scrollView setContentOffset:CGPointZero animated:NO];
}

#pragma Button Actions

- (IBAction)showParametersPressed:(id)sender {
    [parametersController passInRefFile:[refInputView getSelectedFile] readsFile:[readsInputView getSelectedFile] andImptMutsFileContents:[imptMutsInputView getSelectedFile]];
    [self presentViewController:parametersController animated:YES completion:nil];
}

- (IBAction)analyzePressed:(id)sender {
    filePickerCurrentlySelecting = kFilePickerSelectingRef;

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

//<<    if ([refInputView nameOfSelectedRow] == nil)
//<<        [self lockContinueBtns];
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
    
    APFile *refFile = [refInputView getSelectedFile];
    APFile *readsFile = [readsInputView getSelectedFile];
    APFile *imptMutsFile = [imptMutsInputView getSelectedFile];
    
    [parametersController passInRefFile:refFile readsFile:readsFile andImptMutsFileContents:imptMutsFile];
    refFile = parametersController.refFile;
    readsFile = parametersController.readsFile;
    
    refFile = [[APFile alloc] initWithName:parametersController.refFileSegmentNames contents:refFile.contents fileType:refFile.fileType];
//    refFile.name = parametersController.refFileSegmentNames;
    
    //Loads past parameters, if they are null set a default set of parameters
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:kLastUsedParamsSaveKey]];
    parameters[kParameterArraySegmentLensKey] = parametersController.refSegmentLens;
    
    NSString *ext = readsFile.ext;
    if ([ext caseInsensitiveCompare:kFq] != NSOrderedSame && [ext caseInsensitiveCompare:kFastq] != NSOrderedSame) {
        parameters = [parameters mutableCopy];
        [parameters setObject:[NSNumber numberWithInt:kTrimmingOffVal] forKey:kParameterArrayTrimmingValKey];//Disables trimming for non-Fq files
    }
    
    if (parameters == NULL) {
        parameters = [[NSMutableDictionary alloc] init];
        
        parameters[kParameterArrayMatchTypeKey] = [NSNumber numberWithInt:2/*Subs and In/Dels*/];
        parameters[kParameterArrayERKey] = [NSNumber numberWithInt:0.1];
        parameters[kParameterArrayFoRevKey] = [NSNumber numberWithInt:1]; /*Alignment type (forward and reverse)*/
        parameters[kParameterArrayMutationCoverageKey] = [NSNumber numberWithInt:2];
        parameters[kParameterArrayTrimmingValKey] = [NSNumber numberWithInt:kTrimmingOffVal];
        parameters[kParameterArrayTrimmingRefCharKey] = [NSString stringWithFormat:@"%c",kTrimmingRefChar0];
        parameters[kParameterArraySeedingOnKey] = [NSNumber numberWithBool:YES];
        
        [defaults setObject:parameters forKey:kLastUsedParamsSaveKey];
        [defaults synchronize];
    }
    
    if (([ext caseInsensitiveCompare:kFq] == NSOrderedSame || [ext caseInsensitiveCompare:kFastq] == NSOrderedSame) && [parameters[kParameterArrayTrimmingValKey] intValue] == kTrimmingOffVal)
        readsFile = [parametersController readsFileByRemovingQualityValFromReadsFile:readsFile];

    [parametersController.computingController setUpWithReadsFile:readsFile andRefFile:refFile andParameters:parameters andImptMutsFile:imptMutsFile];
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

- (void)loadExternalFileWithDict:(NSNotification*)notification {
    NSDictionary *dict = notification.userInfo;
    APFile *file = dict[kFilePickerControllerNotificationExternalFileLoadedDictAPFileKey];
    FileTypeSelectionOption option = [FileManager getFileTypeSelectionOptionOfFile:file];
    
    externalFile = file;
    
    if (option == FileTypeSelectionOptionDNATypeUndetermined) {
        externalFileSelectionOptionAlert = [[UIAlertView alloc] initWithTitle:kFilePickerControllerExternalFileSelectionOptionAlertTitle message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:kFilePickerControllerExternalFileSelectionOptionAlertBtnRefTxt, kFilePickerControllerExternalFileSelectionOptionAlertBtnReadsTxt, nil];
        [externalFileSelectionOptionAlert show];
    }
    else if (option == FileTypeSelectionOptionReads) {
        [self adjustInterfaceForExternalFileWithNewFilePickerCurrentlySelecting:kFilePickerSelectingReads];
    }
    else if (option == FileTypeSelectionOptionImptMuts) {
        [self adjustInterfaceForExternalFileWithNewFilePickerCurrentlySelecting:kFilePickerSelectingImptMuts];
    }
}

- (void)scrollToGivenFilePickerSelection:(int)selection {
    if ([GlobalVars isIpad])
        return;
    filePickerCurrentlySelecting = selection;
    [UIView animateWithDuration:kFilePickerScrollViewAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut  animations:^{
        [scrollView setContentOffset:CGPointMake(filePickerCurrentlySelecting*self.view.frame.size.width, 0) animated:NO];
    } completion:^(BOOL finished){
        self.view.userInteractionEnabled = YES;
    }];
}

- (void)adjustInterfaceForExternalFileWithNewFilePickerCurrentlySelecting:(int)selection {
    filePickerCurrentlySelecting = selection;
    AdvancedFileInputView *inputView;
    
    NSString *fileNameToWriteTo;
    if (filePickerCurrentlySelecting == kFilePickerSelectingRef) {
        fileNameToWriteTo = kLocalRefFilesDirectoryName;
        inputView = refInputView;
    }
    else if (filePickerCurrentlySelecting == kFilePickerSelectingReads) {
        fileNameToWriteTo = kLocalReadsFilesDirectoryName;
        inputView = readsInputView;
    }
    else if (filePickerCurrentlySelecting == kFilePickerSelectingImptMuts) {
        fileNameToWriteTo = kLocalImptMutsFilesDirectoryName;
        inputView = imptMutsInputView;
    }
    
    [FileManager addLocalFile:externalFile inDirectory:fileNameToWriteTo];
    [self scrollToGivenFilePickerSelection:filePickerCurrentlySelecting];
    NSArray *files = [FileManager getLocalFileWithoutContentsArrayFromDirectory:fileNameToWriteTo];
    [inputView setLocalFiles:files];
    [inputView forceDisplayLocalFiles];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView isEqual:externalFileSelectionOptionAlert]) {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:kFilePickerControllerExternalFileSelectionOptionAlertBtnRefTxt]) {
            [self adjustInterfaceForExternalFileWithNewFilePickerCurrentlySelecting:kFilePickerSelectingRef];
        }
        else if ([title isEqualToString:kFilePickerControllerExternalFileSelectionOptionAlertBtnReadsTxt]) {
            [self adjustInterfaceForExternalFileWithNewFilePickerCurrentlySelecting:kFilePickerSelectingReads];
        }
    }
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
- (void)displayFilePreviewPopoverWithContents:(NSString*)contents atLocation:(CGPoint)loc fromFileInputView:(AdvancedFileInputView *)fileInputView {
    CGPoint location = [self.view convertPoint:loc fromView:fileInputView];
    [self displayPopoverOutOfCellWithContents:contents atLocation:location];
}

- (UIViewController*)getVC {
    return self;
}

- (void)fileSelected:(BOOL)isSelected inFileInputView:(id)inputView {
    if ([inputView isEqual:refInputView])
        refFileSelected = isSelected;
    else if ([inputView isEqual:readsInputView])
        readsFileSelected = isSelected;
    else if ([inputView isEqual:imptMutsInputView])
        return;
    
    if (refFileSelected && readsFileSelected)
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
