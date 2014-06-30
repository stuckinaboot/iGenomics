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
}

- (void)setMutSupportVal:(int)mutSupVal andMutPosArray:(NSArray *)mutPosArr {
    mutationSupportVal = mutSupVal;
    mutPosArray = mutPosArr;
}

- (void)displayExportOptionsWithSender:(id)sender {
    exportActionSheet = [[UIActionSheet alloc] initWithTitle:kExportASTitle delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Cancel" otherButtonTitles:kExportASEmailMutations, kExportASEmailData, kExportASDropboxMuts, kExportASDropboxData, nil];
    [exportActionSheet showFromBarButtonItem:(UIBarButtonItem*)sender animated:YES];
}

- (BOOL)saveFileAtPath:(NSString *)path andContents:(NSString *)contents {
    DBFilesystem *sys = [DBFilesystem sharedFilesystem];
    path = [self fixChosenExportPathExt:path];
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

- (BOOL)overwriteFileAtPath:(NSString*)path andContents:(NSString*)contents {
    DBFilesystem *sys = [DBFilesystem sharedFilesystem];
    path = [self fixChosenExportPathExt:path];
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
            exportMutsDropboxAlert = [[UIAlertView alloc] initWithTitle:kExportAlertTitle message:kExportAlertBody delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Export", nil];
            [exportMutsDropboxAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            UITextField *txtField = [exportMutsDropboxAlert textFieldAtIndex:0];
            int i = [self firstAvailableDefaultFileNameForMutsOrData:0];
            [txtField setText:[NSString stringWithFormat:kExportDropboxSaveFileFormatMuts, readsFileName, (i>0) ? [NSString stringWithFormat:@"(%i)",i] : @""]];
            [exportMutsDropboxAlert show];
        }
        else if (buttonIndex == kExportASDropboxDataIndex) {
            exportDataDropboxAlert = [[UIAlertView alloc] initWithTitle:kExportAlertTitle message:kExportAlertBody delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Export", nil];
            [exportDataDropboxAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            UITextField *txtField = [exportDataDropboxAlert textFieldAtIndex:0];
            int i = [self firstAvailableDefaultFileNameForMutsOrData:1];
            [txtField setText:[NSString stringWithFormat:kExportDropboxSaveFileFormatData, readsFileName, (i>0) ? [NSString stringWithFormat:@"(%i)",i] : @""]];
            [exportDataDropboxAlert show];
        }
    }
}

- (void)emailInfoForOption:(EmailInfoOption)option {
    exportMailController = [[MFMailComposeViewController alloc] init];
    exportMailController.mailComposeDelegate = self;
    
    if (option == EmailInfoOptionMutations) {
        [exportMailController setSubject:[NSString stringWithFormat:@"iGenomics- Mutations for Aligning %@ to %@",readsFileName, genomeFileName]];
        [exportMailController setMessageBody:[NSString stringWithFormat:@"Mutation export information for aligning %@ to %@ for a maximum edit distance of %i. Also, for a position to be considered heterozygous, the heterozygous character must have been recorded at least %i times. The export information is attached to this email as a text file. \n\nPowered by iGenomics", readsFileName, genomeFileName, editDistance, mutationSupportVal/*Mutation support is computed using posOccArr[x]i] > kHeteroAllowance, so for solely greater than, it needs to add one for the sentence in the message to make sense*/] isHTML:NO];
        
        NSMutableString *mutString = [self getMutationsExportStr];
        [exportMailController addAttachmentData:[mutString dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"text/plain" fileName:@"Mutations"];
        [[delegate getVC] presentViewController:exportMailController animated:YES completion:nil];
    }
    else if (option == EmailInfoOptionData) {
        [exportMailController setSubject:[NSString stringWithFormat:@"iGenomics- Export Data for Aligning %@ to %@",readsFileName, genomeFileName]];
        [exportMailController setMessageBody:[NSString stringWithFormat:@"Read alignment information for aligning %@ to %@ for a maximum edit distance of %i. The format is for the export is as follows: Read Number, Position Matched, Forward(+)/Reverse complement(-) Matched, Edit Distance, Gapped Reference, Gapped Read.The export information is attached to this email as a text file. \n\nPowered by iGenomics", readsFileName, genomeFileName, editDistance/*Mutation support is computed using posOccArr[x]i] > kHeteroAllowance, so for solely greater than, it needs to add one for the sentence in the message to make sense*/] isHTML:NO];
        
        [exportMailController addAttachmentData:[exportDataStr dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"text/plain" fileName:@"ExportData"];
        [[delegate getVC] presentViewController:exportMailController animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [exportMailController dismissViewControllerAnimated:YES completion:nil];
}

- (NSMutableString*)getMutationsExportStr {
    NSMutableString *mutString = [[NSMutableString alloc] init];
    [mutString appendFormat:@"Total Mutations: %i\n",[mutPosArray count]];
    MutationInfo *inf = [mutPosArray objectAtIndex:0];
    NSString *exportFormat;
    if (!inf.genomeName)
        exportFormat = kMutationFormat;
    else
        exportFormat = kMutationExportFormat;
    for (MutationInfo *info in mutPosArray) {
        [mutString appendFormat:exportFormat,info.pos+1,[MutationInfo createMutStrFromOriginalChar:info.refChar andFoundChars:info.foundChars],[MutationInfo createMutCovStrFromFoundChars:info.foundChars andPos:info.pos],info.genomeName];//+1 so it doesn't start at 0
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
            else if (![self saveFileAtPath:txt andContents:[self getMutationsExportStr]]) {
                chosenMutsExportPath = txt;
                exportMutsDropboxErrorAlert = [[UIAlertView alloc] initWithTitle:kErrorAlertExportTitle message:kErrorAlertExportBodyFileNameAlreadyInUse delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Overwrite", nil];
                [exportMutsDropboxErrorAlert show];
            }
        }
    }
    else if ([alertView isEqual:exportMutsDropboxErrorAlert]) {
        if (buttonIndex == 1) {
            [self overwriteFileAtPath:chosenMutsExportPath andContents:[self getMutationsExportStr]];
        }
    }
    else if ([alertView isEqual:exportDataDropboxAlert]) {
        if (buttonIndex == 1) {
            NSString *txt = [alertView textFieldAtIndex:0].text;
            if ([txt isEqualToString:@""]) {
                [self actionSheet:exportActionSheet didDismissWithButtonIndex:kExportASDropboxDataIndex];
            }
            else if (![self saveFileAtPath:txt andContents:exportDataStr]) {
                chosenDataExportPath = txt;
                exportDataDropboxErrorAlert = [[UIAlertView alloc] initWithTitle:kErrorAlertExportTitle message:kErrorAlertExportBodyFileNameAlreadyInUse delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Overwrite", nil];
                [exportDataDropboxErrorAlert show];
            }
        }
    }
    else if ([alertView isEqual:exportDataDropboxErrorAlert]) {
        if (buttonIndex == 1) {
            [self overwriteFileAtPath:chosenDataExportPath andContents:exportDataStr];
        }
    }
}

- (NSString*)fixChosenExportPathExt:(NSString*)path {
    int s = kExportDropboxSaveFileExt.length;
    if (![[path substringFromIndex:path.length-s] isEqualToString:kExportDropboxSaveFileExt])
        return [NSString stringWithFormat:@"%@%@",path,kExportDropboxSaveFileExt];
    return path;
}

@end
