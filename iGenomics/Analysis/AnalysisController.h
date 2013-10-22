//
//  AnalysisController.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/11/13.
//
//

typedef enum {
    EmailInfoOptionMutations,
    EmailInfoOptionData
} EmailInfoOption;

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import <dropbox/dropbox.h>

#import "AnalysisPopoverController.h"
#import "InsertionsPopoverController.h"
#import "MutationsInfoPopover.h"
#import "SearchQueryResultsPopover.h"
#import "APTimer.h"

#import "QuickGridView.h"

#import "BWT_Matcher.h"
#import "BWT_MutationFilter.h"
#import "BWT.h"

#import "DNAColors.h"

#define kShowAllMutsBtnTxtNormal @"Show All Mutations"
#define kShowAllMutsBtnTxtUpdating @"Updating..."

#define kSuccessBoxImgName @"SuccessBox.png"
#define kSuccessBoxAlpha 0.8
#define kSuccessBoxDuration 1.8f

#define kErrorAlertExportTitle @"iGenomics: Error"
#define kErrorAlertExportBody @"An error occurred exporting the file."
#define kErrorAlertExportBodyFileNameAlreadyInUse @"File name already used. Would you like to overwrite or cancel?"

#define kExportNameCustomOption @"Export"

#define kGraphRowHeight 80

#define kNumOfRowsInGridView 9 //1 ref, 2 found, 3 A, 4 C, 5 G, 6 T, 7 -, 8 +

#define kGraphN 0 //Index of Graph in rows in gridView
#define kRefN 1 //Index of Ref in rows in gridView
#define kFndN 2 //Index of Found in rows in gridView

#define kPinchZoomMaxLevel 2
#define kPinchZoomMinLevel 20
#define kPinchZoomStartingLevel 3
#define kPinchZoomFactor 2 //(in pixels)

#define kPinchZoomFontSizeFactor 1.2 //(font size)

#define kGridViewTitleLblHolderBorderWidth 7

#define kGenomeLblStart @"Genome: "
#define kReadsLblStart @"Reads: "

#define kLengthLblStart @"Len: "

#define kGenomeCoverageLblStart @"Cov: "

#define kNumOfReadsLblStart @"Num: "

//#define kNumOfRGBVals 10
#define kStartOfAInRGBVals 4
#define kStartOfRefInRGBVals 2

#define kMutationSupportMax 8

#define kSideLblFontSize 20
#define kSideLblStartingX 26
#define kSideLblY 20
#define kSideLblW 30
#define kSideLblH 30

#define kExportASTitle @"Export Data"
#define kExportASEmailMutations @"Email Mutations"
#define kExportASEmailMutsIndex 1 //Index 0 is the cancel button
#define kExportASEmailData @"Email Data"
#define kExportASEmailDataIndex 2
#define kExportASDropboxMuts @"Save Mutations to Dropbox"
#define kExportASDropboxMutsIndex 3
#define kExportASDropboxData @"Save Data to Dropbox"
#define kExportASDropboxDataIndex 4

#define kExportAlertTitle @"File Export"
#define kExportAlertBody @"Enter file name here:"

#define kExportDropboxSaveFileFormatMuts @"%@%@.var.txt"//reads(1..2..3 or no ()).var...
#define kExportDropboxSaveFileFormatData @"%@%@.data.txt"//reads(1..2..3 or no ()).data...
#define kExportDropboxSaveFileExt @".txt"

#define kMutationFormat @"Pos: %i, %s\n"

#define kConfirmDoneAlertTitle @"iGenomics: Analysis"
#define kConfirmDoneAlertMsg @"Would you like to return to the main menu? Note that any unsaved data will be lost."
#define kConfirmDoneAlertGoBtn @"Yes"
#define kConfirmDoneAlertCancelBtn @"No"

#define kReturnToHomeAnimationDuration 10

//DON"T INCLUDE $ SIGN IN LEN
//SHOW LOADING SCREEN THE INSTANT BEFORE SEQUENCING STARTS (START SEQUENCING FROM LOADING SCREEN)
//IN UIPOPOVER THAT SHOWS UP FOR A POSITION THAT IS A MUTATION (ALSO SHOW THIS IN THE SHOW ALL MUTATIONS UITABLEVIEW CELLS), EX. for G to - supported by 5 reads, G > - 5 Reads
//ADD UITEXTFIELD FOR MUTATION SUPPORT**MOST PRIORITIZED
//BUTTON TO SEND TABLE OF MUTATIONS TO AN EMAIL ADDRESS AS A TEXT FILE**MOST PRIORITIZED

//POPOVER TO JUMP TO NEXT MUTATION --IN PROGRESS (POPOVER WITH A LIST, SORTED ASCENDING?)---MAKE IT ASCENDING
//MUTATION SUMMARY (DISPLAY ALL MUTATION IN A TABLE VIEW POPOVER, ALONG WITH A LABEL SAYING THE TOTAL NUMBER OF MUTATIONS) - TAPPING A MUTATION WILL SCROLL YOU TO IT--(((ALSO ADD INSERTIONS TO THIS MUTATION LIST????))))--IF SO STILL IN PROGRESS


//!!!!!NEED TO CREATE LOADING THING WHILE MUTATATION SUPPORT UPDATES (SPINNING ACTIVITY INDICATOR) or a crash will occur

//Display the actual mutation when show mutations is pressed : first

//Need to look through all mutations array at any spot where a mutation is present so that the mutation support is fully functional : third

//Add some save options (such as save actual BWT, save export info to dropbox, email exportinfo (second-highest priority), email list of mutations as a file (highest priority)) : second

@interface AnalysisController : UIViewController <QuickGridViewDelegate, MutationsInfoPopoverDelegate, SearchQueryResultsDelegate, UIActionSheetDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate> {
    DNAColors *dnaColors;
    
    //Interactive Interface Elements
    IBOutlet UITextField *posSearchTxtFld;
    IBOutlet UITextField *seqSearchTxtFld;
    IBOutlet UIButton *showMutTBViewBtn;
    IBOutlet UIButton *showQueryResultsBtn;
    IBOutlet UILabel *mutationSupportNumLbl;
    IBOutlet UIStepper *mutationSupportStpr;//Mutation Support Stepper
    
    //Non-interactive Interface Elements
    UILabel *nLbl[kNumOfRowsInGridView];//cov, ref, found, a, c, g, t, del, ins
    
    UIPinchGestureRecognizer *pinchRecognizer;
    int zoomLevel;
    
    UITapGestureRecognizer *tapRecognizer;
    
    IBOutlet UIImageView *gridViewTitleLblHolder;
    
    IBOutlet UILabel *genomeNameLbl;
    IBOutlet UILabel *genomeLenLbl;
    IBOutlet UILabel *genomeCoverageLbl;
    
    IBOutlet UILabel *readsNameLbl;
    IBOutlet UILabel *readLenLbl;
    IBOutlet UILabel *readNumOfLbl;//Num of reads lbl, I like having read in front though
    
    IBOutlet QuickGridView *gridView;
    IBOutlet UISlider *pxlOffsetSlider;
    UIPopoverController *popoverController;
    MutationsInfoPopover *mutsPopover;
    IBOutlet UIButton *showAllMutsBtn;
    
    BOOL mutsPopoverAlreadyUpdated;
    //Passed in
    char *originalStr;
    NSMutableArray *insertionsArr;
    BWT *bwt;
    
    NSString *genomeFileName;
    NSString *readsFileName;
    int readLen;
    int genomeLen;
    int numOfReads;
    int editDistance;
    
    //Data elements
    NSMutableArray *mutPosArray;//Keeps the positions of the mutations for the selected mutation support
    NSMutableArray *allMutPosArray;//Keeps the positions of ALL mutations
    NSArray *querySeqPosArr;//Keeps the positions of the found query sequence (from seqSearch)
    
    //Used to display data export options
    UIActionSheet *exportActionSheet;
    MFMailComposeViewController *exportMailController;
    NSString *exportDataStr;
    
    //Return to home screen comfirmation alert
    UIAlertView *confirmDoneAlert;
    
    //Select Export Save File Name Alert
    UIAlertView *exportMutsDropboxAlert;
    UIAlertView *exportMutsDropboxErrorAlert;
    UIAlertView *exportDataDropboxAlert;
    UIAlertView *exportDataDropboxErrorAlert;
    NSString *chosenMutsExportPath;
    NSString *chosenDataExportPath;
}
- (void)pinchOccurred:(UIPinchGestureRecognizer*)sender;
- (void)singleTapOccured:(UITapGestureRecognizer*)sender;
- (void)gridPointClickedWithCoordInGrid:(CGPoint)c andClickedPt:(CGPoint)o;

- (IBAction)posSearch:(id)sender;

- (IBAction)seqSearch:(id)sender;

- (IBAction)showSeqSearchResults:(id)sender;

- (IBAction)mutationSupportStepperChanged:(id)sender;

- (IBAction)showMutTBView:(id)sender;
- (IBAction)exportDataPressed:(id)sender;
- (IBAction)donePressed:(id)sender;
- (void)emailInfoForOption:(EmailInfoOption)option;
- (BOOL)saveFileAtPath:(NSString*)path andContents:(NSString*)contents;
- (BOOL)overwriteFileAtPath:(NSString*)path andContents:(NSString*)contents;
- (int)firstAvailableDefaultFileNameForMutsOrData:(int)choice;
- (NSString*)fixChosenExportPathExt:(NSString*)path;

- (void)displaySuccessBox;

- (NSMutableString*)getMutationsExportStr;//Don't need the same method for exportDataStr bc it is a passed in object

- (void)readyViewForDisplay:(char*)unraveledStr andInsertions:(NSMutableArray*)iArr andBWT:(BWT*)myBwt andExportData:(NSString*)exportDataString andBasicInfo:(NSArray*)basicInfArr;//genome file name, reads file name, read length, genome length, number of reads, edit distance chosen by user
- (void)resetDisplay;

- (void)setUpGridLbls;
@end
