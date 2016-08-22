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

#define kSimpleFileDisplayViewBtnFontSize 25.0f

#define kSimpleFileDisplayTblItemDeleteLongPressDuration 0.5f
#define kSimpleFileDisplayTblItemDeleteBtnTitle @"Delete"
#define kSimpleFileDisplayTblItemRenameBtnTitle @"Rename"

#define kSimpleFileDisplayViewSearchPlaceholderTxt @"Search"

#define kSimpleFileDisplayViewFadeAnimationDuration 0.25f
#define kSimpleFileDisplayViewUtilityBtnHeightScaleFactor 0.16f

#define kSimpleFileDisplayViewAlertRenameFileTitle @"Rename File:"
#define kSimpleFileDisplayViewAlertRenameFileMsg @"Enter a new file name (extension will be automatically appended):"
#define kSimpleFileDisplayViewAlertRenameFileBtnCancel @"Cancel"
#define kSimpleFileDisplayViewAlertRenameFileBtnRename @"Rename"

@protocol SimpleFileDisplayViewDelegate <NSObject>
- (void)fileSelected:(APFile*)file inSimpleFileDisplayView:(id)sfdv;
- (void)deletePressedForFile:(APFile*)file inSimpleFileDisplayView:(id)sfdv;
- (void)renamePressedForFile:(APFile*)file withNewName:(NSString*)newName inSimpleFileDisplayView:(id)sfdv;
- (void)simpleFileDisplayViewDidRemoveFromView;
@end
@interface SimpleFileDisplayView : UIView <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIAlertViewDelegate> {
    UITableView *tblView;
    
    UIView *utilityContainerView;
    UISearchBar *searchBar;
    
    NSArray *entireFileArr;
    NSMutableArray *searchedFileArr;
    
    UIAlertView *renameFileAlert;
    
    BOOL deletingFilesEnabled;
    
    UITapGestureRecognizer *dismissKeyboardRecog;
}
@property (nonatomic) id <SimpleFileDisplayViewDelegate> delegate;
- (IBAction)donePressed:(id)sender;
- (void)displayWithFilesArray:(NSArray*)filesArray deletingFilesEnabled:(BOOL)deletingEnabled;
- (void)presentInView:(UIView*)view;
- (void)removeFromView;

- (void)setLocalFilesArray:(NSArray*)array;

//Long Press Delete
- (void)handleLongPressDeleteGesture:(UILongPressGestureRecognizer *)gestureRecognizer;
- (void)displayDeleteBtnForGestureRecognizer:(UIGestureRecognizer*)recognizer;
- (void)hideUtilityMenu:(NSNotification*)notif;
- (IBAction)deletePressed:(id)sender;
- (IBAction)renamePressed:(id)sender;

- (void)dismissKeyboard;
@end
