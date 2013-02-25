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

#import "GridView.h"
#import "BWT_Matcher.h"
#import "BWT_MutationFilter.h"
#import "BWT.h"

#define kGraphRowHeight 50
static double kGraphRGB[3] = {130/255.0f,17/255.0f,243/255.0f};//Should be kept seperate from the rgbVals variable so I don't confuse them because those objects will eventually be created dynamically

#define kNumOfRowsInGridView 9 //1 ref, 2 found, 3 A, 4 C, 5 G, 6 T, 7 -, 8 +

#define kGraphN 0 //Index of Graph in rows in gridView
#define kRefN 1 //Index of Ref in rows in gridView
#define kFndN 2 //Index of Found in rows in gridView

#define kPinchZoomMaxLevel 1
#define kPinchZoomMinLevel 5
#define kPinchZoomStartingLevel 3
#define kPinchZoomFactor 10 //(in pixels)

#define kSetUpGridLblsDelay 0.7 //Eventually labels will need to be created programatically rather in IB

#define kGridViewTitleLblHolderBorderWidth 7

#define kGenomeLblStart @"Genome: "
#define kReadsLblStart @"Reads: "

#define kLengthLblStart @"Len: "

#define kGenomeCoverageLblStart @"Cov: "

#define kNumOfReadsLblStart @"Num: "

#define kNumOfRGBVals 10
#define kStartOfAInRGBVals 4
#define kStartOfRefInRGBVals 2

#define kMutationSupportMax 8

static double rgbVals[kNumOfRGBVals][3] = {{203/255.0f,203/255.0f,203/255.0f},//defBackground
{191/255.0f,191/255.0f,191/255.0f},//defLbl
{95/255.0f,150/255.0f,197/255.0f},//ref
{197/255.0f,215/255.0f,233/255.0f},//found
{78/255.0f,130/255.0f,185/255.0f},//a
{194/255.0f,77/255.0f,78/255.0f},//c
{117/255.0f,147/255.0f,72/255.0f},//g
{254/255.0f,250/255.0f,80/255.0f},//t
{0/255.0f,0/255.0f,0/255.0f},//del
{0/255.0f,0/255.0f,0/255.0f}};//ins


/*static double defBackgroundRGB[3] = {203/255.0f,203/255.0f,203/255.0f};
static double defLblRGB[3] = {191/255.0f,191/255.0f,191/255.0f};
static double refRGB[3] = {95/255.0f,150/255.0f,197/255.0f};
static double foundRGB[3] = {197/255.0f,215/255.0f,233/255.0f};
static double aRGB[3] = {78/255.0f,130/255.0f,185/255.0f};
static double cRGB[3] = {194/255.0f,77/255.0f,78/255.0f};
static double gRGB[3] = {117/255.0f,147/255.0f,72/255.0f};
static double tRGB[3] = {254/255.0f,250/255.0f,80/255.0f};
static double delRGB[3] = {0/255.0f,0/255.0f,0/255.0f};
static double insRGB[3] = {0/255.0f,0/255.0f,0/255.0f};*/

// GET NASAL SPRAY--DONE
//DON"T INCLUDE $ SIGN IN LEN
//SHOW LOADING SCREEN THE INSTANT BEFORE SEQUENCING STARTS (START SEQUENCING FROM LOADING SCREEN)
//IN UIPOPOVER THAT SHOWS UP FOR A POSITION THAT IS A MUTATION (ALSO SHOW THIS IN THE SHOW ALL MUTATIONS UITABLEVIEW CELLS), EX. for G to - supported by 5 reads, G > - 5 Reads
//ADD ABILITY TO PINCH ZOOM, WOULD MAKE THE COLUMNS SMALLER/LARGER, BUT VERTICAL SPACING WOULD REMAIN THE SAME**MOST PRIORITIZED
//FOR DISPLAYING FILE NAMES, "Ref: " and "Reads: "
//ADD UITEXTFIELD FOR MUTATION SUPPORT**MOST PRIORITIZED
//BUTTON TO SEND TABLE OF MUTATIONS TO AN EMAIL ADDRESS AS A TEXT FILE**MOST PRIORITIZED
//EVERY THE POSITION ABOVE THE GRID VIEW EVERY 10TH BASE**MOST PRIORITIZED
//ADD BUTTONS TO SCROLL +/- 10,000 BASES

//MAKE TIMER CLASS

//DISPLAY INSERTIONS IN TABLE VIEW POPOVER IF AN INSERTION GRID BOX IS CLICKED--DONE
//SHOW + IN FOUND SECTION IF THE INSERTION PASSES THE MINIMUM MUTATION COVERAGE THRESHOLD--DONE
//ADD SEARCH BOX FOR POSITION--DONE
//ADD SEARCH BOX FOR A CUSTOM SEQUENCE (EXACT MATCH TO FIND IT, THEN SCROLL TO IT)--DONE
//POPOVER TO JUMP TO NEXT MUTATION --IN PROGRESS (POPOVER WITH A LIST, SORTED ASCENDING?)---MAKE IT ASCENDING
//MUTATION SUMMARY (DISPLAY ALL MUTATION IN A TABLE VIEW POPOVER, ALONG WITH A LABEL SAYING THE TOTAL NUMBER OF MUTATIONS) - TAPPING A MUTATION WILL SCROLL YOU TO IT--(((ALSO ADD INSERTIONS TO THIS MUTATION LIST????))))--IF SO STILL IN PROGRESS


@interface AnalysisController : UIViewController <GridViewDelegate, MutationsInfoPopoverDelegate, SearchQueryResultsDelegate> {
    //Interactive Interface Elements
    IBOutlet UITextField *posSearchTxtFld;
    IBOutlet UITextField *seqSearchTxtFld;
    IBOutlet UIButton *showMutTBViewBtn;
    IBOutlet UIButton *showQueryResultsBtn;
    IBOutlet UILabel *mutationSupportNumLbl;
    IBOutlet UIStepper *mutationSupportStpr;//Mutation Support Stepper
    
    //Non-interactive Interface Elements
    IBOutlet UILabel *refLbl;
    IBOutlet UILabel *foundLbl;
    IBOutlet UILabel *aLbl;
    IBOutlet UILabel *cLbl;
    IBOutlet UILabel *gLbl;
    IBOutlet UILabel *tLbl;
    IBOutlet UILabel *delLbl;
    IBOutlet UILabel *insLbl;
    UILabel *nLbl[kNumOfRowsInGridView];
    
    UIPinchGestureRecognizer *pinchRecognizer;
    int zoomLevel;
    
    IBOutlet UIImageView *gridViewTitleLblHolder;
    
    IBOutlet UILabel *genomeNameLbl;
    IBOutlet UILabel *genomeLenLbl;
    IBOutlet UILabel *genomeCoverageLbl;
    
    IBOutlet UILabel *readsNameLbl;
    IBOutlet UILabel *readLenLbl;
    IBOutlet UILabel *readNumOfLbl;//Num of reads lbl, I like having read in front though
    
    IBOutlet GridView *gridView;
    UIPopoverController *popoverController;
    MutationsInfoPopover *mutsPopover;
    
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
    NSMutableArray *mutPosArray;//Keeps the positions of all the mutations
    NSArray *querySeqPosArr;//Keeps the positions of the found query sequence (from seqSearch)
}
-(void)pinchOccurred:(UIPinchGestureRecognizer*)sender;

- (IBAction)posSearch:(id)sender;

- (IBAction)seqSearch:(id)sender;
- (IBAction)showSeqSearchResults:(id)sender;

- (IBAction)mutationSupportStepperChanged:(id)sender;

- (IBAction)showMutTBView:(id)sender;

- (void)readyViewForDisplay:(char*)unraveledStr andInsertions:(NSMutableArray*)iArr andBWT:(BWT*)myBwt andBasicInfo:(NSArray*)basicInfArr;//genome file name, reads file name, read length, genome length, number of reads
- (void)resetDisplay;

- (void)resetDisplayAfterGridHasBeenCreated;

- (void)setUpGridGraph;

- (void)setUpGridLbls;
@end
