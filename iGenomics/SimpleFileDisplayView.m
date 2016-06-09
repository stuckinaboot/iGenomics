//
//  SimpleFileDisplayView.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 8/4/15.
//
//

#import "SimpleFileDisplayView.h"

@implementation SimpleFileDisplayView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        dismissKeyboardRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
        
        float utilBtnWidth = frame.size.width * kSimpleFileDisplayViewUtilityBtnWidthScaleFactor;
        
        CGRect frame = self.frame;
        searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - utilBtnWidth, 0)];//Height will auto be set to the correct height
        [searchBar sizeToFit];
        [searchBar setDelegate:self];
        
        utilityContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, searchBar.frame.size.height)];
        [utilityContainerView addSubview:searchBar];
        
        DNAColors *dnaColors = [[DNAColors alloc] init];
        [dnaColors setUp];
        
        float x = searchBar.frame.size.width;
        
        UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        doneBtn.frame = CGRectMake(x, 0, utilBtnWidth, searchBar.frame.size.height);
        [doneBtn setBackgroundColor:[[dnaColors defaultBtn] UIColorObj]];
        [doneBtn setTitle:kSimpleFileDisplayViewBtnDoneTxt forState:UIControlStateNormal];
        [doneBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [doneBtn addTarget:self action:@selector(donePressed:) forControlEvents:UIControlEventTouchUpInside];
        [utilityContainerView addSubview:doneBtn];
        [self addSubview:utilityContainerView];
        
        tblView = [[UITableView alloc] initWithFrame:CGRectMake(0, utilityContainerView.frame.size.height, frame.size.width, frame.size.height-utilityContainerView.frame.size.height)];
        [tblView setDelegate:self];
        [tblView setDataSource:self];
        [self addSubview:tblView];
        
        searchedFileArr = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)displayWithFilesArray:(NSArray *)filesArray deletingFilesEnabled:(BOOL)deletingEnabled {
    if (deletingEnabled) {
        if ([tblView.gestureRecognizers count] == 0 || ([tblView.gestureRecognizers count] > 0 && ![tblView.gestureRecognizers[0] isKindOfClass:[UILongPressGestureRecognizer class]])) {
            UILongPressGestureRecognizer *recog = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressDeleteGesture:)];
            recog.minimumPressDuration = kSimpleFileDisplayTblItemDeleteLongPressDuration;
            [tblView addGestureRecognizer:recog];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideUtilityMenu:) name:UIMenuControllerDidHideMenuNotification object:nil];
        }
    }
    else
        if (([tblView.gestureRecognizers count] > 0 && ![tblView.gestureRecognizers[0] isKindOfClass:[UILongPressGestureRecognizer class]]))
            [tblView removeGestureRecognizer:tblView.gestureRecognizers[0]];
    
    entireFileArr = filesArray;
    searchedFileArr = [NSMutableArray arrayWithArray:entireFileArr];
    [tblView reloadData];
}

- (void)presentInView:(UIView *)view {
    self.alpha = 0.0f;
    [view addSubview:self];
    [UIView animateWithDuration:kSimpleFileDisplayViewFadeAnimationDuration animations:^{
        self.alpha = 1.0f;
        [view bringSubviewToFront:self];
    }];
}

- (IBAction)donePressed:(id)sender {
    NSIndexPath *path = [tblView indexPathForSelectedRow];
    if (!path || [entireFileArr count] == 0) {
        [self removeFromView];
        return;
    }
    int row = (int)path.row;
    [delegate fileSelected:searchedFileArr[row] inSimpleFileDisplayView:self];
    [self removeFromView];
}

- (void)removeFromView {
    [UIView animateWithDuration:kSimpleFileDisplayViewFadeAnimationDuration animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished){
        [self removeFromSuperview];
    }];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [searchedFileArr removeAllObjects];
    if (![searchText isEqualToString:@""]) {
        for (APFile *file in entireFileArr) {
            if ([[file.name lowercaseString] rangeOfString:[searchText lowercaseString]].location == 0)
                [searchedFileArr addObject:file];
        }
    }
    else
        searchedFileArr = [[NSMutableArray alloc] initWithArray:entireFileArr];
    [tblView reloadData];
}

- (void)setLocalFilesArray:(NSArray *)array {
    entireFileArr = array;
    searchedFileArr = [[NSMutableArray alloc] initWithArray:array];
    [tblView reloadData];
}

#pragma Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [searchedFileArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    APTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[APTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:MyIdentifier];
    }
    
    if ([searchedFileArr count] > 0) {
        APFile *file = [searchedFileArr objectAtIndex:indexPath.row];
        cell.textLabel.text = file.name;
    }
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isSelected]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [delegate fileSelected:NULL inSimpleFileDisplayView:self];
        return nil;
    }
    else
        [delegate fileSelected:searchedFileArr[(int)indexPath.row] inSimpleFileDisplayView:self];
    return indexPath;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return YES;
}

#pragma Long Press Delete

- (void)handleLongPressDeleteGesture:(UILongPressGestureRecognizer *)gestureRecognizer {
    [self displayDeleteBtnForGestureRecognizer:gestureRecognizer];
}

- (void)displayDeleteBtnForGestureRecognizer:(UIGestureRecognizer*)recognizer {
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (![menuController isMenuVisible])
        return;
    
    UIMenuItem *itemDel = [[UIMenuItem alloc] initWithTitle:kSimpleFileDisplayTblItemDeleteBtnTitle action:@selector(deletePressed:)];
    UIMenuItem *itemRename = [[UIMenuItem alloc] initWithTitle:kSimpleFileDisplayTblItemRenameBtnTitle action:@selector(renamePressed:)];

    [menuController setMenuItems:@[itemRename, itemDel]];
    
    APTableViewCell *cell = (APTableViewCell*)[tblView cellForRowAtIndexPath:[tblView indexPathForRowAtPoint:[recognizer locationInView:tblView]]];
    CGRect rect = cell.frame;
    
    [menuController setTargetRect:rect inView:cell.superview];
    [cell becomeFirstResponder];
    
    [menuController setMenuVisible:YES animated:YES];
}

- (void)hideUtilityMenu:(NSNotification *)notif {
    [self resignFirstResponder];
}

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    if ([UIMenuController sharedMenuController].isMenuVisible)
//        [self hideUtilityMenu:nil];
//}

- (IBAction)deletePressed:(id)sender {
    APFile *file = searchedFileArr[[tblView indexPathForSelectedRow].row];
    [delegate deletePressedForFile:file inSimpleFileDisplayView:self];
}

- (IBAction)renamePressed:(id)sender {
    renameFileAlert = [[UIAlertView alloc] initWithTitle:kSimpleFileDisplayViewAlertRenameFileTitle message:kSimpleFileDisplayViewAlertRenameFileMsg delegate:self cancelButtonTitle:kSimpleFileDisplayViewAlertRenameFileBtnCancel otherButtonTitles:kSimpleFileDisplayViewAlertRenameFileBtnRename, nil];
    [renameFileAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [renameFileAlert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView isEqual:renameFileAlert]) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:kSimpleFileDisplayViewAlertRenameFileBtnRename]) {
            NSString *str = [renameFileAlert textFieldAtIndex:0].text;
            APFile *file = searchedFileArr[[tblView indexPathForSelectedRow].row];
            [delegate renamePressedForFile:file withNewName:str inSimpleFileDisplayView:self];
        }
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    NSString *selStr = NSStringFromSelector(action);
    if ([selStr isEqualToString:NSStringFromSelector(@selector(deletePressed:))])
        return YES;
    else if ([selStr isEqualToString:NSStringFromSelector(@selector(renamePressed:))])
        return YES;
    return NO;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self addGestureRecognizer:dismissKeyboardRecog];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar {
    [aSearchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)search
{
    [search resignFirstResponder];
}

- (void)dismissKeyboard {
    [searchBar resignFirstResponder];
    [self removeGestureRecognizer:dismissKeyboardRecog];
}

@end
