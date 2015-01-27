//
//  FileInputView.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 7/21/14.
//
//

#import "FileInputView.h"

@implementation FileInputView

@synthesize delegate, tblView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setUpWithFileManager:(FileManager *)manager andInstructLblText:(NSString *)instructTxt andSearchBarPlaceHolderTxt:(NSString *)placeHolderTxt andSupportFileTypes:(NSArray*)supportedTypes andValidationStrings:(NSArray *)valStrs andMaxFileSize:(int)maxFS {
    
    fileManager = manager;
    [manager setMaxFileSize:maxFS];
    
    instructLbl.text = instructTxt;
    searchBar.placeholder = placeHolderTxt;
    validationStrings = valStrs;
    
    supportedFileTypes = supportedTypes;
    
    maxFileSize = maxFS;
    UIToolbar* keyboardToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, kKeyboardToolbarHeight)];
    
    keyboardToolbar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithTitle:kKeyboardDoneBtnTxt style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard:)], nil];
    searchBar.inputAccessoryView = keyboardToolbar;
    
    selectedOption = -1;
}

- (NSString*)nameOfSelectedRow {
    if (![tblView indexPathForSelectedRow])
        return @"";
    if (selectedOption == kSavedFilesIndex) {
        return [filteredFileNames objectAtIndex:[tblView indexPathForSelectedRow].row];
    }
    else if (selectedOption == kDropboxFilesIndex) {
        DBFileInfo *info = [filteredFileNames objectAtIndex:[tblView indexPathForSelectedRow].row];
        if (info.isFolder)
            return @"";
        return [info.path name];
    }
    return @"";
}

- (NSString*)contentsOfSelectedRow {
    if (![tblView indexPathForSelectedRow])
        return @"";
    if (selectedOption == kSavedFilesIndex) {
        NSString *fileName = [self nameOfSelectedRow];
        return [fileManager fileContentsForNameWithExt:fileName];
    }
    else if (selectedOption == kDropboxFilesIndex) {
        DBFileInfo *info = [filteredFileNames objectAtIndex:[tblView indexPathForSelectedRow].row];
        if (info.isFolder)
            return @"";
        return [fileManager fileContentsForPath:info.path];
    }
    return @"";
}

- (BOOL)selectedFilePassedValidation {
    NSString *fileContents = [self contentsOfSelectedRow];
    if (![fileContents isEqualToString:@""]) {
        if (!validationStrings)
            return YES;
        else {
            for (NSString *validationStr in validationStrings)
                if ([validationStr isEqualToString:[fileContents substringToIndex:validationStr.length]])
                    return YES;
        }
        [GlobalVars displayiGenomicsAlertWithMsg:kFileInputFailedValidation];
        return NO;
    }
    return YES;
}

- (BOOL)needsInternetToGetFile {
    return (selectedOption == kDropboxFilesIndex);
}

- (IBAction)dismissKeyboard:(id)sender {
    [searchBar resignFirstResponder];
}

#pragma Table View Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (selectedOption == -1)
        return kNumOfFilePickOptions;
    else if (selectedOption == kSavedFilesIndex)
        return [filteredFileNames count];
    else if (selectedOption == kDropboxFilesIndex)
        return [filteredFileNames count];//Num of dropbox files
    return 0;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isSelected]) {
        // Deselect manually.
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [tableView.delegate tableView:tableView didDeselectRowAtIndexPath:indexPath];
        
        return nil;
    }
    lastSelectedIndexPath = indexPath;
    return indexPath;
}

- (void)tableView:(UITableView*)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![tableView indexPathForSelectedRow])
        [delegate fileSelected:NO InFileInputView:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL shouldShowSelectedRow = YES;
    if (selectedOption > -1) {
        if (selectedOption == kDropboxFilesIndex) {
            if ([filteredFileNames count] > 0) {
                if (![[filteredFileNames objectAtIndex:0] isKindOfClass:[DBFileInfo class]]) {
                    filteredFileNames = [NSMutableArray arrayWithArray:fileManager.dropboxFileNames];
                    parentPath = [DBPath root];
                }
                else {
                    DBFileInfo *info = [filteredFileNames objectAtIndex:indexPath.row];
                    if (info.isFolder) {
                        filteredFileNames = [fileManager fileNamesForPath:info.path];
                        parentPath = info.path;
                    }
                    shouldShowSelectedRow = !info.isFolder;
                    if (!info.isFolder && info.size > maxFileSize) {
                        [GlobalVars displayiGenomicsAlertWithMsg:[NSString stringWithFormat:kDropboxFileTooLargeAlertMsg]];
                        shouldShowSelectedRow = NO;
                    }
                    else
                        [delegate fileSelected:!info.isFolder InFileInputView:self];
                }
            }
            else
                filteredFileNames = [NSMutableArray arrayWithArray:fileManager.dropboxFileNames];
            filteredFileNames = [FileManager fileArrayByKeepingOnlyFilesOfTypes:supportedFileTypes fromDropboxFileArray:filteredFileNames];
            [tableView reloadData];
        }
        else
            [delegate fileSelected:YES InFileInputView:self];
    }
    else {
        selectedOption = indexPath.row;
        shouldShowSelectedRow = NO;
        [delegate fileSelected:NO InFileInputView:self];
        if (selectedOption == kDropboxFilesIndex) {
            if (![GlobalVars internetAvailable]) {
                selectedOption = -1;
                return;
            }
            if ([DBAccountManager sharedManager].linkedAccount == NULL)
                [[DBAccountManager sharedManager] linkFromController:[delegate getVC]];
            DBAccount *account = [DBAccountManager sharedManager].linkedAccount;
            if (account) {
                if (!fileManager.dbFileSys)
                    [fileManager setUpForDropbox];
                filteredFileNames = [NSMutableArray arrayWithArray:fileManager.dropboxFileNames];
                filteredFileNames = [FileManager fileArrayByKeepingOnlyFilesOfTypes:supportedFileTypes fromDropboxFileArray:filteredFileNames];
            }
            else
                selectedOption = -1;
        }
        else if (selectedOption == kSavedFilesIndex)
            filteredFileNames = [NSMutableArray arrayWithArray:fileManager.defaultFileNames];
        [tableView reloadData];
    }
    NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    if (shouldShowSelectedRow)
        [tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier];
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellDoubleTapped:)];
        [recognizer setNumberOfTapsRequired:kMinTapsRequired];
        [cell addGestureRecognizer:recognizer];
    }
    
    if (selectedOption == -1) {
        if (indexPath.row == kSavedFilesIndex)
            [cell.textLabel setText:kSavedFilesTitle];
        else if (indexPath.row == kDropboxFilesIndex)
            [cell.textLabel setText:kDropboxFilesTitle];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if (selectedOption == kSavedFilesIndex) {
        [cell.textLabel setText:[filteredFileNames objectAtIndex:indexPath.row]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if (selectedOption == kDropboxFilesIndex) {
        DBFileInfo *info = [filteredFileNames objectAtIndex:indexPath.row];
        [cell.textLabel setText:[info.path name]];//names of dropbox files
        if (info.isFolder)
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (IBAction)backTbl:(id)sender {
    if (selectedOption == kDropboxFilesIndex) {
        DBPath *parentOfParentPath = [parentPath parent];
        if ([parentPath isEqual:[DBPath root]])
            selectedOption = -1;
        else {
            filteredFileNames = [fileManager fileNamesForPath:parentOfParentPath];
            if (!filteredFileNames)
                selectedOption = -1;
        }
        parentPath = parentOfParentPath;
        [self searchBar:searchBar textDidChange:@""];
    }
    else
        selectedOption = -1;
    [delegate fileSelected:NO InFileInputView:self];
    [tblView reloadData];
}

- (IBAction)cellDoubleTapped:(id)sender {
    [tblView selectRowAtIndexPath:lastSelectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [delegate fileSelected:YES InFileInputView:self];
    NSString *s = @"";
    NSString *ext = @"";
    if (selectedOption == kSavedFilesIndex) {
        s = [filteredFileNames objectAtIndex:[tblView indexPathForSelectedRow].row];//Component 0 for default files for now
        ext = [[FileManager getFileNameAndExtForFullName:s] objectAtIndex:1];
        s = [fileManager fileContentsForNameWithExt:s];
    }
    else if (selectedOption == kDropboxFilesIndex) {
        DBFileInfo *info = [filteredFileNames objectAtIndex:[tblView indexPathForSelectedRow].row];
        if (info.isFolder)
            return;
        s = [fileManager fileContentsForPath:info.path];
    }
    
    if ([s isEqualToString:@""])
        return;

    if ([ext caseInsensitiveCompare:kFa] == NSOrderedSame) {
        NSArray *sComponents = [NSArray arrayWithArray:[[s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:kLineBreak]];
        if ([[sComponents objectAtIndex:kFaInterval] characterAtIndex:0] != kFaFileTitleIndicator) {//Makes sure its not a reads file
            NSMutableString *newStr = [[NSMutableString alloc] init];
            for (int i = 0; i < [sComponents count]; i++) {
                if ([[sComponents objectAtIndex:i] characterAtIndex:0] == kFaFileTitleIndicator)
                    [newStr appendFormat:@"%@%@\n", (i > 0) ? kLineBreak : @"",[sComponents objectAtIndex:i]];
                else
                    [newStr appendString:[sComponents objectAtIndex:i]];
            }
            s = newStr;
//            NSString *oldStr = [s substringFromIndex:[s rangeOfString:kLineBreak].location+1];
//            s = [[s componentsSeparatedByString:kLineBreak] objectAtIndex:0];//Gets just first line
//            s = [NSString stringWithFormat:@"%@\n%@",s,[oldStr stringByReplacingOccurrencesOfString:kLineBreak withString:@""]];
        }
    }
    CGRect frame = [tblView rectForRowAtIndexPath:[tblView indexPathForSelectedRow]];
    CGPoint loc = CGPointMake(frame.origin.x+frame.size.width/2, tblView.frame.origin.y+frame.origin.y+frame.size.height);
    [delegate displayFilePreviewPopoverWithContents:s atLocation:loc fromFileInputView:self];
}

#pragma Search Bar delegate

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    if(text.length == 0) {
        if (selectedOption == kSavedFilesIndex)
            filteredFileNames = [[NSMutableArray alloc] initWithArray:fileManager.defaultFileNames];
        else if (selectedOption == kDropboxFilesIndex) {
            filteredFileNames = [fileManager fileNamesForPath:parentPath];
            filteredFileNames = [FileManager fileArrayByKeepingOnlyFilesOfTypes:supportedFileTypes fromDropboxFileArray:filteredFileNames];
        }
    }
    else {
        [filteredFileNames removeAllObjects];
        if (selectedOption != kDropboxFilesIndex)
            filteredFileNames = [fileManager fileNamesArrayWithNamesContainingTxt:text inArr:fileManager.defaultFileNames];
        else {
            filteredFileNames = [fileManager fileNamesArrayWithNamesContainingTxt:text inArr:[fileManager fileNamesForPath:parentPath]];
            filteredFileNames = [FileManager fileArrayByKeepingOnlyFilesOfTypes:supportedFileTypes fromDropboxFileArray:filteredFileNames];
        }
    }
    [tblView reloadData];
}

@end
