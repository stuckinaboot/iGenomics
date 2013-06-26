//
//  FilePickerController.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/4/13.
//
//

#import "FilePickerController.h"

@interface FilePickerController ()

@end

@implementation FilePickerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma Set up methods

- (void)viewDidLoad
{
    parametersController = [[ParametersController alloc] init];
    selectedOptionRef = -1;
    selectedRowRef = 0;
    selectedOptionReads = -1;
    selectedRowReads = 0;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)setUpDefaultFiles {
    defaultRefFilesNames = [[NSMutableArray alloc] initWithArray:[[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kDefaultRefFilesNamesFile ofType:kTxt] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"]];
    
    filteredRefFileNames = [[NSMutableArray alloc] initWithArray:defaultRefFilesNames];
    
    defaultReadsFilesNames = [[NSMutableArray alloc] initWithArray:[[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kDefaultReadsFilesNamesFile ofType:kTxt] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"]];
    
    filteredReadFileNames = [[NSMutableArray alloc] initWithArray:defaultReadsFilesNames];
    
    if ([DBAccountManager sharedManager].linkedAccount)
        dbFileSys = [[DBFilesystem alloc] initWithAccount:[DBAccountManager sharedManager].linkedAccount];
}

#pragma Button Actions

- (IBAction)showParametersPressed:(id)sender {
    NSString *s = @"";
    NSString *sName = @"";
    NSString *r = @"";
    NSString *rName = @"";
    if (selectedOptionRef == kSavedFilesIndex) {
        s = [filteredRefFileNames objectAtIndex:selectedRowRef];//Component 0 for default files for now
        sName = [filteredRefFileNames objectAtIndex:selectedRowRef];
        NSArray *arr = [self getFileNameAndExtForFullName:s];
        s = [[NSString alloc] initWithString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[arr objectAtIndex:0] ofType:[arr objectAtIndex:1]] encoding:NSUTF8StringEncoding error:nil]];
    }
    else if (selectedOptionRef == kDropboxFilesIndex) {
        DBFileInfo *info = [filteredRefFileNames objectAtIndex:selectedRowRef];
        DBFile *file = [dbFileSys openFile:info.path error:nil];
        s = [file readString:nil];
        sName = [info.path name];
    }
    if (selectedOptionReads == kSavedFilesIndex) {
        r = [filteredReadFileNames objectAtIndex:selectedRowReads];
        rName = [filteredReadFileNames objectAtIndex:selectedRowReads];
        NSArray *arr = [self getFileNameAndExtForFullName:r];
        r = [[NSString alloc] initWithString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[arr objectAtIndex:0] ofType:[arr objectAtIndex:1]] encoding:NSUTF8StringEncoding error:nil]];
    }
    else if (selectedOptionReads == kDropboxFilesIndex) {
        DBFileInfo *info = [filteredReadFileNames objectAtIndex:selectedRowReads];
        DBFile *file = [dbFileSys openFile:info.path error:nil];
        r = [file readString:nil];
        rName = [info.path name];
    }
    [parametersController passInSeq:s andReads:r andRefFileName:sName andReadFileName:rName];
    [self presentModalViewController:parametersController animated:YES];
}

- (IBAction)backPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma Table View Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:referenceFilePicker]) {
        if (selectedOptionRef == -1)
            return kNumOfFilePickOptions;
        else if (selectedOptionRef == kSavedFilesIndex)
            return [filteredRefFileNames count];
        else if (selectedOptionRef == kDropboxFilesIndex)
            return [filteredRefFileNames count];//Num of dropbox files
    }
    else if ([tableView isEqual:readsFilePicker]) {
        if (selectedOptionReads == -1)
            return kNumOfFilePickOptions;
        else if (selectedOptionReads == kSavedFilesIndex)
            return [filteredReadFileNames count];
        else if (selectedOptionReads == kDropboxFilesIndex)
            return [filteredReadFileNames count];//Num of dropbox files
    }
    return 0;
}

/*
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,kHeaderHeight)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setTitle:@"Back" forState:UIControlStateNormal];
    btn.frame = CGRectMake(tableView.frame.size.width-kBackBtnWidth, 0, kBackBtnWidth, kHeaderHeight);
    
    UISearchBar *searchBar;
    if ([tableView isEqual:referenceFilePicker]) {
        [btn addTarget:self action:@selector(backRefTbl:) forControlEvents:UIControlEventTouchUpInside];
        refPickerSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width-kBackBtnWidth, kHeaderHeight)];
        searchBar = refPickerSearchBar;
    }
    else if ([tableView isEqual:readsFilePicker]) {
        [btn addTarget:self action:@selector(backReadsTbl:) forControlEvents:UIControlEventTouchUpInside];
        readsPickerSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width-kBackBtnWidth, kHeaderHeight)];
        searchBar = readsPickerSearchBar;
    }
    [searchBar setDelegate:self];
    [headerView addSubview:searchBar];
    [headerView addSubview:btn];
    return headerView;
    
}*/

- (IBAction)backRefTbl:(id)sender {
    if (selectedOptionRef == kDropboxFilesIndex) {
        DBFileInfo *info = [filteredRefFileNames objectAtIndex:0];
        DBPath *parent = [info.path parent];
        if ([parent isEqual:[DBPath root]])
            selectedOptionRef = -1;
        else {
            filteredRefFileNames = [NSMutableArray arrayWithArray:[dbFileSys listFolder:parent error:nil]];
        }
        [self searchBar:refPickerSearchBar textDidChange:@""];
    }
    else
        selectedOptionRef = -1;
    [referenceFilePicker reloadData];
}
- (IBAction)backReadsTbl:(id)sender {
    if (selectedOptionReads == kDropboxFilesIndex) {
        DBFileInfo *info = [filteredReadFileNames objectAtIndex:0];
        DBPath *parent = [info.path parent];
        if ([parent isEqual:[DBPath root]])
            selectedOptionReads = -1;
        else
            filteredReadFileNames = [NSMutableArray arrayWithArray:[dbFileSys listFolder:parent error:nil]];
        [self searchBar:readsPickerSearchBar textDidChange:@""];
    }
    else
        selectedOptionReads = -1;
    [readsFilePicker reloadData];
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
    }
    
    // Here we use the provided setImageWithURL: method to load the web image
    // Ensure you use a placeholder image otherwise cells will be initialized with no image
    if ([tableView isEqual:referenceFilePicker]) {
        if (selectedOptionRef == -1) {
            if (indexPath.row == kSavedFilesIndex)
                [cell.textLabel setText:kSavedFilesTitle];
            else if (indexPath.row == kDropboxFilesIndex)
                [cell.textLabel setText:kDropboxFilesTitle];
        }
        else if (selectedOptionRef == kSavedFilesIndex) {
            [cell.textLabel setText:[filteredRefFileNames objectAtIndex:indexPath.row]];
        }
        else if (selectedOptionRef == kDropboxFilesIndex) {
            DBFileInfo *info = [filteredRefFileNames objectAtIndex:indexPath.row];
            [cell.textLabel setText:[info.path name]];//names of dropbox files
            if (info.isFolder)
                cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else if ([tableView isEqual:readsFilePicker]) {
        if (selectedOptionReads == -1) {
            if (indexPath.row == kSavedFilesIndex)
                [cell.textLabel setText:kSavedFilesTitle];
            else if (indexPath.row == kDropboxFilesIndex)
                [cell.textLabel setText:kDropboxFilesTitle];
        }
        else if (selectedOptionReads == kSavedFilesIndex)
            [cell.textLabel setText:[filteredReadFileNames objectAtIndex:indexPath.row]];
        else if (selectedOptionReads == kDropboxFilesIndex) {
            DBFileInfo *info = [filteredReadFileNames objectAtIndex:indexPath.row];
            [cell.textLabel setText:[info.path name]];//names of dropbox files
            if (info.isFolder)
                cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([tableView isEqual:referenceFilePicker]) {
        if (selectedOptionRef > -1) {
            selectedRowRef = indexPath.row;
            if (selectedOptionRef == kDropboxFilesIndex) {
                if ([filteredRefFileNames count] > 0) {
                    if (![[filteredRefFileNames objectAtIndex:0] isKindOfClass:[DBFileInfo class]])
                        filteredRefFileNames = [NSMutableArray arrayWithArray:allDropboxFiles];
                    else {
                        DBFileInfo *info = [filteredRefFileNames objectAtIndex:selectedRowRef];
                        if (info.isFolder)
                            if ([self folderIsNotEmptyAtPath:info.path])
                                filteredRefFileNames = [NSMutableArray arrayWithArray:[dbFileSys listFolder:info.path error:nil]];
                    }
                }
                else
                    filteredRefFileNames = [NSMutableArray arrayWithArray:allDropboxFiles];
                [tableView reloadData];
            }
        }
        else {
            selectedOptionRef = indexPath.row;
            if (selectedOptionRef == kDropboxFilesIndex) {
                if ([DBAccountManager sharedManager].linkedAccount == NULL)
                    [[DBAccountManager sharedManager] linkFromController:self];
                DBAccount *account = [DBAccountManager sharedManager].linkedAccount;
                if (account) {
                    if (!dbFileSys)
                        dbFileSys = [DBFilesystem sharedFilesystem];
                    [self setUpAllDropboxFiles];
                    filteredRefFileNames = [NSMutableArray arrayWithArray:allDropboxFiles];
                }
                else
                    selectedOptionRef = -1;
            }
            else if (selectedOptionRef == kSavedFilesIndex)
                filteredRefFileNames = [NSMutableArray arrayWithArray:defaultRefFilesNames];
            [tableView reloadData];
        }
        NSIndexPath *path = [NSIndexPath indexPathForRow:selectedRowRef inSection:0];
        [tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    else if ([tableView isEqual:readsFilePicker]) {
        if (selectedOptionReads > -1) {
            selectedRowReads = indexPath.row;
            if (selectedOptionReads == kDropboxFilesIndex) {
                if ([filteredReadFileNames count] > 0) {
                    if (![[filteredReadFileNames objectAtIndex:0] isKindOfClass:[DBFileInfo class]])
                        filteredReadFileNames = [NSMutableArray arrayWithArray:allDropboxFiles];
                    else {
                        DBFileInfo *info = [filteredReadFileNames objectAtIndex:selectedRowReads];
                        if (info.isFolder)
                            if ([self folderIsNotEmptyAtPath:info.path])
                                filteredReadFileNames = [NSMutableArray arrayWithArray:[dbFileSys listFolder:info.path error:nil]];
                    }
                }
                else
                filteredReadFileNames = [NSMutableArray arrayWithArray:allDropboxFiles];
                [tableView reloadData];
            }
        }
        else {
            selectedOptionReads = indexPath.row;
            if (selectedOptionReads == kDropboxFilesIndex) {
                if ([DBAccountManager sharedManager].linkedAccount == NULL)
                    [[DBAccountManager sharedManager] linkFromController:self];
                DBAccount *account = [DBAccountManager sharedManager].linkedAccount;
                if (account) {
                    if (!dbFileSys)
                        dbFileSys = [DBFilesystem sharedFilesystem];
                    [self setUpAllDropboxFiles];
                    filteredReadFileNames = [NSMutableArray arrayWithArray:allDropboxFiles];
                }
                else
                    selectedOptionReads = -1;
            }
            else if (selectedOptionReads == kSavedFilesIndex)
                filteredReadFileNames = [NSMutableArray arrayWithArray:defaultReadsFilesNames];
            [tableView reloadData];
        }
        NSIndexPath *path = [NSIndexPath indexPathForRow:selectedRowReads inSection:0];
        [tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)setUpAllDropboxFiles {
    allDropboxFiles = [[NSMutableArray alloc] initWithArray:[dbFileSys listFolder:[DBPath root] error:nil]];
}

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    if ([searchBar isEqual:refPickerSearchBar]) {
        if(text.length == 0) {
            if (selectedOptionRef == kSavedFilesIndex)
                filteredRefFileNames = [[NSMutableArray alloc] initWithArray:defaultRefFilesNames];
            else if (selectedOptionRef == kDropboxFilesIndex) {
                filteredRefFileNames = allDropboxFiles;
            }
        }
        else {
            [filteredRefFileNames removeAllObjects];
            if (selectedOptionRef != kDropboxFilesIndex) {
                for (NSString* s in defaultRefFilesNames) {
                    NSRange nameRange = [s rangeOfString:text options:NSCaseInsensitiveSearch];
                    if(nameRange.location != NSNotFound)
                        [filteredRefFileNames addObject:s];
                }
            }
            else {
                for (DBFileInfo* info in allDropboxFiles) {
                    NSString *s = [info.path name];
                    NSRange nameRange = [s rangeOfString:text options:NSCaseInsensitiveSearch];
                    if(nameRange.location != NSNotFound)
                        [filteredRefFileNames addObject:info];
                }
            }
            //may need to add something for dropbox support
        }
        [referenceFilePicker reloadData];
    }
    else if ([searchBar isEqual:readsPickerSearchBar]) {
        if(text.length == 0) {
            if (selectedOptionReads == kSavedFilesIndex)
                filteredReadFileNames = [[NSMutableArray alloc] initWithArray:defaultReadsFilesNames];
            else if (selectedOptionReads == kDropboxFilesIndex)
                filteredReadFileNames = allDropboxFiles;
        }
        else {
            [filteredReadFileNames removeAllObjects];
            if (selectedOptionReads != kDropboxFilesIndex) {
                for (NSString* s in defaultReadsFilesNames) {
                    NSRange nameRange = [s rangeOfString:text options:NSCaseInsensitiveSearch];
                    if(nameRange.location != NSNotFound)
                        [filteredReadFileNames addObject:s];
                }
            }
            else {
                for (DBFileInfo* info in allDropboxFiles) {
                    NSString *s = [info.path name];
                    NSRange nameRange = [s rangeOfString:text options:NSCaseInsensitiveSearch];
                    if(nameRange.location != NSNotFound)
                        [filteredReadFileNames addObject:info];
                }
            }
            //may need to add something for dropbox support
        }
        [readsFilePicker reloadData];
    }
}

- (BOOL)folderIsNotEmptyAtPath:(DBPath *)path {
    NSArray *arr = [dbFileSys listFolder:path error:nil];
    return [arr count] > 0;
}

- (NSArray*)getFileNameAndExtForFullName:(NSString *)fileName {
    //Search for first . starting from the end
    int index = 0;
    for (int i = fileName.length-1; i>0; i--) {
        if ([fileName characterAtIndex:i] == kExtDot) {
            index = i;
        }
    }
    return [NSArray arrayWithObjects:[fileName substringToIndex:index], [fileName substringFromIndex:index+1],nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
