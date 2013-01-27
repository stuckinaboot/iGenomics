//
//  AnalysisController.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/11/13.
//
//

#import <UIKit/UIKit.h>
#import "AnalysisPopoverController.h"

#import "GridView.h"
#import "BWT_Matcher.h"
#import "BWT_MutationFilter.h"

#define kNumOfRowsInGridView 8 //0 ref, 1 found, 2 A, 3 C, 4 G, 5 T, 6 -, 7 +

//DISPLAY INSERTIONS IN TABLE VIEW POPOVER IF AN INSERTION GRID BOX IS CLICKED
//SHOW + IN FOUND SECTION IF THE INSERTION PASSES THE MINIMUM MUTATION COVERAGE THRESHOLD
//ADD SEARCH BOX FOR POSITION
//ADD SEARCH BOX FOR A CUSTOM SEQUENCE (EXACT MATCH TO FIND IT, THEN SCROLL TO IT)
//ARROWS TO JUMP TO NEXT MUTATION
//MUTATION SUMMARY (DISPLAY ALL MUTATION IN A TABLE VIEW POPOVER, ALONG WITH A LABEL SAYING THE TOTAL NUMBER OF MUTATIONS) - TAPPING A MUTATION WILL SCROLL YOU TO IT
//BUTTON TO SEND TABLE OF MUTATIONS TO AN EMAIL ADDRESS AS A TEXT FILE

@interface AnalysisController : UIViewController <GridViewDelegate> {
    IBOutlet GridView *gridView;
    UIPopoverController *popoverController;
    
    char *originalStr;
    NSMutableArray *insertionsArr;
}
- (void)readyViewForDisplay:(char*)unraveledStr andInsertions:(NSMutableArray*)iArr;
- (void)resetDisplay;
@end
