//
//  SimpleFileDisplayView.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 8/4/15.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "FileManager.h"
#import "DNAColors.h"
#import "APTableViewCell.h"

#define kSimpleFileDisplayViewBtnDoneTxt @"Done"

#define kSimpleFileDisplayTblItemDeleteLongPressDuration 0.5f
#define kSimpleFileDisplayTblItemDeleteBtnTitle @"Delete"
#define kSimpleFileDisplayTblItemRenameBtnTitle @"Rename"

#define kSimpleFileDisplayViewFadeAnimationDuration 0.25f
#define kSimpleFileDisplayViewUtilityBtnWidthScaleFactor 0.25f;

@protocol SimpleFileDisplayViewDelegate <NSObject>
- (void)fileSelected:(APFile*)file inSimpleFileDisplayView:(id)sfdv;
- (void)deletePressedForFile:(APFile*)file inSimpleFileDisplayView:(id)sfdv;
- (void)renamePressedForFile:(APFile*)file inSimpleFileDisplayView:(id)sfdv;
@end
@interface SimpleFileDisplayView : UIView <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
    UITableView *tblView;
    
    UIView *utilityContainerView;
    UISearchBar *searchBar;
    
    NSArray *entireFileArr;
    NSMutableArray *searchedFileArr;
}
@property (nonatomic) id <SimpleFileDisplayViewDelegate> delegate;
- (IBAction)donePressed:(id)sender;
- (void)displayWithFilesArray:(NSArray*)filesArray deletingFilesEnabled:(BOOL)deletingEnabled;
- (void)presentInView:(UIView*)view;
- (void)removeFromView;

//Long Press Delete
- (void)handleLongPressDeleteGesture:(UILongPressGestureRecognizer *)gestureRecognizer;
- (void)displayDeleteBtnForGestureRecognizer:(UIGestureRecognizer*)recognizer;
- (void)hideUtilityMenu:(NSNotification*)notif;
- (IBAction)deletePressed:(id)sender;
- (IBAction)renamePressed:(id)sender;
@end
