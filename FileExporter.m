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

- (void)setGenomeFileName:(NSString *)gName andReadsFileName:(NSString *)rName andErrorRate:(float)er andExportDataStr:(NSString *)expDataStr andTotalNumOfReads:(int)numOfReads andTotalNumOfReadsAligned:(int)numOfReadsAligned separateGenomeLensArr:(NSArray *)sepGenLens separateGenomeNamesArr:(NSArray *)sepSegNames {
    genomeFileName = [gName substringToIndex:[gName rangeOfString:@"." options:NSBackwardsSearch].location];
    readsFileName = [rName substringToIndex:[rName rangeOfString:@"." options:NSBackwardsSearch].location];
    errorRate = er;
    exportDataStr = [NSString stringWithString:expDataStr];
    
    totalAlignmentRuntime = 0;
//    totalAlignmentRuntime = runtime;
    totalNumOfReadsAligned = numOfReadsAligned;
    totalNumOfReads = numOfReads;
    
    separateGenomeLens = sepGenLens;
    separateSegmentNames = sepSegNames;
    
//    [self performSelectorInBackground:@selector(fixExportDataStr) withObject:nil];
}

- (void)fixExportDataStr {
    NSArray *lineArr = [exportDataStr componentsSeparatedByString:kLineBreak];
    NSMutableString *newDataStr = [[NSMutableString alloc] init];
    NSArray *lenArr = [delegate getCumulativeLenArray];
    
    //Add error rate and runtime to beginning
    [newDataStr appendFormat:@"#\tER\tRT\tRC\tARC\n#\t%f\t%f\t%d\t%d\n",errorRate,totalAlignmentRuntime, totalNumOfReads, totalNumOfReadsAligned];
    
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

- (void)setTotalAlignmentRuntime:(float)runtime {
    totalAlignmentRuntime = runtime;
    
    [self performSelectorInBackground:@selector(fixExportDataStr) withObject:nil];
}

- (void)displayExportOptionsWithSender:(id)sender {
    exportActionSheet = [[UIActionSheet alloc] initWithTitle:kExportASTitle delegate:self cancelButtonTitle:nil destructiveButtonTitle:kAlertBtnTitleCancel otherButtonTitles:kExportASExportMutationsHaploid, kExportASExportMutationsDiploid, kExportASEmailData, kExportASDropboxData, nil];
    if ([sender isKindOfClass:[UIBarButtonItem class]])
        [exportActionSheet showFromBarButtonItem:(UIBarButtonItem*)sender animated:YES];
    else
        [exportActionSheet showFromRect:((UIView*)sender).frame inView:((UIView*)sender).superview animated:YES];
}

- (void)saveFileAtPath:(NSString *)path andContents:(NSString *)contents andFileType:(FileType)fileType completion:(void(^)(BOOL, BOOL))completionBlock {
    DBUserClient *client = [DBClientsManager authorizedClient];
//    DBFilesystem *sys = [DBFilesystem sharedFilesystem];
    if (!client) {
        [DBClientsManager authorizeFromController:[UIApplication sharedApplication] controller:[delegate getVC] openURL:^(NSURL *url) {
            [[UIApplication sharedApplication] openURL:url];
        }];
    }
    
//    if (!sys) {
//        if ([DBAccountManager sharedManager].linkedAccount == NULL)
//            [[DBAccountManager sharedManager] linkFromController:[delegate getVC]];
//        else {
//            sys = [[DBFilesystem alloc] initWithAccount:[DBAccountManager sharedManager].linkedAccount];
//            [DBFilesystem setSharedFilesystem:sys];
//        }
//    }
    path = [self fixChosenExportPathExt:path forFileType:fileType];
//    DBPath *dbPath = [[DBPath alloc] initWithString:path];
//    DBFileInfo *info = [sys fileInfoForPath:dbPath error:nil];
//    DBFile *file;
//    DBError *error;
    
//    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    __block BOOL uploadedSuccessfully = FALSE;
    NSLog(@"Saving");
    [[client.filesRoutes getMetadata:path] setResponseBlock: ^(DBFILESMetadata * _Nullable result, DBFILESGetMetadataError * _Nullable routeError, DBRequestError * _Nullable networkError) {
        // Requests metadata to see if the file exists
        NSLog(@"Requesting metadata");
        if (!result) {
            NSLog(@"file DNE");
            // File does not exist, so upload the file
            [[client.filesRoutes uploadData:path inputData:[contents dataUsingEncoding:NSUTF8StringEncoding]] setResponseBlock:^(DBFILESFileMetadata * _Nullable result, DBFILESUploadError * _Nullable routeError, DBRequestError * _Nullable networkError) {
                if (result) {
                    // File uploaded successfully
                    uploadedSuccessfully = YES;
                    [delegate displaySuccessBox];
                } else {
                    // Unknown Error occurred
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kErrorAlertExportTitle message:kErrorAlertExportBodyGeneralFailError delegate:nil cancelButtonTitle:kErrorAlertExportBodyGeneralFailErrorBtnTitleClose otherButtonTitles:nil];
                    [alert show];
                    uploadedSuccessfully = NO;
                }
        
                completionBlock(uploadedSuccessfully, FALSE);
                
                NSLog(@"Signaling");
//                dispatch_semaphore_signal(sema);
            }];
        } else {
            NSLog(@"File exists");
            // File exists
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kErrorAlertExportTitle message:kErrorAlertExportBodyGeneralFailError delegate:nil cancelButtonTitle:kErrorAlertExportBodyGeneralFailErrorBtnTitleClose otherButtonTitles:nil];
//            [alert show];
            uploadedSuccessfully = NO;
            NSLog(@"Signaling");
            completionBlock(uploadedSuccessfully, TRUE);
//            dispatch_semaphore_signal(sema);
        }
    }];
    NSLog(@"Waiting");
//    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    NSLog(@"Done waiting");
//    return uploadedSuccessfully;
    
//    if (!info)
//        file = [sys createFile:dbPath error:&error];
//    else
//        return NO;

//    if (error) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kErrorAlertExportTitle message:kErrorAlertExportBodyGeneralFailError delegate:nil cancelButtonTitle:kErrorAlertExportBodyGeneralFailErrorBtnTitleClose otherButtonTitles:nil];
//        [alert show];
//        return NO;
//    } else if ([file writeString:contents error:nil]) {
//        [delegate displaySuccessBox];
//        return YES;
//    } else {
//        //Error occurred, file exists is the usual error (if this ever changes, I will need to adapt to it)
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kErrorAlertExportTitle message:kErrorAlertExportBodyGeneralFailError delegate:nil cancelButtonTitle:kErrorAlertExportBodyGeneralFailErrorBtnTitleClose otherButtonTitles:nil];
//        [alert show];
//        return NO;
//    }
}

- (int)firstAvailableDefaultFileNameForMutsOrData:(int)choice {
    DBUserClient *client = [DBClientsManager authorizedClient];
    if (!client) {
        [DBClientsManager authorizeFromController:[UIApplication sharedApplication] controller:[delegate getVC] openURL:^(NSURL *url) {
            [[UIApplication sharedApplication] openURL:url];
        }];
    }
    
    NSString *formatStr;
    if (choice == 0) { // muts
        formatStr = kExportDropboxSaveFileFormatMuts;
    } else if (choice == 1) {
        formatStr = kExportDropboxSaveFileFormatData;
    } else {
        return -1;
    }

    NSString *path = [NSString stringWithFormat:formatStr,readsFileName, @""];
    return path;
    
    /*
    __block BOOL validNameFound = FALSE;
    __block int i = 0;
    while (!validNameFound) {
        NSLog(@"del entered while");
//        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        runOnMainQueueWithoutDeadlocking(^{
            NSLog(@"ran this");
            [[client.filesRoutes getMetadata:path] setResponseBlock:^(DBFILESMetadata * _Nullable result, DBFILESGetMetadataError * _Nullable routeError, DBRequestError * _Nullable networkError) {
                if (!result) {
                    NSLog(@"del found valid name");
                    validNameFound = TRUE;
                } else {
                    NSLog(@"del no invalid name %@", [result description]);
                    i++;
                }
    //                dispatch_semaphore_signal(sema);
            }];
//        });
            });
            if (validNameFound) {
                break;
            } else {
                NSLog(@"del started waiting");
    //            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            }
    }
    return i;
//    DBFilesystem *sys = [DBFilesystem sharedFilesystem];
//    if (choice == 0) {//muts
//        DBFile *file = [sys openFile:[[DBPath alloc] initWithString:[NSString stringWithFormat:kExportDropboxSaveFileFormatMuts,readsFileName, @""]] error:nil];
//        int i = 0;
//        while (file) {
//            i++;
//            file = [sys openFile:[[DBPath alloc] initWithString:[NSString stringWithFormat:kExportDropboxSaveFileFormatMuts,readsFileName, [NSString stringWithFormat:@"(%i)",i]]] error:nil];
//        }
//        return i;
//    }
//    else if (choice == 1) {//data
//        DBFile *file = [sys openFile:[[DBPath alloc] initWithString:[NSString stringWithFormat:kExportDropboxSaveFileFormatData,readsFileName, @""]] error:nil];
//        int i = 0;
//        while (file) {
//            i++;
//            file = [sys openFile:[[DBPath alloc] initWithString:[NSString stringWithFormat:kExportDropboxSaveFileFormatData,readsFileName, [NSString stringWithFormat:@"(%i)",i]]] error:nil];
//        }
//        return i;
//    }
     */
}

- (void)overwriteFileAtPath:(NSString*)path andContents:(NSString*)contents andFileType:(FileType)fileType {
    DBUserClient *client = [DBClientsManager authorizedClient];
//    DBFilesystem *sys = [DBFilesystem sharedFilesystem];
    path = [self fixChosenExportPathExt:path forFileType:fileType];
    
//    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [[client.filesRoutes uploadData:path mode:[[DBFILESWriteMode alloc] initWithOverwrite] autorename:NULL clientModified:NULL mute:NULL propertyGroups:NULL strictConflict:NULL inputData:[contents dataUsingEncoding:NSUTF8StringEncoding]] setResponseBlock:^(DBFILESFileMetadata * _Nullable result, DBFILESUploadError * _Nullable routeError, DBRequestError * _Nullable networkError) {
        if (result != NULL) {
            [delegate displaySuccessBox];
        } else {
            // Display error
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kErrorAlertExportTitle message:kErrorAlertExportBodyGeneralFailError delegate:nil cancelButtonTitle:kErrorAlertExportBodyGeneralFailErrorBtnTitleClose otherButtonTitles:nil];
            [alert show];
        }
//        dispatch_semaphore_signal(sema);
    }];
//    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
//    if (uploaded) {
//        [delegate displaySuccessBox];
//        return YES;
//    } else {
//        return NO;
//    }
//    DBFile *file = [sys openFile:[[DBPath alloc] initWithString:path] error:nil];
//    if ([file writeString:contents error:nil]) {
//        [delegate displaySuccessBox];
//        return YES;
//    }
//    else {
//        //Error occurred, file exists is the usual error (if this ever changes, I will need to adapt to it)
//        return NO;
//    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"del A");
    if (![[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kAlertBtnTitleCancel] && ![GlobalVars internetAvailable]) {
        // Only return if no internet available and button other than cancel hit
        return;
    } else if ([actionSheet isEqual:exportActionSheet]) {
        NSLog(@"del B");
        if (buttonIndex == kExportASExportMutationsHaploidIndex) {
            NSLog(@"del C");
            exportOptionsMutsActionSheet = [[UIActionSheet alloc] initWithTitle:kExportAlertTitle delegate:self cancelButtonTitle:kAlertBtnTitleCancel destructiveButtonTitle:nil otherButtonTitles:kExportMutExportEmailMuts, kExportMutExportDropboxMuts, nil];
            exportOptionsMutsActionSheet.tag = kExportASExportMutationsHaploidIndex;
            UIView *viewToDisplayIn = [actionSheet superview];
            if (!viewToDisplayIn) {
                viewToDisplayIn = [[delegate getVC] view];
            }
            [exportOptionsMutsActionSheet showInView:viewToDisplayIn];
//            [self emailInfoForOption:EmailInfoOptionMutations];
        }
        else if (buttonIndex == kExportASExportMutationsDiploidIndex) {
            NSLog(@"del D");
            exportOptionsMutsActionSheet = [[UIActionSheet alloc] initWithTitle:kExportAlertTitle delegate:self cancelButtonTitle:kAlertBtnTitleCancel destructiveButtonTitle:nil otherButtonTitles:kExportMutExportEmailMuts, kExportMutExportDropboxMuts, nil];
            exportOptionsMutsActionSheet.tag = kExportASExportMutationsDiploidIndex;
            UIView *viewToDisplayIn = [actionSheet superview];
            if (!viewToDisplayIn) {
                viewToDisplayIn = [[delegate getVC] view];
            }
            [exportOptionsMutsActionSheet showInView:viewToDisplayIn];
//            [self emailInfoForOption:EmailInfoOptionMutations];
        }
        else if (buttonIndex == kExportASEmailDataIndex) {
            NSLog(@"del E");
            [self emailInfoForOption:EmailInfoOptionData isDiploid:NO];
        }
        else if (buttonIndex == kExportASDropboxDataIndex) {
            NSLog(@"del F");
//            if ([DBAccountManager sharedManager].linkedAccount == NULL)
//                [[DBAccountManager sharedManager] linkFromController:[delegate getVC]];
            DBUserClient *client = [DBClientsManager authorizedClient];
            NSLog(@"checking client");
            if (!client) {
                NSLog(@"authorizing");
                [DBClientsManager authorizeFromController:[UIApplication sharedApplication] controller:[delegate getVC] openURL:^(NSURL *url) {
                    [[UIApplication sharedApplication] openURL:url];
                }];
            }
            else {
                NSLog(@"del G");
                exportDataDropboxAlert = [[UIAlertView alloc] initWithTitle:kExportAlertTitle message:kExportAlertBody delegate:self cancelButtonTitle:kAlertBtnTitleCancel otherButtonTitles:kExportAlertBtnExportTitle, nil];
                [exportDataDropboxAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                UITextField *txtField = [exportDataDropboxAlert textFieldAtIndex:0];
                NSLog(@"del H");
                int i = [self firstAvailableDefaultFileNameForMutsOrData:1];
                NSLog(@"del I");
                [txtField setText:[NSString stringWithFormat:kExportDropboxSaveFileFormatData, readsFileName, (i>0) ? [NSString stringWithFormat:@"(%i)",i] : @""]];
                [exportDataDropboxAlert show];
            }
        }
    } else if ([actionSheet isEqual:exportOptionsMutsActionSheet]) {
        if ([[exportOptionsMutsActionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kExportMutExportEmailMuts]) {
            [self emailInfoForOption:EmailInfoOptionMutations isDiploid:exportOptionsMutsActionSheet.tag == kExportASExportMutationsDiploidIndex];
        } else if ([[exportOptionsMutsActionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kExportMutExportDropboxMuts]) {
//            if ([DBAccountManager sharedManager].linkedAccount == NULL)
//                [[DBAccountManager sharedManager] linkFromController:[delegate getVC]];
            DBUserClient *client = [DBClientsManager authorizedClient];
            if (!client) {
                [DBClientsManager authorizeFromController:[UIApplication sharedApplication] controller:[delegate getVC] openURL:^(NSURL *url) {
                    [[UIApplication sharedApplication] openURL:url];
                }];
            }
            else {
                exportMutsDropboxAlert = [[UIAlertView alloc] initWithTitle:kExportAlertTitle message:kExportAlertBody delegate:self cancelButtonTitle:kAlertBtnTitleCancel otherButtonTitles:kExportAlertBtnExportTitle, nil];
                [exportMutsDropboxAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                UITextField *txtField = [exportMutsDropboxAlert textFieldAtIndex:0];
                int i = [self firstAvailableDefaultFileNameForMutsOrData:0];
                [txtField setText:[NSString stringWithFormat:kExportDropboxSaveFileFormatMuts, readsFileName, (i>0) ? [NSString stringWithFormat:@"(%i)",i] : @""]];
                exportMutsDropboxAlert.tag = actionSheet.tag;
                [exportMutsDropboxAlert show];
            }
        }
    }
}

- (void)emailInfoForOption:(EmailInfoOption)option isDiploid:(BOOL)isDiploid {
    if (![MFMailComposeViewController canSendMail]) {
        // Display alert and return if you can can't send mail
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kErrorAlertEmailTitle message:kErrorAlertEmailBody delegate:self cancelButtonTitle:kErrorAlertExportBodyGeneralFailErrorBtnTitleClose otherButtonTitles:nil];
        [alert show];
        return;
    }
    exportMailController = [[MFMailComposeViewController alloc] init];
    exportMailController.mailComposeDelegate = self;
    
    if (option == EmailInfoOptionMutations) {
        [exportMailController setSubject:[NSString stringWithFormat:kExportMutsEmailSubject,readsFileName, genomeFileName]];
        [exportMailController setMessageBody:[NSString stringWithFormat:kExportMutsEmailMsg, readsFileName, genomeFileName, errorRate] isHTML:NO];
        
        NSMutableString *mutString = [self getMutationsExportStrForIsDiploid:isDiploid];
        [exportMailController addAttachmentData:[mutString dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"text/plain" fileName:[NSString stringWithFormat:kExportMailSaveFileFormatMuts,readsFileName,@""]];
        [[delegate getVC] presentViewController:exportMailController animated:YES completion:nil];
    }
    else if (option == EmailInfoOptionData) {
        [exportMailController setSubject:[NSString stringWithFormat:kExportDataEmailSubject,readsFileName, genomeFileName]];
        [exportMailController setMessageBody:[NSString stringWithFormat:kExportDataEmailMsg, readsFileName, genomeFileName, errorRate] isHTML:NO];
        
        [exportMailController addAttachmentData:[exportDataStr dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"text/plain" fileName:[NSString stringWithFormat:kExportMailSaveFileFormatData,readsFileName,@""]];
        [[delegate getVC] presentViewController:exportMailController animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [exportMailController dismissViewControllerAnimated:YES completion:nil];
}

- (NSMutableString*)getMutationsExportStrForIsDiploid:(BOOL)isDiploid {
    NSMutableString *mutString = [[NSMutableString alloc] init];
//    [mutString appendFormat:kMutationTotalFormat,(int)[mutPosArray count]];
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
//    for (MutationInfo *info in mutPosArray) {
//        [mutString appendFormat:exportFormat,info.displayedPos+1,[MutationInfo createMutStrFromOriginalChar:info.refChar andFoundChars:info.foundChars pos:info.pos relevantInsArr:info.relevantInsertionsArr],[MutationInfo createMutCovStrFromFoundChars:info.foundChars andPos:info.pos relevantInsArr:info.relevantInsertionsArr], info.genomeName];//+1 so it doesn't start at 0
//    }
    NSString *header = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kExportMutsHeaderFileName ofType:kExportMutsHeaderFileExt] encoding:NSUTF8StringEncoding error:nil];
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"ddMMyyyy"];
    NSString *dateString = [dateFormatter stringFromDate:today];
    
    NSMutableString *contigsStr = [NSMutableString string];
    for (int i = 0; i < [separateGenomeLens count]; i++) {
        int len = [[separateGenomeLens objectAtIndex:i] intValue];
        NSString *name = [separateSegmentNames objectAtIndex:i];
        [contigsStr appendFormat:@"##contig=<ID=%@, length=%d>%@", name, len, (i < [separateGenomeLens count] - 1) ? @"\n" : @""];
    }
    [mutString appendFormat:header, dateString, genomeFileName, contigsStr, readsFileName];
    [mutString appendString:[MutationInfo mutationInfosOutputString:mutPosArray isDiploid:isDiploid]];
    return mutString;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView isEqual:exportMutsDropboxAlert]) {
        if (buttonIndex == 1) {
            NSString *txt = [alertView textFieldAtIndex:0].text;
            if ([txt isEqualToString:@""]) {
                [self actionSheet:exportOptionsMutsActionSheet didDismissWithButtonIndex:kExportMutExportDropboxMutsIndex];
            }
            else {
                [self saveFileAtPath:txt andContents:[self getMutationsExportStrForIsDiploid:alertView.tag == kExportASExportMutationsDiploidIndex] andFileType:FileTypeMutations completion:^(BOOL uploaded, BOOL fileAlreadyExists) {
                    if (!uploaded && fileAlreadyExists) {
                        chosenMutsExportPath = txt;
                        exportMutsDropboxErrorAlert = [[UIAlertView alloc] initWithTitle:kErrorAlertExportTitle message:kErrorAlertExportBodyFileNameAlreadyInUse delegate:self cancelButtonTitle:kAlertBtnTitleCancel otherButtonTitles:kErrorAlertExportBtnTitleOverwrite, nil];
                        exportMutsDropboxErrorAlert.tag = exportMutsDropboxAlert.tag;
                        [exportMutsDropboxErrorAlert show];
                    }
                }];
            }
        }
    }
    else if ([alertView isEqual:exportMutsDropboxErrorAlert]) {
        if (buttonIndex == 1) {
            [self overwriteFileAtPath:chosenMutsExportPath andContents:[self getMutationsExportStrForIsDiploid:alertView.tag == kExportASExportMutationsDiploidIndex] andFileType:FileTypeMutations];
        }
    }
    else if ([alertView isEqual:exportDataDropboxAlert]) {
        if (buttonIndex == 1) {
            NSString *txt = [alertView textFieldAtIndex:0].text;
            if ([txt isEqualToString:@""]) {
                [self actionSheet:exportActionSheet didDismissWithButtonIndex:kExportASDropboxDataIndex];
            }
            else {
                [self saveFileAtPath:txt andContents:exportDataStr andFileType:FileTypeData completion:^(BOOL uploaded, BOOL fileAlreadyExists) {
                    if (!uploaded && fileAlreadyExists) {
                        chosenDataExportPath = txt;
                        exportDataDropboxErrorAlert = [[UIAlertView alloc] initWithTitle:kErrorAlertExportTitle message:kErrorAlertExportBodyFileNameAlreadyInUse delegate:self cancelButtonTitle:kAlertBtnTitleCancel otherButtonTitles:kErrorAlertExportBtnTitleOverwrite, nil];
                        [exportDataDropboxErrorAlert show];
                    }
                }];
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
    
    // Add forward slash to path if it does not exist (for dropbox)
    if ([path characterAtIndex:0] != '/') {
        path = [NSString stringWithFormat:@"/%@", path];
    }
    if ([[path substringFromIndex:path.length-s] caseInsensitiveCompare:ext] != NSOrderedSame)
        return [NSString stringWithFormat:@"%@%@",path,ext];
    return path;
}

@end
