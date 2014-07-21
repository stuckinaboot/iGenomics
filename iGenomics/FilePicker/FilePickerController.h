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

#import "ParametersController.h"

#define kOldIphoneTblViewScaleFactor 1.4
#define kFilePickerDistBwtBtnAndTblView 8

//Eventually we can use - (NSFileHandle *)readHandle:(DBError **)error to read x lines (or megabytes) at a time
//fasta is standard format for genome, fastq is standard format for reads

@interface FilePickerController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIPopoverControllerDelegate> {
    ParametersController *parametersController;
    
    IBOutlet UIView *contentView;
    
    IBOutlet UITableView *referenceFilePicker;
    IBOutlet UISearchBar *refPickerSearchBar;
    IBOutlet UITableView *readsFilePicker;
    IBOutlet UISearchBar *readsPickerSearchBar;
    
    IBOutlet UIButton *analyzeBtn;
    IBOutlet UIButton *configBtn;
    IBOutlet UIButton *nextBtn;
    IBOutlet UINavigationBar *secondDataSelectionBarIPhoneOnly;
    BOOL refSelected;
    BOOL readsSelected;
    
    IBOutlet UIScrollView *scrollView;
    
    NSMutableArray *defaultRefFilesNames;
    NSMutableArray *filteredRefFileNames;
    NSMutableArray *defaultReadsFilesNames;
    NSMutableArray *filteredReadFileNames;
    
    NSMutableArray *allDropboxFiles;
    DBFilesystem *dbFileSys;
    
    int selectedOptionRef;
    int selectedRowRef;
    DBPath *parentFolderPathRef;
    int selectedOptionReads;
    int selectedRowReads;
    DBPath *parentFolderPathReads;
    
    BOOL isSelectingReads;
    
    //Only for old iphone
    BOOL updatedScrollViewSize;
}
@property (nonatomic, strong) UIPopoverController *previewPopoverController;
- (IBAction)showParametersPressed:(id)sender;
- (IBAction)analyzePressed:(id)sender;
- (IBAction)nextPressedOnIPhone:(id)sender;
- (IBAction)backPressed:(id)sender;

- (IBAction)backRefTbl:(id)sender;
- (IBAction)backReadsTbl:(id)sender;

- (void)setUpDefaultFiles;
- (void)setUpAllDropboxFiles;

- (void)resetScrollViewOffset;

- (IBAction)cellDoubleTappedRef:(id)sender;
- (IBAction)cellDoubleTappedReads:(id)sender;
//- (void)displayPopoverOutOfCellWithContents:(NSString*)contents;//Popover with textview
- (void)displayPopoverOutOfCellWithContents:(NSString *)contents atLocation:(CGPoint)loc;

- (void)beginActualSequencingPredefinedParameters;

- (void)lockContinueBtns;
- (void)unlockContinueBtns;

- (NSMutableArray*)fileArrayByKeepingOnlyFaAndFqFilesForDropboxFileArray:(NSMutableArray*)array;
- (NSArray*)getFileNameAndExtForFullName:(NSString*)fileName;//returns array with two NSStrings, fileName and fileExt
@end