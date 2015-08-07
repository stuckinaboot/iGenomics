//
//  AdvancedFileInputView.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 8/4/15.
//
//

#import <UIKit/UIKit.h>
#import <DBChooser/DBChooser.h>
#import "DNAColors.h"
#import "SimpleFileDisplayView.h"
#import "APFile.h"

#define kAdvancedFileInputViewFileNameLblDefaultTxt @"No File Selected"
#define kAdvancedFileInputViewFileInputBtnTxt @"Select File"
#define kAdvancedFileInputViewFileDidNotPassValidationAlertMsg @"Selected file type is not compatible. Please select a file of a different type and try again."
#define kAdvancedFileInputViewWidgetScaleFactorHeight .14 //widget height = kAdvancedFileInputViewWidgetScaleFactorHeight * self.frame.size.height
#define kAdvancedFileInputViewBtnScaleFactorWidth .9
#define kAdvancedFileInputViewBtnFontSize 25.0f

#define kFileTypeSelectionOptionLblFontSize 30.0f
#define kFileTypeSelectionOptionLblTxt @"Choose %@ File:" //%@ is a title from kFileTypeSelectionOptionTitles
#define kFileTypeSelectionOptionTitles @[@"Reference", @"Reads", @"Important Mutations"]//Should be in same order as the FileTypeSelectionOption enum

#define kFileInputOptionsSheetOptionSheetTitle @"Select File Source:"
#define kFileInputOptionsSheetOptionTitleDropbox @"Dropbox"
#define kFileInputOptionsSheetOptionTitleLocal @"Local Files"
#define kFileInputOptionsSheetOptionTitleDefault @"Default Files"
#define kFileInputOptionsSheetOptionTitleCancel @"Cancel"

@protocol AdvancedFileInputViewDelegate <NSObject>
- (void)fileSelected:(BOOL)isSelected inFileInputView:(id)inputView;
@end
@interface AdvancedFileInputView : UIView <UIActionSheetDelegate, SimpleFileDisplayViewDelegate> {
    UILabel *fileTypeSelectionOptionLbl;
    
    UILabel *fileNameLbl;
    UIButton *inputBtn;
    
    UIActionSheet *fileInputOptionsSheet;
    
    SimpleFileDisplayView *simpleFileDisplayView;
    
    FileTypeSelectionOption fileTypeSelectionOption;
    
    UIViewController *containingController;
    
    APFile *selectedFile;
    
    NSArray *localFiles;
    NSArray *defaultFiles;
    
    NSArray *validationExts;
}
@property (nonatomic) id <AdvancedFileInputViewDelegate> delegate;
- (IBAction)inputBtnPressed:(id)sender;
- (void)loadWithFileTypeSelectionOption:(FileTypeSelectionOption)selectionOption containingController:(UIViewController*)vc validationExts:(NSArray*)exts;

- (void)displayDropboxChooser;
- (void)dropboxChooserFinishedWithResult:(DBChooserResult*)result;

- (void)selectFile:(APFile*)file;
- (void)newFileSelected;

- (void)setLocalFiles:(NSArray*)locals;
- (void)forceDisplayLocalFiles;

- (APFile*)getSelectedFile;

+ (NSString*)getLocalFileDirectoryForFileTypeSelectionOption:(FileTypeSelectionOption)option;
@end
