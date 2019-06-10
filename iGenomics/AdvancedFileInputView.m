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
//        [self addSubview:inputBtn];
        
        fileNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, inputBtn.frame.origin.y-size.height, size.width, size.height)];
        [fileNameLbl setTextAlignment:NSTextAlignmentCenter];
        fileNameLbl.text = kAdvancedFileInputViewFileNameLblDefaultTxt;
        [fileNameLbl setAdjustsFontSizeToFitWidth:YES];
//        [self addSubview:fileNameLbl];
    }
    return self;
}

- (void)setSuperView:(UIView *)sV {
    superView = sV;
}

- (void)loadWithFileTypeSelectionOption:(FileTypeSelectionOption)selectionOption containingController:(UIViewController *)vc validationExts:(NSArray *)exts {
    fileTypeSelectionOption = selectionOption;
    NSString *fileTypeSelectionOptionLblTitle = [NSString stringWithFormat:kFileTypeSelectionOptionLblTxt,kFileTypeSelectionOptionTitles[fileTypeSelectionOption]];
    fileTypeSelectionOptionLbl.text = fileTypeSelectionOptionLblTitle;
    
    CGRect frame = self.frame;
    simpleFileDisplayView = [[SimpleFileDisplayView alloc] initWithFrame:CGRectMake(0, fileTypeSelectionOptionLbl.frame.size.height, frame.size.width, frame.size.height-fileTypeSelectionOptionLbl.frame.size.height)];
    [simpleFileDisplayView setHidden:YES];
    [self addSubview:simpleFileDisplayView];
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
        [self setHidden:NO];
        [self displayDropboxChooser];
    }
    else if ([title isEqualToString:kFileInputOptionsSheetOptionTitleLocal]) {
        [self setHidden:NO];
        [simpleFileDisplayView presentInView:self];
        [simpleFileDisplayView displayWithFilesArray:localFiles deletingFilesEnabled:YES];
    }
    else if ([title isEqualToString:kFileInputOptionsSheetOptionTitleDefault]) {
        [self setHidden:NO];
        [simpleFileDisplayView presentInView:self];
        [simpleFileDisplayView displayWithFilesArray:defaultFiles deletingFilesEnabled:NO];
    }
}

- (void)selectFile:(APFile*)file {
    if ([FileManager filePassesValidation:file againstExts:validationExts]) {
        selectedFile = file;
        fileNameLbl.text = selectedFile.name;
        [delegate fileSelected:(selectedFile != NULL) inFileInputView:self];
        [delegate fileSelectedWithName:selectedFile.name inFileInputView:self];
    }
    else
        [GlobalVars displayiGenomicsAlertWithMsg:kAdvancedFileInputViewFileDidNotPassValidationAlertMsg];
}

- (void)displayDropboxChooser {
    if (![GlobalVars internetAvailable])
        return;
    // Hide the advanced file input view because dropbox will display its own view
    // and in case user uses iOS application switch, the advanced file input view will be hidden
    // (which is good because we want to allow the user any file picker option again)
    [self setHidden:YES];
    [[DBChooser defaultChooser] openChooserForLinkType:DBChooserLinkTypeDirect fromViewController:containingController completion:^(NSArray *results) {
         if ([results count]) {
             [self dropboxChooserFinishedWithResult:results[0]];
         }
     }];
}

- (void)dropboxChooserFinishedWithResult:(DBChooserResult *)result {
    NSString *contents = [[NSString alloc] initWithData:[FileManager dataDownloadedFromURL:result.link] encoding:NSUTF8StringEncoding];
    APFile *file = [[APFile alloc] initWithName:result.name contents:contents fileType:APFileTypeDropbox];
    [self selectFile:file];
    [self setHidden:YES];
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

+ (NSString*)getLocalFileDirectoryForFileTypeSelectionOption:(FileTypeSelectionOption)option {
    if (option == FileTypeSelectionOptionRef)
        return kLocalRefFilesDirectoryName;
    else if (option == FileTypeSelectionOptionReads)
        return kLocalReadsFilesDirectoryName;
    else if (option == FileTypeSelectionOptionImptMuts)
        return kLocalImptMutsFilesDirectoryName;
    return @"";
}

#pragma SimpleFileDisplayViewDelegate

- (void)fileSelected:(APFile *)file inSimpleFileDisplayView:(id)sfdv {
    if (file) {
        if (file.fileType == APFileTypeDefault)
            file = [FileManager defaultFileForFileWithOnlyName:file];
        else if (file.fileType == APFileTypeLocal) {
            NSString *directory = [AdvancedFileInputView getLocalFileDirectoryForFileTypeSelectionOption:fileTypeSelectionOption];
            
            file = [FileManager localFileForFileWithOnlyName:file inDirectory:directory];
        }
        [self selectFile:file];
    }
    else {
        //Make selectedFile be empty file
        selectedFile = [[APFile alloc] initWithName:@"" contents:@"" fileType:APFileTypeDefault];
        fileNameLbl.text = kAdvancedFileInputViewFileNameLblDefaultTxt;
        [delegate fileSelected:NO inFileInputView:self];
        [delegate fileSelectedWithName:kAdvancedFileInputViewFileNameLblDefaultTxt inFileInputView:self];
    }
}

- (void)deletePressedForFile:(APFile *)file inSimpleFileDisplayView:(id)sfdv {
    NSString *directory = [AdvancedFileInputView getLocalFileDirectoryForFileTypeSelectionOption:fileTypeSelectionOption];
    [FileManager deleteLocalFile:file inDirectory:directory];
    localFiles = [FileManager getLocalFileWithoutContentsArrayFromDirectory:directory];
    [sfdv setLocalFilesArray:localFiles];
}

- (void)renamePressedForFile:(APFile*)file withNewName:(NSString*)newName inSimpleFileDisplayView:(id)sfdv {
    NSString *directory = [AdvancedFileInputView getLocalFileDirectoryForFileTypeSelectionOption:fileTypeSelectionOption];
    [FileManager renameLocalFile:file forNewFileName:newName inDirectory:directory];
    localFiles = [FileManager getLocalFileWithoutContentsArrayFromDirectory:directory];
    [sfdv setLocalFilesArray:localFiles];
}

- (void)simpleFileDisplayViewDidRemoveFromView {
    [self setHidden:YES];
}

@end
