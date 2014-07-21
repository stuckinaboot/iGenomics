//
//  FileInputView.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 7/21/14.
//
//

#import <UIKit/UIKit.h>
#import <dropbox/dropbox.h>
#import "FileManager.h"

#define kNumOfComponentsInPickers 1

#define kComponent1Title @"Default"

#define kSavedFilesTitle @"Saved Files"
#define kSavedFilesIndex 0
#define kDropboxFilesTitle @"Dropbox Files"
#define kDropboxFilesIndex 1

#define kNumOfFilePickOptions 2

#define kFastaFileExt @"fa"

#define kLockedBtnAlpha 0.5

#define kMinTapsRequired 2

@protocol FileInputViewDelegate <NSObject>
- (void)displayFilePreviewPopoverWithContents:(NSString*)contents atLocation:(CGPoint)loc;
- (UIViewController*)getVC;
@end
@interface FileInputView : UIView <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIPopoverControllerDelegate> {
    IBOutlet UISearchBar *searchBar;
    IBOutlet UITableView *tblView;
    IBOutlet UILabel *instructLbl;
    
    NSMutableArray *filteredFileNames;
    
    FileManager *fileManager;
    DBPath *parentPath;
    int selectedOption;
}
@property (nonatomic) id <FileInputViewDelegate> delegate;
- (IBAction)backTbl:(id)sender;
- (IBAction)cellDoubleTapped:(id)sender;
- (void)setUpWithFileManager:(FileManager *)manager andInstructLblText:(NSString *)instructTxt andSearchBarPlaceHolderTxt:(NSString *)placeHolderTxt;
@end
