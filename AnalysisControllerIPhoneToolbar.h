//
//  AnalysisControllerIPhoneToolbar.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 3/29/14.
//
//

#import <UIKit/UIKit.h>
#import "GlobalVars.h"
#import "ImportantMutationsDisplayView.h"

#define kGridViewSwitcherCtrlAlignmentsIndex 0
#define kGridViewSwitcherCtrlCovProfileIndex 1

@protocol AnalysisControllerIPhoneToolbarDelegate <NSObject>
- (void)readyViewForCovProfile;
- (void)readyViewForAlignments;
- (void)scrollToPos:(int)pos;
@end
@interface AnalysisControllerIPhoneToolbar : UIView <UIScrollViewDelegate, ImportantMutationsDisplayViewDelegate, UITextFieldDelegate> {
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIPageControl *pageControl;
    IBOutlet UINavigationBar *summaryNavBar;
    
    NSArray *pages;
    IBOutlet UIView *btnsView;
    IBOutlet UIView *lblsView;
}
@property (nonatomic) ImportantMutationsDisplayView *imptMutsDispView;
@property (nonatomic) id <AnalysisControllerIPhoneToolbarDelegate> delegate;
- (IBAction)showAlignmentsPressed:(id)sender;
- (IBAction)showCovProfilePressed:(id)sender;
- (IBAction)donePressed:(id)sender;
- (void)hide;
- (IBAction)pageChanged:(id)sender;
- (void)setUpWithImptMutationList:(NSMutableArray*)imptMutations;
- (void)addDoneBtnForTxtFields:(NSArray*)txtFields;
@end
