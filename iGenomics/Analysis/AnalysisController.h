//
//  AnalysisController.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/11/13.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import <dropbox/dropbox.h>

#import "OBSlider.h"
#import "AnalysisPopoverController.h"
#import "InsertionsPopoverController.h"
#import "MutationsInfoPopover.h"
#import "SearchQueryResultsPopover.h"
#import "APTimer.h"
#import "AnalysisControllerIPhoneToolbar.h"
#import "FileExporter.h"
#import "CoverageHistogram.h"
#import "QuickGridView.h"
#import "CoverageGridView.h"
#import "AlignmentGridView.h"

#import "BWT_Matcher.h"
#import "BWT_MutationFilter.h"
#import "BWT.h"

#import "DNAColors.h"

#define kConfirmDoneAlertTitle @"iGenomics: Analysis"
#define kConfirmDoneAlertMsg @"Would you like to return to the main menu? Note that any unsaved data will be lost."
#define kConfirmDoneAlertGoBtn @"Yes"
#define kConfirmDoneAlertCancelBtn @"No"
#define kConfirmDoneAlertGoBtnIndex 1

#define kSeqSearchNoResultsAlertTitle @"iGenomics: Analysis"
#define kSeqSearchNoResultsAlertMsg @"No results found"
#define kSeqSearchNoResultsAlertDoneBtn @"Ok"

#define kPosSearchPosOutOfRangeAlertTitle @"iGenomics: Analysis"
#define kPosSearchPosOutOfRangeAlertMsg @"Searched position is out of the range of the segment"
#define kPosSearchPosOutOfRangeAlertBtn @"Ok"

#define kShowAllMutsBtnTxtNormal @"Show All Mutations"
#define kShowAllMutsBtnTxtUpdating @"Updating..."

#define kSuccessBoxImgName @"SuccessBox.png"
#define kSuccessBoxAlpha 0.8
#define kSuccessBoxDuration 1.8f

#define kExportNameCustomOption @"Export"

//#define kGraphRowHeight 80
#define kGraphRowHeightIPhone 20
#define kGraphRowHeightIPad 80

#define kNumOfRowsInGridView 9 //1 ref, 2 found, 3 A, 4 C, 5 G, 6 T, 7 -, 8 +

#define kGraphN 0 //Index of Graph in rows in gridView
#define kRefN 1 //Index of Ref in rows in gridView
#define kFndN 2 //Index of Found in rows in gridView

#define kPinchZoomMaxLevel 3
#define kPinchZoomMinLevel 10
#define kPinchZoomStartingLevel 3
#define kPinchZoomFactor 2 //(in pixels)

#define kPinchZoomFontSizeFactor 1.2 //(font size)

#define kNumOfTapsRequiredToDisplayAnalysisPopover 2

#define kGridViewTitleLblHolderBorderWidth 7

#define kGenomeLblStart @"Genome: "
#define kReadsLblStart @"Reads: "

#define kGenomeLengthLblStart @"Genome Len: "
#define kReadLengthLblStart @"Read Len: "

#define kGenomeCoverageLblStart @"Genome Cov: "

#define kNumOfReadsLblStart @"Num Reads: "

#define kReadPercentMatchedLblStart @"% Matched: "

#define kTotalNumOfMutsLblStart @"Total Num Of Mutations: "

//#define kNumOfRGBVals 10
#define kStartOfAInRGBVals 4
#define kStartOfRefInRGBVals 2

#define kMutationSupportMax 8

#define kSideLblFontSize 16
#define kSideLblStartingX 26
#define kSideLblY 20
#define kSideLblW 40
#define kSideLblH 30

#define kAnalysisNavBarHeightIPhone 44

@interface AnalysisController : UIViewController <QuickGridViewDelegate, MutationsInfoPopoverDelegate, SearchQueryResultsDelegate, UIActionSheetDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate, FileExporterDelegate, AnalysisControllerIPhoneToolbarDelegate> {
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
    int graphRowHeight;
    
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
    IBOutlet UILabel *readPercentMatchedLbl;
    IBOutlet UILabel *totalNumOfMutsLbl;
    
    IBOutlet UIStepper *segmentStpr;
    IBOutlet UILabel *currSegmentLbl;
    
    IBOutlet QuickGridView *gridView;
    CoverageGridView *covGridView;
    AlignmentGridView *alignmentGridView;
    
    IBOutlet OBSlider *pxlOffsetSlider;
    UIPopoverController *popoverController;
    MutationsInfoPopover *mutsPopover;
    IBOutlet UIButton *showAllMutsBtn;
    
    IBOutlet UIBarButtonItem *coverageHistogramBtn;
    CoverageHistogram *coverageHistogram;
    
    BOOL mutsPopoverAlreadyUpdated;
    //Passed in
    char *originalStr;
    NSMutableArray *insertionsArr;
    BWT *bwt;
    
    NSMutableArray *separateGenomeLens;//Contains the genome lengths ordered the same way separateGenomeFileName is
    NSMutableArray *cumulativeSeparateGenomeLens;//Used to quicken detection of which genome is currently being viewed
    NSMutableArray *separateGenomeNames;//Contains the genome names separated by >. The actual file name of the genome is stored in genomeFileName, it is removed in this.
    NSString *genomeFileSegmentNames;
    NSString *genomeFileName;
    NSString *readsFileName;
    int readLen;
    int genomeLen;
    int numOfReads;
    int numOfReadsMatched;
    int editDistance;
    
    NSString *imptMutsFileContents;
    NSMutableArray *imptMutationsArr;
    
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
    
    FileExporter *fileExporter;
    
    IBOutlet AnalysisControllerIPhoneToolbar *analysisControllerIPhoneToolbar;
    
    BOOL firstAppeared;
}
- (IBAction)displayAnalysisIPhoneToolbar:(id)sender;
- (void)setUpIPhoneToolbar;

- (IBAction)showCoverageHistogram:(id)sender;

- (void)pinchOccurred:(UIPinchGestureRecognizer*)sender;
- (void)singleTapOccured:(UITapGestureRecognizer*)sender;
- (void)gridPointClickedWithCoordInGrid:(CGPoint)c andClickedPt:(CGPoint)o;

- (IBAction)posSearch:(id)sender;

- (IBAction)seqSearch:(id)sender;

- (IBAction)showSeqSearchResults:(id)sender;

- (IBAction)mutationSupportStepperChanged:(id)sender;

- (IBAction)showMutTBView:(id)sender;
- (IBAction)exportDataPressed:(id)sender;

- (IBAction)segmentStprValChanged:(id)sender;

- (IBAction)donePressed:(id)sender;

//- (void)displaySuccessBox;

- (void)readyViewForDisplay:(char*)unraveledStr andInsertions:(NSMutableArray*)iArr andBWT:(BWT*)myBwt andExportData:(NSString*)exportDataString andBasicInfo:(NSArray*)basicInfArr andSeparateGenomeNamesArr:(NSMutableArray*)sepGNA andSeparateGenomeLensArr:(NSMutableArray*)sepGLA andCumulativeGenomeLensArr:(NSMutableArray*)cGLA andImptMutsFileContents:(NSString*)mutsFileContents;//genome file name, reads file name, read length, genome length, number of reads, edit distance chosen by user
- (void)resetDisplay;

- (void)resetGridViewForType:(QuickGridView*)gViewType;

- (void)setUpGridLbls;
@end
