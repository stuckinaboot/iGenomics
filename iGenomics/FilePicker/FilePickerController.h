//
//  FilePickerController.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/4/13.
//
//

#import <UIKit/UIKit.h>
#import <dropbox/dropbox.h>
#import "APTimer.h"
#import "GlobalVars.h"
#import "FilePreviewPopoverController.h"
#import "AnalysisPopoverController.h"
#import "FileInputView.h"
#import "AdvancedFileInputView.h"
#import "AbstractFileChooseView.h"

#import "ParametersController.h"

#define kOldIphoneTblViewScaleFactor 1.4
#define kFilePickerDistBwtBtnAndTblView 8

#define kRefInputViewInstructLblTxt @"Pick the reference file:"
#define kRefInputViewSearchPlaceholderTxt @"Search reference files..."

#define kReadsInputViewInstructLblTxt @"Pick the reads file:"
#define kReadsInputViewSearchPlaceholderTxt @"Search reads files..."

#define kImptMutsInputViewInstructLblTxt @"Pick the important muts file (Optional):"
#define kImptMutsInputViewSearchPlaceholderTxt @"Search important muts files..."
//Eventually we can use - (NSFileHandle *)readHandle:(DBError **)error to read x lines (or megabytes) at a time
//fasta is standard format for genome, fastq is standard format for reads

#define kFilePickerSelectingRef 0
#define kFilePickerSelectingReads 1
#define kFilePickerSelectingImptMuts 2

#define kFilePickerFastaValidationStr @">"
#define kFilePickerFastqValidationStr @"@"
#define kFilePickerImptMutsFileValidationStr

#define kFilePickerScrollViewAnimationDuration 0.4f

#define kFilePickerControllerNotificationExternalFileLoadedKey @"FilePickerControllerNotificationExternalFileLoadedKey"
#define kFilePickerControllerNotificationExternalFileLoadedDictAPFileKey @"FilePickerControllerNotificationExternalFileLoadedDictAPFileKey"

#define kFilePickerControllerExternalFileSelectionOptionAlertTitle @"Select Type:"
#define kFilePickerControllerExternalFileSelectionOptionAlertBtnRefTxt @"Reference"
#define kFilePickerControllerExternalFileSelectionOptionAlertBtnReadsTxt @"Reads"

@interface FilePickerController : UIViewController <UIPopoverControllerDelegate, AdvancedFileInputViewDelegate, UIAlertViewDelegate, AbstractFileChooseViewDelegate> {
    ParametersController *parametersController;
    
    IBOutlet UIView *contentView;
    
    IBOutlet UIView *refFileInputContainerView;
    AdvancedFileInputView *refInputView;
    BOOL refFileSelected;
    
    IBOutlet UIView *readsFileInputContainerView;
    AdvancedFileInputView *readsInputView;
    BOOL readsFileSelected;
    
    IBOutlet UIView *imptMutsFileInputContainerView;
    AdvancedFileInputView *imptMutsInputView;

    IBOutlet UIButton *analyzeBtn;
    IBOutlet UIButton *configBtn;
    IBOutlet UIButton *nextBtn;
    IBOutlet UINavigationBar *secondDataSelectionBarIPhoneOnly;
    
    IBOutlet UIScrollView *scrollView;
    
    IBOutlet UINavigationBar *topBar;
    IBOutlet AbstractFileChooseView *refAbstractChooseView;
    IBOutlet AbstractFileChooseView *readsAbstractChooseView;
    IBOutlet AbstractFileChooseView *imptMutsAbstractChooseView;
    
    int filePickerCurrentlySelecting;
    
    //Only for old iphone
    BOOL updatedScrollViewSize;
    
    BOOL layoutOnce;
    
    UIAlertView *externalFileSelectionOptionAlert;
    APFile *externalFile;
}
@property (nonatomic, strong) UIPopoverController *previewPopoverController;
- (IBAction)showParametersPressed:(id)sender;
- (IBAction)analyzePressed:(id)sender;
- (IBAction)nextPressedOnIPhone:(id)sender;
- (IBAction)backPressed:(id)sender;

- (void)loadExternalFileWithDict:(NSNotification*)notification;
- (void)adjustInterfaceForExternalFileWithNewFilePickerCurrentlySelecting:(int)selection;
- (void)determineExternalFileSelectionOptionThroughUserAlert;

- (void)scrollToGivenFilePickerSelection:(int)selection;

- (void)resetScrollViewOffset;

//- (void)displayPopoverOutOfCellWithContents:(NSString*)contents;//Popover with textview
- (void)displayPopoverOutOfCellWithContents:(NSString *)contents atLocation:(CGPoint)loc;

- (void)beginActualSequencingPredefinedParameters;

- (void)lockContinueBtns;
- (void)unlockContinueBtns;
@end