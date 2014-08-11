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

#define kFileInputViewNibName @"FileInputView"

#define kComponent1Title @"Default"

#define kSavedFilesTitle @"Saved Files"
#define kSavedFilesIndex 0
#define kDropboxFilesTitle @"Dropbox Files"
#define kDropboxFilesIndex 1

#define kNumOfFilePickOptions 2

#define kFastaFileExt @"fa"

#define kLockedBtnAlpha 0.5

#define kMinTapsRequired 2

@class FileInputView;
@protocol FileInputViewDelegate <NSObject>
- (void)displayFilePreviewPopoverWithContents:(NSString*)contents atLocation:(CGPoint)loc fromFileInputView:(FileInputView*)fileInputView;
- (UIViewController*)getVC;
- (void)fileSelected:(BOOL)isSelected InFileInputView:(UIView*)inputView;
@end
@interface FileInputView : UIView <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIPopoverControllerDelegate> {
    IBOutlet UISearchBar *searchBar;
    IBOutlet UILabel *instructLbl;
    
    NSMutableArray *filteredFileNames;
    
    FileManager *fileManager;
    DBPath *parentPath;
    int selectedOption;
    
    NSArray *supportedFileTypes;
    
    NSIndexPath *lastSelectedIndexPath;
}
@property (nonatomic) id <FileInputViewDelegate> delegate;
@property (nonatomic, readonly) IBOutlet UITableView *tblView;
- (IBAction)backTbl:(id)sender;
- (IBAction)cellDoubleTapped:(id)sender;
- (BOOL)needsInternetToGetFile;
- (NSString*)nameOfSelectedRow;
- (NSString*)contentsOfSelectedRow;
- (void)setUpWithFileManager:(FileManager *)manager andInstructLblText:(NSString *)instructTxt andSearchBarPlaceHolderTxt:(NSString *)placeHolderTxt andSupportFileTypes:(NSArray*)supportedTypes;
@end
