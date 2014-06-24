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

@synthesize previewPopoverController;

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
    
    isSelectingReads = FALSE;
    
    [self lockContinueBtns];
    
    UIToolbar* keyboardToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, kKeyboardToolbarHeight)];
    
    keyboardToolbar.items = [NSArray arrayWithObjects:
                             [[UIBarButtonItem alloc]initWithTitle:kKeyboardDoneBtnTxt style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard:)],
                             nil];
    readsPickerSearchBar.inputAccessoryView = keyboardToolbar;
    refPickerSearchBar.inputAccessoryView = keyboardToolbar;

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    if (isSelectingReads)
        [scrollView setContentOffset:CGPointMake(0, secondDataSelectionBarIPhoneOnly.frame.origin.y)];
}

- (void)viewDidAppear:(BOOL)animated {
    if ([GlobalVars isOldIPhone]) {
        if (!updatedScrollViewSize) {
            scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height*2);
            updatedScrollViewSize = TRUE;
        }
        if (isSelectingReads)
            [scrollView setContentOffset:CGPointMake(0, secondDataSelectionBarIPhoneOnly.frame.origin.y)];
        
        CGRect rect = referenceFilePicker.frame;
        referenceFilePicker.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height/kOldIphoneTblViewScaleFactor);
        rect = referenceFilePicker.frame;
        CGRect rect2 = nextBtn.frame;
        nextBtn.frame = CGRectMake(rect2.origin.x, rect.origin.y+rect.size.height+kFilePickerDistBwtBtnAndTblView, rect2.size.width, rect2.size.height);
        CGRect rect3 = readsFilePicker.frame;
        readsFilePicker.frame = CGRectMake(rect3.origin.x, rect3.origin.y, rect3.size.width, rect3.size.height/kOldIphoneTblViewScaleFactor);
        rect3 = readsFilePicker.frame;
        CGRect rect4 = analyzeBtn.frame;
        analyzeBtn.frame = CGRectMake(rect4.origin.x, rect3.origin.y+rect3.size.height+kFilePickerDistBwtBtnAndTblView, rect4.size.width, rect4.size.height);
        rect4 = configBtn.frame;
        configBtn.frame = CGRectMake(rect4.origin.x, rect3.origin.y+rect3.size.height+kFilePickerDistBwtBtnAndTblView, rect4.size.width, rect4.size.height);
    }
}

- (void)setUpDefaultFiles {
    defaultRefFilesNames = [[NSMutableArray alloc] initWithArray:[[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kDefaultRefFilesNamesFile ofType:kTxt] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"]];
    
    filteredRefFileNames = [[NSMutableArray alloc] initWithArray:defaultRefFilesNames];
    
    defaultReadsFilesNames = [[NSMutableArray alloc] initWithArray:[[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kDefaultReadsFilesNamesFile ofType:kTxt] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"]];
    
    filteredReadFileNames = [[NSMutableArray alloc] initWithArray:defaultReadsFilesNames];
    
    if ([DBAccountManager sharedManager].linkedAccount) {
        dbFileSys = [[DBFilesystem alloc] initWithAccount:[DBAccountManager sharedManager].linkedAccount];
        [DBFilesystem setSharedFilesystem:dbFileSys];
    }
}

- (void)resetScrollViewOffset {
    [scrollView setContentOffset:CGPointZero animated:NO];
    isSelectingReads = NO;
}

#pragma Button Actions

- (IBAction)showParametersPressed:(id)sender {
    NSString *s = @"";
    NSString *sName = @"";
    NSString *r = @"";
    NSString *rName = @"";
    
    if (multipleRefSelectionSwitch.on) {
        NSString *temp;
        if (selectedOptionRef == kSavedFilesIndex) {
            for (NSIndexPath *path in [referenceFilePicker indexPathsForSelectedRows]) {
                temp = [filteredRefFileNames objectAtIndex:path.row];
                sName = [NSString stringWithFormat:@"%@%@%@",sName,temp,kRefFileInternalDivider];
                
                NSArray *arr = [self getFileNameAndExtForFullName:temp];
                s = [NSString stringWithFormat:@"%@%@", s,[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[arr objectAtIndex:0] ofType:[arr objectAtIndex:1]] encoding:NSUTF8StringEncoding error:nil]];
            }
        }
        else if (selectedOptionRef == kDropboxFilesIndex) {
            if (![GlobalVars internetAvailable])
                return;
            for (NSIndexPath *path in [referenceFilePicker indexPathsForSelectedRows]) {
                DBFileInfo *info = [filteredRefFileNames objectAtIndex:path.row];
                sName = [NSString stringWithFormat:@"%@%@%@",sName,[info.path name],kRefFileInternalDivider];
                DBFile *file = [dbFileSys openFile:info.path error:nil];
                s = [NSString stringWithFormat:@"%@%@",s,[file readString:nil]];
            }
        }
        sName = [sName stringByReplacingCharactersInRange:NSMakeRange(sName.length-kRefFileInternalDivider.length, kRefFileInternalDivider.length) withString:@""];//Removes the final internal divider 
    }
    else {
        if (selectedOptionRef == kSavedFilesIndex) {
            s = [filteredRefFileNames objectAtIndex:selectedRowRef];//Component 0 for default files for now
            sName = [filteredRefFileNames objectAtIndex:selectedRowRef];
            NSArray *arr = [self getFileNameAndExtForFullName:s];
            s = [[NSString alloc] initWithString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[arr objectAtIndex:0] ofType:[arr objectAtIndex:1]] encoding:NSUTF8StringEncoding error:nil]];
        }
        else if (selectedOptionRef == kDropboxFilesIndex) {
            if (![GlobalVars internetAvailable])
                return;
            DBFileInfo *info = [filteredRefFileNames objectAtIndex:selectedRowRef];
            DBFile *file = [dbFileSys openFile:info.path error:nil];
            s = [file readString:nil];
            sName = [info.path name];
        }
    }
    if (selectedOptionReads == kSavedFilesIndex) {
        r = [filteredReadFileNames objectAtIndex:selectedRowReads];
        rName = [filteredReadFileNames objectAtIndex:selectedRowReads];
        NSArray *arr = [self getFileNameAndExtForFullName:r];
        r = [[NSString alloc] initWithString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[arr objectAtIndex:0] ofType:[arr objectAtIndex:1]] encoding:NSUTF8StringEncoding error:nil]];
    }
    else if (selectedOptionReads == kDropboxFilesIndex) {
        if (![GlobalVars internetAvailable])
            return;
        DBFileInfo *info = [filteredReadFileNames objectAtIndex:selectedRowReads];
        DBFile *file = [dbFileSys openFile:info.path error:nil];
        r = [file readString:nil];
        rName = [info.path name];
    }
    [parametersController passInSeq:s andReads:r andRefFileName:sName andReadFileName:rName];
    [self presentViewController:parametersController animated:YES completion:nil];
}

- (IBAction)analyzePressed:(id)sender {
    isSelectingReads = NO;
    @try {
        NSLog(@"Try Block Entered");
        if (selectedOptionReads == kDropboxFilesIndex || selectedOptionRef == kDropboxFilesIndex)
            if (![GlobalVars internetAvailable])
                return;
        
        NSLog(@"About to set computing controller");
        parametersController.computingController = [[ComputingController alloc] init];
        
        NSLog(@"About to present View Controller");
        [self presentViewController:parametersController.computingController animated:NO completion:nil];
        NSLog(@"About to perform selector");
        [self performSelector:@selector(beginActualSequencingPredefinedParameters) withObject:nil afterDelay:kStartSeqDelay];
        NSLog(@"Try Block Finished");
    }
    @catch (NSException *exception) {
        NSLog(@"Analyze Pressed Exception: %@, %@",exception.debugDescription, exception.description);
    }
    @finally {
        NSLog(@"Finally Reached");
    }
}

- (IBAction)nextPressedOnIPhone:(id)sender {
    [scrollView setContentOffset:CGPointMake(0, secondDataSelectionBarIPhoneOnly.frame.origin.y) animated:YES];
    isSelectingReads = YES;
    
    if (referenceFilePicker.indexPathForSelectedRow == nil)
        [self lockContinueBtns];
}

- (void)lockContinueBtns {
    [analyzeBtn setAlpha:kLockedBtnAlpha];
    analyzeBtn.enabled = FALSE;
    [configBtn setAlpha:kLockedBtnAlpha];
    configBtn.enabled = FALSE;
}
- (void)unlockContinueBtns {
    [analyzeBtn setAlpha:1.0f];
    analyzeBtn.enabled = TRUE;
    [configBtn setAlpha:1.0f];
    configBtn.enabled = TRUE;
}

- (void)beginActualSequencingPredefinedParameters {
    NSLog(@"Entered beginActualSequencingPredefinedParameters");
    
    NSString *s = @"";
    NSString *sName = @"";
    NSString *r = @"";
    NSString *rName = @"";
    
    if (multipleRefSelectionSwitch.on) {
        NSString *temp;
        if (selectedOptionRef == kSavedFilesIndex) {
            for (NSIndexPath *path in [referenceFilePicker indexPathsForSelectedRows]) {
                temp = [filteredRefFileNames objectAtIndex:path.row];
                sName = [NSString stringWithFormat:@"%@%@%@",sName,temp,kRefFileInternalDivider];
                
                NSArray *arr = [self getFileNameAndExtForFullName:temp];
                s = [NSString stringWithFormat:@"%@%@", s,[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[arr objectAtIndex:0] ofType:[arr objectAtIndex:1]] encoding:NSUTF8StringEncoding error:nil]];
            }
        }
        else if (selectedOptionRef == kDropboxFilesIndex) {
            if (![GlobalVars internetAvailable])
                return;
            for (NSIndexPath *path in [referenceFilePicker indexPathsForSelectedRows]) {
                DBFileInfo *info = [filteredRefFileNames objectAtIndex:path.row];
                sName = [NSString stringWithFormat:@"%@%@%@",sName,[info.path name],kRefFileInternalDivider];
                DBFile *file = [dbFileSys openFile:info.path error:nil];
                s = [NSString stringWithFormat:@"%@%@",s,[file readString:nil]];
            }
        }
        sName = [sName stringByReplacingCharactersInRange:NSMakeRange(sName.length-kRefFileInternalDivider.length, kRefFileInternalDivider.length) withString:@""];//Removes the final internal divider
    }
    else {
        if (selectedOptionRef == kSavedFilesIndex) {
            s = [filteredRefFileNames objectAtIndex:selectedRowRef];//Component 0 for default files for now
            sName = [filteredRefFileNames objectAtIndex:selectedRowRef];
            NSArray *arr = [self getFileNameAndExtForFullName:s];
            s = [[NSString alloc] initWithString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[arr objectAtIndex:0] ofType:[arr objectAtIndex:1]] encoding:NSUTF8StringEncoding error:nil]];
        }
        else if (selectedOptionRef == kDropboxFilesIndex) {
            if (![GlobalVars internetAvailable])
                return;
            DBFileInfo *info = [filteredRefFileNames objectAtIndex:selectedRowRef];
            DBFile *file = [dbFileSys openFile:info.path error:nil];
            s = [file readString:nil];
            sName = [info.path name];
        }
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
    
    NSLog(@"beginActualSequencingPredefinedParameters... Files Loaded");
    
    [parametersController passInSeq:s andReads:r andRefFileName:sName andReadFileName:rName];
    s = parametersController.seq;
    r = parametersController.reads;
    sName = parametersController.refFileName;
    rName = parametersController.readFileName;
    
    NSLog(@"beginActualSequencingPredefinedParameters Names fixed");
    
    //Loads past parameters, if they are null set a default set of parameters
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arr = [defaults objectForKey:kLastUsedParamsSaveKey];
    
    if ([[parametersController extFromFileName:rName] caseInsensitiveCompare:kFq] != NSOrderedSame) {
        arr = [arr mutableCopy];
        [arr setObject:[NSNumber numberWithInt:kTrimmingOffVal] atIndexedSubscript:kParameterArrayTrimmingValIndex];//Disables trimming for non-Fq files
    }
    
    if (arr == NULL) {
        arr = (NSMutableArray*)[NSArray arrayWithObjects:[NSNumber numberWithInt:1/*Substitutions*/], [NSNumber numberWithInt:2] /*ED*/, [NSNumber numberWithInt:1] /*Alignment type (forward and reverse)*/, [NSNumber numberWithInt:2] /*Mut support*/, [NSNumber numberWithInt:0] /*Trimming*/, nil];//Contains everything except refFileName and readFileName
        [defaults setObject:arr forKey:kLastUsedParamsSaveKey];
        [defaults synchronize];
    }
    
    NSLog(@"beginActualSequencingPredefinedParameters Old Parameters loaded, preparing to load computingController");
    
    [parametersController.computingController setUpWithReads:r andSeq:s andParameters:[arr arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:sName, rName, nil]]];
    
    NSLog(@"Computing controller loaded");
}

- (IBAction)backPressed:(id)sender {
    if ([GlobalVars isIpad])
        [self dismissViewControllerAnimated:YES completion:nil];
    else {
        if (scrollView.contentOffset.y > 0)
            [scrollView setContentOffset:CGPointZero animated:YES];
        else
            [self dismissViewControllerAnimated:YES completion:nil];
        isSelectingReads = NO;
    }
}

#pragma Multiple Ref Selection

- (IBAction)multipleRefSelectionValueChanged:(id)sender {
    NSIndexPath *path = [referenceFilePicker.indexPathsForSelectedRows objectAtIndex:0];
    referenceFilePicker.allowsMultipleSelection = multipleRefSelectionSwitch.on;
    if (!referenceFilePicker.allowsMultipleSelection)//Selects the first of the multiple selected files so that there is one selected
        [referenceFilePicker selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
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
        DBPath *parentPath = [parentFolderPathRef parent];
        if ([parentFolderPathRef isEqual:[DBPath root]])
            selectedOptionRef = -1;
        else {
            filteredRefFileNames = [NSMutableArray arrayWithArray:[dbFileSys listFolder:parentPath error:nil]];
        }
        parentFolderPathRef = parentPath;
        [self searchBar:refPickerSearchBar textDidChange:@""];
    }
    else
        selectedOptionRef = -1;
    refSelected = FALSE;
    if (analyzeBtn.enabled)//Currently unlocked
        [self lockContinueBtns];
    [referenceFilePicker reloadData];
}
- (IBAction)backReadsTbl:(id)sender {
    if (selectedOptionReads == kDropboxFilesIndex) {
        DBPath *parentPath = [parentFolderPathReads parent];
        if ([parentFolderPathReads isEqual:[DBPath root]])
            selectedOptionReads = -1;
        else
            filteredReadFileNames = [NSMutableArray arrayWithArray:[dbFileSys listFolder:parentPath error:nil]];
        parentFolderPathReads = parentPath;
        [self searchBar:readsPickerSearchBar textDidChange:@""];
    }
    else
        selectedOptionReads = -1;
    readsSelected = FALSE;
    if (analyzeBtn.enabled)//Currently unlocked
        [self lockContinueBtns];
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
        UITapGestureRecognizer *recognizer;
        if ([tableView isEqual:referenceFilePicker])
            recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongPressedRef:)];
        else if ([tableView isEqual:readsFilePicker])
            recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongPressedReads:)];
        [recognizer setNumberOfTapsRequired:kMinTapsRequired];
        [cell addGestureRecognizer:recognizer];
    }
    
    // Here we use the provided setImageWithURL: method to load the web image
    // Ensure you use a placeholder image otherwise cells will be initialized with no image
    if ([tableView isEqual:referenceFilePicker]) {
        if (selectedOptionRef == -1) {
            if (indexPath.row == kSavedFilesIndex)
                [cell.textLabel setText:kSavedFilesTitle];
            else if (indexPath.row == kDropboxFilesIndex)
                [cell.textLabel setText:kDropboxFilesTitle];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else if (selectedOptionRef == kSavedFilesIndex) {
            [cell.textLabel setText:[filteredRefFileNames objectAtIndex:indexPath.row]];
            cell.accessoryType = UITableViewCellAccessoryNone;
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
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else if (selectedOptionReads == kSavedFilesIndex) {
            [cell.textLabel setText:[filteredReadFileNames objectAtIndex:indexPath.row]];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
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

- (IBAction)cellLongPressedRef:(id)sender {
    NSString *s = @"";
    
    if (selectedOptionRef == kSavedFilesIndex) {
        s = [filteredRefFileNames objectAtIndex:selectedRowRef];//Component 0 for default files for now
        NSArray *arr = [self getFileNameAndExtForFullName:s];
        s = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[arr objectAtIndex:0] ofType:[arr objectAtIndex:1]] encoding:NSUTF8StringEncoding error:nil];
        if ([[arr objectAtIndex:1] caseInsensitiveCompare:kFastaFileExt] == NSOrderedSame) {
            NSString *oldStr = [s substringFromIndex:[s rangeOfString:kLineBreak].location+1];
            s = [[s componentsSeparatedByString:kLineBreak] objectAtIndex:0];//Gets just first line
            s = [NSString stringWithFormat:@"%@\n%@",s,[oldStr stringByReplacingOccurrencesOfString:kLineBreak withString:@""]];
        }
    }
    else if (selectedOptionRef == kDropboxFilesIndex) {
        DBFileInfo *info = [filteredRefFileNames objectAtIndex:selectedRowRef];
        DBFile *file = [dbFileSys openFile:info.path error:nil];
        s = [file readString:nil];
    }
    [self displayPopoverOutOfCellWithContents:s atLocation:[(UIGestureRecognizer*)sender locationInView:self.view]];
}

- (IBAction)cellLongPressedReads:(id)sender {
    NSString *r = @"";
    
    if (selectedOptionReads == kSavedFilesIndex) {
        r = [filteredReadFileNames objectAtIndex:selectedRowReads];
        NSArray *arr = [self getFileNameAndExtForFullName:r];
        r = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[arr objectAtIndex:0] ofType:[arr objectAtIndex:1]] encoding:NSUTF8StringEncoding error:nil];
    }
    else if (selectedOptionReads == kDropboxFilesIndex) {
        DBFileInfo *info = [filteredReadFileNames objectAtIndex:selectedRowReads];
        DBFile *file = [dbFileSys openFile:info.path error:nil];
        r = [file readString:nil];
    }
    [self displayPopoverOutOfCellWithContents:r atLocation:[(UIGestureRecognizer*)sender locationInView:self.view]];
}

- (void)displayPopoverOutOfCellWithContents:(NSString *)contents atLocation:(CGPoint)loc {
    if (previewPopoverController.isPopoverVisible)
        return;
    FilePreviewPopoverController *controller = [[FilePreviewPopoverController alloc] init];
    [controller updateTxtViewContents:contents];
    
    if ([GlobalVars isIpad]) {
        previewPopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        [previewPopoverController setPopoverContentSize:controller.txtView.frame.size];
        [previewPopoverController presentPopoverFromRect:CGRectMake(loc.x, loc.y, 1, 1) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    else {
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL showSelectedRow = TRUE; //Used to prevent user from accidentally selecting wrong item
    if ([tableView isEqual:referenceFilePicker]) {
        if (selectedOptionRef > -1) {
            selectedRowRef = indexPath.row;
            if (selectedOptionRef == kDropboxFilesIndex) {
                if ([filteredRefFileNames count] > 0) {
                    if (![[filteredRefFileNames objectAtIndex:0] isKindOfClass:[DBFileInfo class]]) {
                        filteredRefFileNames = [NSMutableArray arrayWithArray:allDropboxFiles];
                        parentFolderPathRef = [DBPath root];
                    }
                    else {
                        DBFileInfo *info = [filteredRefFileNames objectAtIndex:selectedRowRef];
                        if (info.isFolder) {
                            filteredRefFileNames = [NSMutableArray arrayWithArray:[dbFileSys listFolder:info.path error:nil]];
                            parentFolderPathRef = info.path;
                            refSelected = FALSE;
                            showSelectedRow = FALSE;
                        }
                        else
                            refSelected = TRUE;
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
                if (![GlobalVars internetAvailable]) {
                    selectedOptionRef = -1;
                    return;
                }
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
            else if (selectedOptionRef == kSavedFilesIndex) {
                filteredRefFileNames = [NSMutableArray arrayWithArray:defaultRefFilesNames];
                refSelected = TRUE;
            }
            [tableView reloadData];
        }
        NSIndexPath *path = [NSIndexPath indexPathForRow:selectedRowRef inSection:0];
        [tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
        if (!showSelectedRow)
            [tableView deselectRowAtIndexPath:path animated:YES];
    }
    else if ([tableView isEqual:readsFilePicker]) {
        if (selectedOptionReads > -1) {
            selectedRowReads = indexPath.row;
            if (selectedOptionReads == kDropboxFilesIndex) {
                if ([filteredReadFileNames count] > 0) {
                    if (![[filteredReadFileNames objectAtIndex:0] isKindOfClass:[DBFileInfo class]]) {
                        filteredReadFileNames = [NSMutableArray arrayWithArray:allDropboxFiles];
                        parentFolderPathReads = [DBPath root];
                    }
                    else {
                        DBFileInfo *info = [filteredReadFileNames objectAtIndex:selectedRowReads];
                        if (info.isFolder) {
                            filteredReadFileNames = [NSMutableArray arrayWithArray:[dbFileSys listFolder:info.path error:nil]];
                            parentFolderPathReads = info.path;
                            readsSelected = FALSE;
                            showSelectedRow = FALSE;
                        }
                        else
                            readsSelected = TRUE;
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
                if (![GlobalVars internetAvailable]) {
                    selectedOptionReads = -1;
                    return;
                }
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
            else if (selectedOptionReads == kSavedFilesIndex) {
                filteredReadFileNames = [NSMutableArray arrayWithArray:defaultReadsFilesNames];
                readsSelected = TRUE;
            }
            [tableView reloadData];
        }
        NSIndexPath *path = [NSIndexPath indexPathForRow:selectedRowReads inSection:0];
        [tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
        if (!showSelectedRow)
            [tableView deselectRowAtIndexPath:path animated:YES];
    }
    if (readsSelected && refSelected)
        [self unlockContinueBtns];
    else if (analyzeBtn.enabled)//Currently unlocked
        [self lockContinueBtns];
}

- (void)setUpAllDropboxFiles {
    allDropboxFiles = [[NSMutableArray alloc] initWithArray:[dbFileSys listFolder:[DBPath root] error:nil]];
    parentFolderPathRef = [DBPath root];
    parentFolderPathReads = [DBPath root];
}

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    if ([searchBar isEqual:refPickerSearchBar]) {
        if(text.length == 0) {
            if (selectedOptionRef == kSavedFilesIndex)
                filteredRefFileNames = [[NSMutableArray alloc] initWithArray:defaultRefFilesNames];
            else if (selectedOptionRef == kDropboxFilesIndex) {
                filteredRefFileNames = [NSMutableArray arrayWithArray:[dbFileSys listFolder:parentFolderPathRef error:nil]];
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
                for (DBFileInfo* info in [dbFileSys listFolder:parentFolderPathRef error:nil]) {
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
                filteredReadFileNames = [NSMutableArray arrayWithArray:[dbFileSys listFolder:parentFolderPathReads error:nil]];
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
                for (DBFileInfo* info in [dbFileSys listFolder:parentFolderPathReads error:nil]) {
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

- (NSArray*)getFileNameAndExtForFullName:(NSString *)fileName {
    //Search for first . starting from the end
    int index = 0;
    for (int i = fileName.length-1; i>0; i--) {
        if ([fileName characterAtIndex:i] == kExtDot) {
            index = i;
            break;
        }
    }
    return [NSArray arrayWithObjects:[fileName substringToIndex:index], [fileName substringFromIndex:index+1],nil];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
}

- (IBAction)dismissKeyboard:(id)sender {
    [refPickerSearchBar resignFirstResponder];
    [readsPickerSearchBar resignFirstResponder];
}

- (NSUInteger)supportedInterfaceOrientations {
    if (![GlobalVars isIpad])
        return UIInterfaceOrientationMaskPortrait;
    else
        return UIInterfaceOrientationMaskLandscape;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
