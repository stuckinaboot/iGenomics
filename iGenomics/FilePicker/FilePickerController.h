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

#import "ParametersController.h"

#define kTxt @"txt"

#define kDefaultRefFilesNamesFile @"NamesOfDefaultReferenceFiles"
#define kDefaultReadsFilesNamesFile @"NamesOfDefaultReadsFiles"

#define kNumOfComponentsInPickers 1

#define kComponent1Title @"Default"

#define kSavedFilesTitle @"Saved Files"
#define kSavedFilesIndex 0
#define kDropboxFilesTitle @"Dropbox Files"
#define kDropboxFilesIndex 1

#define kNumOfFilePickOptions 2

#define kExtDot '.'

#define kLockedBtnAlpha 0.5

//Eventually we can use - (NSFileHandle *)readHandle:(DBError **)error to read x lines (or megabytes) at a time
//fasta is standard format for genome, fastq is standard format for reads

@interface FilePickerController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
    ParametersController *parametersController;
    
    IBOutlet UITableView *referenceFilePicker;
    IBOutlet UISearchBar *refPickerSearchBar;
    IBOutlet UITableView *readsFilePicker;
    IBOutlet UISearchBar *readsPickerSearchBar;
    
    IBOutlet UIButton *analyzeBtn;
    IBOutlet UIButton *configBtn;
    BOOL refSelected;
    BOOL readsSelected;
    
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
}
- (IBAction)showParametersPressed:(id)sender;
- (IBAction)analyzePressed:(id)sender;
- (IBAction)backPressed:(id)sender;

- (IBAction)backRefTbl:(id)sender;
- (IBAction)backReadsTbl:(id)sender;

- (void)setUpDefaultFiles;
- (void)setUpAllDropboxFiles;

- (void)beginActualSequencingPredefinedParameters;

- (void)lockContinueBtns;
- (void)unlockContinueBtns;

- (NSArray*)getFileNameAndExtForFullName:(NSString*)fileName;//returns array with two NSStrings, fileName and fileExt
@end
