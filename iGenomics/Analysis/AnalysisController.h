//
//  AnalysisController.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/11/13.
//
//

#import <UIKit/UIKit.h>
#import "AnalysisPopoverController.h"
#import "InsertionsPopoverController.h"
#import "MutationsInfoPopover.h"

#import "GridView.h"
#import "BWT_Matcher.h"
#import "BWT_MutationFilter.h"
#import "BWT.h"

#define kNumOfRowsInGridView 8 //0 ref, 1 found, 2 A, 3 C, 4 G, 5 T, 6 -, 7 +

//DISPLAY INSERTIONS IN TABLE VIEW POPOVER IF AN INSERTION GRID BOX IS CLICKED--DONE
//SHOW + IN FOUND SECTION IF THE INSERTION PASSES THE MINIMUM MUTATION COVERAGE THRESHOLD--DONE
//ADD SEARCH BOX FOR POSITION--DONE
//ADD SEARCH BOX FOR A CUSTOM SEQUENCE (EXACT MATCH TO FIND IT, THEN SCROLL TO IT)--DONE (EXCEPT NEEDS A WAY TO HANDLE IF THE QUERY IS NEAR THE END OF THE SEQUENCE, CURRENTLY IT DOES NOT SCROLL ALL THE WAY
//ARROWS TO JUMP TO NEXT MUTATION --IN PROGRESS (OR POSSIBLY A POPOVER WITH A LIST?)
//MUTATION SUMMARY (DISPLAY ALL MUTATION IN A TABLE VIEW POPOVER, ALONG WITH A LABEL SAYING THE TOTAL NUMBER OF MUTATIONS) - TAPPING A MUTATION WILL SCROLL YOU TO IT--DONE
//BUTTON TO SEND TABLE OF MUTATIONS TO AN EMAIL ADDRESS AS A TEXT FILE

@interface AnalysisController : UIViewController <GridViewDelegate, MutationsInfoPopoverDelegate> {
    //Interactive Interface Elements
    IBOutlet UITextField *posSearchTxtFld;
    IBOutlet UITextField *seqSearchTxtFld;
    IBOutlet UIButton *showMutTBViewBtn;
    
    IBOutlet GridView *gridView;
    UIPopoverController *popoverController;
    MutationsInfoPopover *mutsPopover;
    
    //Passed in
    char *originalStr;
    NSMutableArray *insertionsArr;
    BWT *bwt;
    
    //Data elements
    NSMutableArray *mutPosArray;//Keeps the positions of all the mutations
    NSArray *querySeqPosArr;//Keeps the positions of the found query sequence (from seqSearch)
}

- (IBAction)posSearch:(id)sender;
- (IBAction)seqSearch:(id)sender;

- (IBAction)showMutTBView:(id)sender;

- (void)readyViewForDisplay:(char*)unraveledStr andInsertions:(NSMutableArray*)iArr andBWT:(BWT*)myBwt;
- (void)resetDisplay;
@end
