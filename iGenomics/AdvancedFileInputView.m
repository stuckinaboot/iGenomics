//
//  AdvancedFileInputView.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 8/4/15.
//
//

#import "AdvancedFileInputView.h"

@implementation AdvancedFileInputView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        CGSize size = CGSizeMake(self.frame.size.width, kAdvancedFileInputViewWidgetScaleFactorHeight * self.frame.size.height);
        fileTypeSelectionOptionLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        [fileTypeSelectionOptionLbl setTextAlignment:NSTextAlignmentCenter];
        [fileTypeSelectionOptionLbl setFont:[UIFont systemFontOfSize:kFileTypeSelectionOptionLblFontSize]];
        [fileTypeSelectionOptionLbl setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:fileTypeSelectionOptionLbl];
        
        DNAColors *dnaColors = [[DNAColors alloc] init];
        [dnaColors setUp];
        
        inputBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [inputBtn setFrame:CGRectMake(0, 0, size.width * kAdvancedFileInputViewBtnScaleFactorWidth, size.height)];
        inputBtn.center = self.center;
        [inputBtn setTitle:kAdvancedFileInputViewFileInputBtnTxt forState:UIControlStateNormal];
        [inputBtn setBackgroundColor:[UIColor colorWithRed:dnaColors.defaultBtn.r green:dnaColors.defaultBtn.g blue:dnaColors.defaultBtn.b alpha:1.0f]];
        [inputBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        inputBtn.showsTouchWhenHighlighted = YES;
        [inputBtn.titleLabel setFont:[UIFont systemFontOfSize:kAdvancedFileInputViewBtnFontSize]];
        [inputBtn addTarget:self action:@selector(inputBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:inputBtn];
        
        fileNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, inputBtn.frame.origin.y-size.height, size.width, size.height)];
        [fileNameLbl setTextAlignment:NSTextAlignmentCenter];
        fileNameLbl.text = kAdvancedFileInputViewFileNameLblDefaultTxt;
        [fileNameLbl setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:fileNameLbl];
    }
    return self;
}

- (void)loadWithFileTypeSelectionOption:(FileTypeSelectionOption)selectionOption containingController:(UIViewController *)vc validationExts:(NSArray *)exts {
    fileTypeSelectionOption = selectionOption;
    NSString *fileTypeSelectionOptionLblTitle = [NSString stringWithFormat:kFileTypeSelectionOptionLblTxt,kFileTypeSelectionOptionTitles[fileTypeSelectionOption]];
    fileTypeSelectionOptionLbl.text = fileTypeSelectionOptionLblTitle;
    
    CGRect frame = self.frame;
    simpleFileDisplayView = [[SimpleFileDisplayView alloc] initWithFrame:CGRectMake(0, fileTypeSelectionOptionLbl.frame.size.height, frame.size.width, frame.size.height-fileTypeSelectionOptionLbl.frame.size.height)];
    [simpleFileDisplayView setDelegate:self];
    
    containingController = vc;
    validationExts = exts;
    
    NSString *defaultFilesKey;
    if (selectionOption == FileTypeSelectionOptionRef)
        defaultFilesKey = kDefaultRefFilesNamesFile;
    else if (selectionOption == FileTypeSelectionOptionReads)
        defaultFilesKey = kDefaultReadsFilesNamesFile;
    else if (selectionOption == FileTypeSelectionOptionImptMuts)
        defaultFilesKey = kDefaultImptMutsFilesNamesFile;
    defaultFiles = [FileManager defaultFilesForKey:defaultFilesKey];
}

- (IBAction)inputBtnPressed:(id)sender {
    fileInputOptionsSheet = [[UIActionSheet alloc] initWithTitle:kFileInputOptionsSheetOptionSheetTitle delegate:self cancelButtonTitle:kFileInputOptionsSheetOptionTitleCancel destructiveButtonTitle:nil otherButtonTitles:kFileInputOptionsSheetOptionTitleDropbox, kFileInputOptionsSheetOptionTitleLocal, kFileInputOptionsSheetOptionTitleDefault, nil];
    [fileInputOptionsSheet showInView:self];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:kFileInputOptionsSheetOptionTitleDropbox]) {
        [self displayDropboxChooser];
    }
    else if ([title isEqualToString:kFileInputOptionsSheetOptionTitleLocal]) {
        [simpleFileDisplayView presentInView:self];
        [simpleFileDisplayView displayWithFilesArray:localFiles deletingFilesEnabled:YES];
    }
    else if ([title isEqualToString:kFileInputOptionsSheetOptionTitleDefault]) {
        [simpleFileDisplayView presentInView:self];
        [simpleFileDisplayView displayWithFilesArray:defaultFiles deletingFilesEnabled:NO];
    }
}

- (void)selectFile:(APFile*)file {
    if ([FileManager filePassesValidation:file againstExts:validationExts]) {
        selectedFile = file;
        fileNameLbl.text = selectedFile.name;
        [delegate fileSelected:(selectedFile) inFileInputView:self];
    }
    else
        [GlobalVars displayiGenomicsAlertWithMsg:kAdvancedFileInputViewFileDidNotPassValidationAlertMsg];
}

- (void)displayDropboxChooser {
    if (![GlobalVars internetAvailable])
        return;
    [[DBChooser defaultChooser] openChooserForLinkType:DBChooserLinkTypeDirect fromViewController:containingController completion:^(NSArray *results) {
         if ([results count]) {
             [self dropboxChooserFinishedWithResult:results[0]];
         } else {
             // User canceled the action
         }
     }];
}

- (void)dropboxChooserFinishedWithResult:(DBChooserResult *)result {
    NSString *contents = [[NSString alloc] initWithData:[FileManager dataDownloadedFromURL:result.link] encoding:NSUTF8StringEncoding];
    APFile *file = [[APFile alloc] initWithName:result.name contents:contents fileType:APFileTypeDropbox];
    [self selectFile:file];
}

- (APFile*)getSelectedFile {
    return selectedFile;
}

- (void)setLocalFiles:(NSArray *)locals {
    localFiles = locals;
}

- (void)forceDisplayLocalFiles {
    [simpleFileDisplayView presentInView:self];
    [simpleFileDisplayView displayWithFilesArray:localFiles deletingFilesEnabled:YES];
}

#pragma SimpleFileDisplayViewDelegate

- (void)fileSelected:(APFile *)file inSimpleFileDisplayView:(id)sfdv {
    if (file.fileType == APFileTypeDefault)
        file = [FileManager defaultFileForFileWithOnlyName:file];
    else if (file.fileType == APFileTypeLocal)
        file = [FileManager localFileForFileWithOnlyName:file];
    if (file)
        [self selectFile:file];
    else
        [delegate fileSelected:NO inFileInputView:self];
}

- (void)deletePressedForFile:(APFile *)file inSimpleFileDisplayView:(id)sfdv {
    
}

- (void)renamePressedForFile:(APFile*)file inSimpleFileDisplayView:(id)sfdv {

}

@end
