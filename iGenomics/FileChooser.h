//
//  FileChooser.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 12/1/12.
//
//

#import <UIKit/UIKit.h>

#define kDefaultReadsListFileName @"DefaultReadsList"
#define kDefaultReadsListFileType @"txt"
#define kDefaultSequencesListFileName @"DefaultSequencesList"
#define kDefaultSequencesListFileType @"txt"

#define kTypeChooserTitle @"Which file would you like to use?"
#define kTypeChooserCancel @"Cancel"
#define kTypeChooserBack @"Back"
#define kTypeChooserCustomName @"Custom"
#define kTypeChooserDefaultName @"Default"
#define kTypeChooserDropboxName @"Dropbox"
#define kTypeChooserCustom 1
#define kTypeChooserDefault 2
#define kTypeChooserDropbox 3

@protocol FileChooserDelegate <NSObject>
- (void)fileChosen:(NSString*)fileContents;
@end
@interface FileChooser : UIViewController <UIActionSheetDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate> {
    IBOutlet UITextView *customTxtView;
    IBOutlet UIButton *doneTypingBtn;
    
    IBOutlet UIPickerView *pickerView;
    
    UIActionSheet *typeChooser;
    
    NSArray *defaultReads;
    NSArray *defaultSequences;
    
    BOOL isForReads;
    
    id delegate;
}
@property (nonatomic) id <FileChooserDelegate> delegate;
- (void)loadForReads:(BOOL)forReads;
- (IBAction)donePressed:(id)sender;
- (IBAction)backPressed:(id)sender;

- (IBAction)doneTypingPressed:(id)sender;
@end
