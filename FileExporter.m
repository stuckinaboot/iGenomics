//
//  FileExporter.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 6/30/14.
//
//

#import "FileExporter.h"

@implementation FileExporter

@synthesize delegate;

- (void)setGenomeFileName:(NSString *)gName andReadsFileName:(NSString *)rName andEditDistance:(int)ed andExportDataStr:(NSString *)expDataStr {
    genomeFileName = [NSString stringWithString:gName];
    readsFileName = [NSString stringWithString:rName];
    editDistance = ed;
    exportDataStr = [NSString stringWithString:expDataStr];
    [self performSelectorInBackground:@selector(fixExportDataStr) withObject:nil];
}

- (void)fixExportDataStr {
    NSArray *lineArr = [exportDataStr componentsSeparatedByString:kLineBreak];
    NSMutableString *newDataStr = [[NSMutableString alloc] init];
    NSArray *lenArr = [delegate getCumulativeLenArray];
    
    int currLenArrIndex = 0;
    
    for (int i = 0; i < [lineArr count]; i++) {
        NSArray *compArr = [[lineArr objectAtIndex:i] componentsSeparatedByString:kReadExportDataComponentDivider];
        for (int x = 0; x < [compArr count]; x++) {
            NSString *obj = [compArr objectAtIndex:x];
            if (x == kReadExportDataStrPositionIndex) {
                currLenArrIndex = 0;
                while ([obj intValue] > [[lenArr objectAtIndex:currLenArrIndex] intValue])
                    currLenArrIndex++;
                int newVal = [obj intValue] - ((currLenArrIndex > 0) ? [[lenArr objectAtIndex:currLenArrIndex-1] intValue] : 0);
                obj = [NSString stringWithFormat:@"%i%@%@",newVal, kReadExportDataComponentDivider, [[delegate getSeparateGenomeSegmentNamesArray] objectAtIndex:currLenArrIndex]];
            }
            [newDataStr appendFormat:@"%@%@",obj,(x < [compArr count]-1) ? kReadExportDataComponentDivider : kLineBreak];
        }
    }
    
    exportDataStr = newDataStr;
}

- (void)setMutSupportVal:(int)mutSupVal andMutPosArray:(NSArray *)mutPosArr {
    mutationSupportVal = mutSupVal;
    mutPosArray = mutPosArr;
}

- (void)displayExportOptionsWithSender:(id)sender {
    exportActionSheet = [[UIActionSheet alloc] initWithTitle:kExportASTitle delegate:self cancelButtonTitle:nil destructiveButtonTitle:kAlertBtnTitleCancel otherButtonTitles:kExportASEmailMutations, kExportASEmailData, kExportASDropboxMuts, kExportASDropboxData, nil];
    if ([sender isKindOfClass:[UIBarButtonItem class]])
        [exportActionSheet showFromBarButtonItem:(UIBarButtonItem*)sender animated:YES];
    else
        [exportActionSheet showFromRect:((UIView*)sender).frame inView:((UIView*)sender).superview animated:YES];
}

- (BOOL)saveFileAtPath:(NSString *)path andContents:(NSString *)contents andFileType:(FileType)fileType {
    DBFilesystem *sys = [DBFilesystem sharedFilesystem];
    if (!sys) {
        if ([DBAccountManager sharedManager].linkedAccount == NULL)
            [[DBAccountManager sharedManager] linkFromController:[delegate getVC]];
        else {
            sys = [[DBFilesystem alloc] initWithAccount:[DBAccountManager sharedManager].linkedAccount];
            [DBFilesystem setSharedFilesystem:sys];
        }
    }
    path = [self fixChosenExportPathExt:path forFileType:fileType];
    DBFile *file = [sys createFile:[[DBPath alloc] initWithString:path] error:nil];
    if ([file writeString:contents error:nil]) {
        [delegate displaySuccessBox];
        return YES;
    }
    else {
        //Error occurred, file exists is the usual error (if this ever changes, I will need to adapt to it)
        return NO;
    }
}

- (int)firstAvailableDefaultFileNameForMutsOrData:(int)choice {
    DBFilesystem *sys = [DBFilesystem sharedFilesystem];
    if (choice == 0) {//muts
        DBFile *file = [sys openFile:[[DBPath alloc] initWithString:[NSString stringWithFormat:kExportDropboxSaveFileFormatMuts,readsFileName, @""]] error:nil];
        int i = 0;
        while (file) {
            i++;
            file = [sys openFile:[[DBPath alloc] initWithString:[NSString stringWithFormat:kExportDropboxSaveFileFormatMuts,readsFileName, [NSString stringWithFormat:@"(%i)",i]]] error:nil];
        }
        return i;
    }
    else if (choice == 1) {//data
        DBFile *file = [sys openFile:[[DBPath alloc] initWithString:[NSString stringWithFormat:kExportDropboxSaveFileFormatData,readsFileName, @""]] error:nil];
        int i = 0;
        while (file) {
            i++;
            file = [sys openFile:[[DBPath alloc] initWithString:[NSString stringWithFormat:kExportDropboxSaveFileFormatData,readsFileName, [NSString stringWithFormat:@"(%i)",i]]] error:nil];
        }
        return i;
    }
    return -1;
}

- (BOOL)overwriteFileAtPath:(NSString*)path andContents:(NSString*)contents andFileType:(FileType)fileType {
    DBFilesystem *sys = [DBFilesystem sharedFilesystem];
    path = [self fixChosenExportPathExt:path forFileType:fileType];
    DBFile *file = [sys openFile:[[DBPath alloc] initWithString:path] error:nil];
    if ([file writeString:contents error:nil]) {
        [delegate displaySuccessBox];
        return YES;
    }
    else {
        //Error occurred, file exists is the usual error (if this ever changes, I will need to adapt to it)
        return NO;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (![GlobalVars internetAvailable])
        return;
    if ([actionSheet isEqual:exportActionSheet]) {
        if (buttonIndex == kExportASEmailMutsIndex) {
            [self emailInfoForOption:EmailInfoOptionMutations];
        }
        else if (buttonIndex == kExportASEmailDataIndex) {
            [self emailInfoForOption:EmailInfoOptionData];
        }
        else if (buttonIndex == kExportASDropboxMutsIndex) {
            if ([DBAccountManager sharedManager].linkedAccount == NULL)
                [[DBAccountManager sharedManager] linkFromController:[delegate getVC]];
            else {
                exportMutsDropboxAlert = [[UIAlertView alloc] initWithTitle:kExportAlertTitle message:kExportAlertBody delegate:self cancelButtonTitle:kAlertBtnTitleCancel otherButtonTitles:kExportAlertBtnExportTitle, nil];
                [exportMutsDropboxAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                UITextField *txtField = [exportMutsDropboxAlert textFieldAtIndex:0];
                int i = [self firstAvailableDefaultFileNameForMutsOrData:0];
                [txtField setText:[NSString stringWithFormat:kExportDropboxSaveFileFormatMuts, readsFileName, (i>0) ? [NSString stringWithFormat:@"(%i)",i] : @""]];
                [exportMutsDropboxAlert show];
            }
        }
        else if (buttonIndex == kExportASDropboxDataIndex) {
            if ([DBAccountManager sharedManager].linkedAccount == NULL)
                [[DBAccountManager sharedManager] linkFromController:[delegate getVC]];
            else {
                exportDataDropboxAlert = [[UIAlertView alloc] initWithTitle:kExportAlertTitle message:kExportAlertBody delegate:self cancelButtonTitle:kAlertBtnTitleCancel otherButtonTitles:kExportAlertBtnExportTitle, nil];
                [exportDataDropboxAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                UITextField *txtField = [exportDataDropboxAlert textFieldAtIndex:0];
                int i = [self firstAvailableDefaultFileNameForMutsOrData:1];
                [txtField setText:[NSString stringWithFormat:kExportDropboxSaveFileFormatData, readsFileName, (i>0) ? [NSString stringWithFormat:@"(%i)",i] : @""]];
                [exportDataDropboxAlert show];
            }
        }
    }
}

- (void)emailInfoForOption:(EmailInfoOption)option {
    exportMailController = [[MFMailComposeViewController alloc] init];
    exportMailController.mailComposeDelegate = self;
    
    if (option == EmailInfoOptionMutations) {
        [exportMailController setSubject:[NSString stringWithFormat:kExportMutsEmailSubject,readsFileName, genomeFileName]];
        [exportMailController setMessageBody:[NSString stringWithFormat:kExportMutsEmailMsg, readsFileName, genomeFileName, editDistance, mutationSupportVal] isHTML:NO];
        
        NSMutableString *mutString = [self getMutationsExportStr];
        [exportMailController addAttachmentData:[mutString dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"text/plain" fileName:[NSString stringWithFormat:kExportDropboxSaveFileFormatMuts,readsFileName,@""]];
        [[delegate getVC] presentViewController:exportMailController animated:YES completion:nil];
    }
    else if (option == EmailInfoOptionData) {
        [exportMailController setSubject:[NSString stringWithFormat:kExportDataEmailSubject,readsFileName, genomeFileName]];
        [exportMailController setMessageBody:[NSString stringWithFormat:kExportDataEmailMsg, readsFileName, genomeFileName, editDistance] isHTML:NO];
        
        [exportMailController addAttachmentData:[exportDataStr dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"text/plain" fileName:[NSString stringWithFormat:kExportDropboxSaveFileFormatData,readsFileName,@""]];
        [[delegate getVC] presentViewController:exportMailController animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [exportMailController dismissViewControllerAnimated:YES completion:nil];
}

- (NSMutableString*)getMutationsExportStr {
    NSMutableString *mutString = [[NSMutableString alloc] init];
    [mutString appendFormat:kMutationTotalFormat,[mutPosArray count]];
    MutationInfo *inf;
    if ([mutPosArray count] > 0)
        inf = [mutPosArray objectAtIndex:0];
    else
        return (NSMutableString*)kNoMutationsFoundStr;
    NSString *exportFormat;
    if (!inf.genomeName)
        exportFormat = kMutationFormat;
    else
        exportFormat = kMutationExportFormat;
    for (MutationInfo *info in mutPosArray) {
        [mutString appendFormat:exportFormat,info.displayedPos+1,[MutationInfo createMutStrFromOriginalChar:info.refChar andFoundChars:info.foundChars],[MutationInfo createMutCovStrFromFoundChars:info.foundChars andPos:info.pos],info.genomeName];//+1 so it doesn't start at 0
    }
    return mutString;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView isEqual:exportMutsDropboxAlert]) {
        if (buttonIndex == 1) {
            NSString *txt = [alertView textFieldAtIndex:0].text;
            if ([txt isEqualToString:@""]) {
                [self actionSheet:exportActionSheet didDismissWithButtonIndex:kExportASDropboxMutsIndex];
            }
            else if (![self saveFileAtPath:txt andContents:[self getMutationsExportStr] andFileType:FileTypeMutations]) {
                chosenMutsExportPath = txt;
                exportMutsDropboxErrorAlert = [[UIAlertView alloc] initWithTitle:kErrorAlertExportTitle message:kErrorAlertExportBodyFileNameAlreadyInUse delegate:self cancelButtonTitle:kAlertBtnTitleCancel otherButtonTitles:kErrorAlertExportBtnTitleOverwrite, nil];
                [exportMutsDropboxErrorAlert show];
            }
        }
    }
    else if ([alertView isEqual:exportMutsDropboxErrorAlert]) {
        if (buttonIndex == 1) {
            [self overwriteFileAtPath:chosenMutsExportPath andContents:[self getMutationsExportStr] andFileType:FileTypeMutations];
        }
    }
    else if ([alertView isEqual:exportDataDropboxAlert]) {
        if (buttonIndex == 1) {
            NSString *txt = [alertView textFieldAtIndex:0].text;
            if ([txt isEqualToString:@""]) {
                [self actionSheet:exportActionSheet didDismissWithButtonIndex:kExportASDropboxDataIndex];
            }
            else if (![self saveFileAtPath:txt andContents:exportDataStr andFileType:FileTypeData]) {
                chosenDataExportPath = txt;
                exportDataDropboxErrorAlert = [[UIAlertView alloc] initWithTitle:kErrorAlertExportTitle message:kErrorAlertExportBodyFileNameAlreadyInUse delegate:self cancelButtonTitle:kAlertBtnTitleCancel otherButtonTitles:kErrorAlertExportBtnTitleOverwrite, nil];
                [exportDataDropboxErrorAlert show];
            }
        }
    }
    else if ([alertView isEqual:exportDataDropboxErrorAlert]) {
        if (buttonIndex == 1) {
            [self overwriteFileAtPath:chosenDataExportPath andContents:exportDataStr andFileType:FileTypeData];
        }
    }
}

- (NSString*)fixChosenExportPathExt:(NSString*)path forFileType:(FileType)fileType {
    NSString *ext;
    switch (fileType) {
        case FileTypeData:
            ext = kExportDropboxSaveDataFileExt;
            break;
        case FileTypeMutations:
            ext = kExportDropboxSaveMutsFileExt;
            break;
        default:
            ext = kExportDropboxSaveFileExt;
            break;
    }
    int s = ext.length;
    if ([[path substringFromIndex:path.length-s] caseInsensitiveCompare:ext] != NSOrderedSame)
        return [NSString stringWithFormat:@"%@%@",path,ext];
    return path;
}

@end
