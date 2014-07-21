//
//  FileInputView.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 7/21/14.
//
//

#import "FileInputView.h"

@implementation FileInputView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setUpWithFileManager:(FileManager *)manager andInstructLblText:(NSString *)instructTxt andSearchBarPlaceHolderTxt:(NSString *)placeHolderTxt {
    fileManager = manager;
    instructLbl.text = instructTxt;
    searchBar.placeholder = placeHolderTxt;
    
    UIToolbar* keyboardToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, kKeyboardToolbarHeight)];
    
    keyboardToolbar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithTitle:kKeyboardDoneBtnTxt style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard:)], nil];
    searchBar.inputAccessoryView = keyboardToolbar;
    
    selectedOption = -1;
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL showSelectedRow = TRUE; //Used to prevent user from accidentally selecting wrong item
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
                        showSelectedRow = FALSE;
                    }
                }
            }
            else
                filteredFileNames = [NSMutableArray arrayWithArray:fileManager.dropboxFileNames];
            filteredFileNames = [FileManager fileArrayByKeepingOnlyFilesOfTypes:[NSArray arrayWithObjects:kFa, kFq, nil] fromDropboxFileArray:filteredFileNames];
            [tableView reloadData];
        }
    }
    else {
        selectedOption = indexPath.row;
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
                filteredFileNames = [FileManager fileArrayByKeepingOnlyFilesOfTypes:[NSArray arrayWithObjects:kFa, kFq, nil] fromDropboxFileArray:filteredFileNames];
            }
            else
                selectedOption = -1;
        }
        else if (selectedOption == kSavedFilesIndex)
            filteredFileNames = [NSMutableArray arrayWithArray:fileManager.defaultFileNames];
        [tableView reloadData];
    }
    NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    [tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
    if (!showSelectedRow)
        [tableView deselectRowAtIndexPath:path animated:YES];
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
        if ([parentOfParentPath isEqual:[DBPath root]])
            selectedOption = -1;
        else {
            filteredFileNames = [fileManager fileNamesForPath:parentOfParentPath];
        }
        parentPath = parentOfParentPath;
        [self searchBar:searchBar textDidChange:@""];
    }
    else
        selectedOption = -1;
    [tblView reloadData];
}

- (IBAction)cellDoubleTapped:(id)sender {
    NSString *s = @"";
    
    if (selectedOption == kSavedFilesIndex) {
        s = [filteredFileNames objectAtIndex:[tblView indexPathForSelectedRow].row];//Component 0 for default files for now
        s = [fileManager fileContentsForNameWithExt:s];
        NSString *oldStr = [s substringFromIndex:[s rangeOfString:kLineBreak].location+1];
        s = [[s componentsSeparatedByString:kLineBreak] objectAtIndex:0];//Gets just first line
        s = [NSString stringWithFormat:@"%@\n%@",s,[oldStr stringByReplacingOccurrencesOfString:kLineBreak withString:@""]];
    }
    else if (selectedOption == kDropboxFilesIndex) {
        DBFileInfo *info = [filteredFileNames objectAtIndex:[tblView indexPathForSelectedRow].row];
        if (info.isFolder)
            return;
        s = [fileManager fileContentsForPath:info.path];
    }
    
    [delegate displayFilePreviewPopoverWithContents:s atLocation:[(UIGestureRecognizer*)sender locationInView:self]];
}

@end
