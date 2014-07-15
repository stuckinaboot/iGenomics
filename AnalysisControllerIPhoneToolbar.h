//
//  AnalysisControllerIPhoneToolbar.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 3/29/14.
//
//

#import <UIKit/UIKit.h>
#import "GlobalVars.h"

@protocol AnalysisControllerIPhoneToolbarDelegate <NSObject>
- (void)readyViewForCovProfile;
- (void)readyViewForAlignments;
@end
@interface AnalysisControllerIPhoneToolbar : UIView <UIScrollViewDelegate> {
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIPageControl *pageControl;
    IBOutlet UINavigationBar *summaryNavBar;
    
    NSArray *pages;
    IBOutlet UIView *btnsView;
    IBOutlet UIView *lblsView;
}
@property (nonatomic) id <AnalysisControllerIPhoneToolbarDelegate> delegate;
- (IBAction)showAlignmentsPressed:(id)sender;
- (IBAction)showCovProfilePressed:(id)sender;
- (IBAction)donePressed:(id)sender;
- (void)hide;
- (IBAction)pageChanged:(id)sender;
- (void)setUp;
- (void)addDoneBtnForTxtFields:(NSArray*)txtFields;
@end
