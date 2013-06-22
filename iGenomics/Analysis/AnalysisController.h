//
//  AnalysisController.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/11/13.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "AnalysisPopoverController.h"
#import "InsertionsPopoverController.h"
#import "MutationsInfoPopover.h"
#import "SearchQueryResultsPopover.h"
#import "MatchedReadData.h"

#import "QuickGridView.h"

#import "BWT_Matcher.h"
#import "BWT_MutationFilter.h"
#import "BWT.h"

#import "DNAColors.h"

#define kGraphRowHeight 80

#define kNumOfRowsInGridView 9 //1 ref, 2 found, 3 A, 4 C, 5 G, 6 T, 7 -, 8 +

#define kGraphN 0 //Index of Graph in rows in gridView
#define kRefN 1 //Index of Ref in rows in gridView
#define kFndN 2 //Index of Found in rows in gridView

#define kPinchZoomMaxLevel 2
#define kPinchZoomMinLevel 20
#define kPinchZoomStartingLevel 3
#define kPinchZoomFactor 2 //(in pixels)

#define kPinchZoomFontSizeFactor 15 //(font size)

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

//DON"T INCLUDE $ SIGN IN LEN
//SHOW LOADING SCREEN THE INSTANT BEFORE SEQUENCING STARTS (START SEQUENCING FROM LOADING SCREEN)
//IN UIPOPOVER THAT SHOWS UP FOR A POSITION THAT IS A MUTATION (ALSO SHOW THIS IN THE SHOW ALL MUTATIONS UITABLEVIEW CELLS), EX. for G to - supported by 5 reads, G > - 5 Reads
//ADD UITEXTFIELD FOR MUTATION SUPPORT**MOST PRIORITIZED
//BUTTON TO SEND TABLE OF MUTATIONS TO AN EMAIL ADDRESS AS A TEXT FILE**MOST PRIORITIZED

//POPOVER TO JUMP TO NEXT MUTATION --IN PROGRESS (POPOVER WITH A LIST, SORTED ASCENDING?)---MAKE IT ASCENDING
//MUTATION SUMMARY (DISPLAY ALL MUTATION IN A TABLE VIEW POPOVER, ALONG WITH A LABEL SAYING THE TOTAL NUMBER OF MUTATIONS) - TAPPING A MUTATION WILL SCROLL YOU TO IT--(((ALSO ADD INSERTIONS TO THIS MUTATION LIST????))))--IF SO STILL IN PROGRESS


@interface AnalysisController : UIViewController <QuickGridViewDelegate, MutationsInfoPopoverDelegate, SearchQueryResultsDelegate> {
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
    
    //Data elements
    NSMutableArray *mutPosArray;//Keeps the positions of the mutations for the selected mutation support
    NSMutableArray *allMutPosArray;//Keeps the positions of ALL mutations
    NSArray *querySeqPosArr;//Keeps the positions of the found query sequence (from seqSearch)
}
- (void)pinchOccurred:(UIPinchGestureRecognizer*)sender;
- (void)singleTapOccured:(UITapGestureRecognizer*)sender;
- (void)gridPointClickedWithCoordInGrid:(CGPoint)c andClickedPt:(CGPoint)o;

- (IBAction)posSearch:(id)sender;

- (IBAction)seqSearch:(id)sender;
- (IBAction)showSeqSearchResults:(id)sender;

- (IBAction)mutationSupportStepperChanged:(id)sender;

- (IBAction)showMutTBView:(id)sender;

- (void)readyViewForDisplay:(char*)unraveledStr andInsertions:(NSMutableArray*)iArr andBWT:(BWT*)myBwt andBasicInfo:(NSArray*)basicInfArr;//genome file name, reads file name, read length, genome length, number of reads
- (void)resetDisplay;

- (void)setUpGridLbls;
@end
