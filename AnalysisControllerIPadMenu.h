//
//  AnalysisControllerIPadMenu.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 8/8/14.
//
//

#import <UIKit/UIKit.h>
#import "CoverageHistogram.h"

#define kAnalysisControllerIPadTblElementSearch @"Search"
#define kAnalysisControllerIPadTblElementSegmentPicker @"Segment Picker"
#define kAnalysisControllerIPadTblElementMutSupport @"Mutation Support"
#define kAnalysisControllerIPadTblElementCovHistogram @"Coverage Histogram"

@interface AnalysisControllerIPadMenu : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *tblView;
    NSArray *tblElementsArr;
    
    IBOutlet UIView *elementSearchView;
    
    IBOutlet UIView *elementSegmentPckrView;
    IBOutlet UIView *elementMutSprtView;
    
    CoverageHistogram *covHistogram;
    
    UIPopoverController *popoverController;
}
- (void)setCoverageHistogram:(CoverageHistogram*)histo;
- (void)displayCovHistogramOutOfCell:(UITableViewCell*)cell;
@end
