//
//  AnalysisController.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/11/13.
//
//

#import <UIKit/UIKit.h>
#import "GridView.h"
#import "BWT_Matcher.h"
#import "BWT_MutationFilter.h"

#define kNumOfRowsInGridView 7 //0 ref, 1 found, 2 A, 3 C, 4 G, 5 T, 6 -,

@interface AnalysisController : UIViewController {
    IBOutlet GridView *gridView;
    
    char *originalStr;
}
- (void)readyViewForDisplay:(char*)unraveledStr;
- (void)resetDisplay;
@end
