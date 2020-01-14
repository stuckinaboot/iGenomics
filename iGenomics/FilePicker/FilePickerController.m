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
        [self setModalPresentationStyle:UIModalPresentationFullScreen];
    }
    return self;
}

#pragma Set up methods

- (void)setStuffUp {
    
    CGRect containerRect = CGRectMake(0, topBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - topBar.frame.size.height);
    
    CGRect b = [[UIScreen mainScreen] bounds];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadExternalFileWithDict:) name:kFilePickerControllerNotificationExternalFileLoadedKey object:nil];
    
    parametersController = [[ParametersController alloc] init];
    filePickerCurrentlySelecting = kFilePickerSelectingRef;
    
    [self lockContinueBtns];
    
    [FileManager initializeFileSystems];
    
    NSArray *fileTypesDNA = [NSArray arrayWithObjects:kFa, kFq, kFasta, kFastq, nil];
    
    //Ref
    
    refInputView = [[AdvancedFileInputView alloc] initWithFrame:containerRect];
    [refInputView setDelegate:self];
    [refInputView setSuperView:self.view];
    [refInputView loadWithFileTypeSelectionOption:FileTypeSelectionOptionRef containingController:self validationExts:fileTypesDNA];
    [refInputView setLocalFiles:[FileManager getLocalFileWithoutContentsArrayFromDirectory:kLocalRefFilesDirectoryName]];
    
    //Reads
    readsInputView = [[AdvancedFileInputView alloc] initWithFrame:containerRect];
    [readsInputView setDelegate:self];
    [readsInputView setSuperView:self.view];
    [readsInputView loadWithFileTypeSelectionOption:FileTypeSelectionOptionReads containingController:self validationExts:fileTypesDNA];
    [readsInputView setLocalFiles:[FileManager getLocalFileWithoutContentsArrayFromDirectory:kLocalReadsFilesDirectoryName]];
    
    //Impt muts
    NSArray *fileTypesImptMuts = [NSArray arrayWithObjects:kImptMutsFileExt, nil];
    
    imptMutsInputView = [[AdvancedFileInputView alloc] initWithFrame:containerRect];
    [imptMutsInputView setDelegate:self];
    [imptMutsInputView setSuperView:self.view];
    [imptMutsInputView loadWithFileTypeSelectionOption:FileTypeSelectionOptionImptMuts containingController:self validationExts:fileTypesImptMuts];
    [imptMutsInputView setLocalFiles:[FileManager getLocalFileWithoutContentsArrayFromDirectory:kLocalImptMutsFilesDirectoryName]];
    
    
//    if (![GlobalVars isIpad]) {
        [self.view addSubview:refInputView];
        [refInputView setHidden:YES];
        
        [self.view addSubview:readsInputView];
        [readsInputView setHidden:YES];
        
        [self.view addSubview:imptMutsInputView];
        [imptMutsInputView setHidden:YES];
//    }
}


- (void)viewDidLayoutSubviews {
    if (layoutOnce)
        return;
    layoutOnce = TRUE;

    [self setStuffUp];
    [refAbstractChooseView setUpWithDescriptionTxt:@"Reference:" chosenFileTxt:kAdvancedFileInputViewFileNameLblDefaultTxt];
    [refAbstractChooseView setDelegate:self];
    
    [readsAbstractChooseView setUpWithDescriptionTxt:@"Reads:" chosenFileTxt:kAdvancedFileInputViewFileNameLblDefaultTxt];
    [readsAbstractChooseView setDelegate:self];
    
    [imptMutsAbstractChooseView setUpWithDescriptionTxt:@"Mutations (Optional):" chosenFileTxt:kAdvancedFileInputViewFileNameLblDefaultTxt];
    [imptMutsAbstractChooseView setDelegate:self];
    
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
    
    //Loads past parameters, if they are null set a default set of parameters
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *savedParamsDict = [defaults objectForKey:kLastUsedParamsSaveKey];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:savedParamsDict];
    
    if (savedParamsDict == NULL) {
        parameters = [[NSMutableDictionary alloc] init];
        
        parameters[kParameterArrayMatchTypeKey] = @(MatchTypeSubsAndIndels);
        parameters[kParameterArrayERKey] = [NSNumber numberWithDouble:0.2];
        parameters[kParameterArrayFoRevKey] = kAlignmentTypeForwardAndReverse;/*Alignment type (forward and reverse)*/
        parameters[kParameterArrayMutationCoverageKey] = [NSNumber numberWithInt:5];
        parameters[kParameterArrayTrimmingValKey] = [NSNumber numberWithInt:kTrimmingOffVal];
        parameters[kParameterArrayTrimmingRefCharKey] = [NSString stringWithFormat:@"%c",kTrimmingRefChar0];
        parameters[kParameterArraySeedingOnKey] = [NSNumber numberWithBool:NO];
        
        [defaults setObject:parameters forKey:kLastUsedParamsSaveKey];
        [defaults synchronize];
    }
    
    parameters[kParameterArraySegmentLensKey] = parametersController.refSegmentLens;
    parameters[kParameterArrayReadFileNameKey] = readsFile.name;
    parameters[kParameterArrayRefFileSegmentNamesKey] = parametersController.refFileSegmentNames;
    parameters[kParameterArraySegmentNamesKey] = parametersController.refSegmentNames;
    
    NSString *ext = readsFile.ext;
    if ([ext caseInsensitiveCompare:kFq] != NSOrderedSame && [ext caseInsensitiveCompare:kFastq] != NSOrderedSame) {
        parameters = [parameters mutableCopy];
        [parameters setObject:[NSNumber numberWithInt:kTrimmingOffVal] forKey:kParameterArrayTrimmingValKey];//Disables trimming for non-Fq files
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

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
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

- (void)fileSelectedWithName:(NSString*)fileName inFileInputView:(id)inputView {
    if ([inputView isEqual:refInputView]) {
        [refAbstractChooseView updateChosenFileTxt:fileName];
    }
    else if ([inputView isEqual:readsInputView]) {
        [readsAbstractChooseView updateChosenFileTxt:fileName];
    }
    else if ([inputView isEqual:imptMutsInputView]) {
        [imptMutsAbstractChooseView updateChosenFileTxt:fileName];
    }
}

- (void)choosePressedForChooseView:(id)chooseView {
    if ([chooseView isEqual:refAbstractChooseView]) {
        [refInputView layoutSubviews];
        [refInputView inputBtnPressed:nil];
    } else if ([chooseView isEqual:readsAbstractChooseView]) {
        [readsInputView layoutSubviews];
        [readsInputView inputBtnPressed:nil];
    } else if ([chooseView isEqual:imptMutsAbstractChooseView]) {
        [imptMutsInputView layoutSubviews];
        [imptMutsInputView inputBtnPressed:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
