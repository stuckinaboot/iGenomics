//
//  AnalysisControllerIPhoneToolbar.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 3/29/14.
//
//

#import "AnalysisControllerIPhoneToolbar.h"

@implementation AnalysisControllerIPhoneToolbar

@synthesize delegate, imptMutsDispView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
            }
    return self;
}

- (void)setUpWithImptMutationList:(NSMutableArray*)imptMutations {
    //Sets up the scrollview for paging
    scrollView.frame = CGRectMake(0, summaryNavBar.frame.size.height, scrollView.frame.size.width, scrollView.frame.size.height);

    UINib *mutsNib = [UINib nibWithNibName:kImportantMutationsDisplayViewNibName bundle:nil];
    imptMutsDispView = [[mutsNib instantiateWithOwner:imptMutsDispView options:nil] objectAtIndex:0];
    [imptMutsDispView setUpWithMutationsArray:imptMutations];
    [imptMutsDispView setDelegate:self];
    pages = [NSArray arrayWithObjects:btnsView, lblsView, segSelectView, imptMutsDispView,nil];
    
    scrollView.contentSize = CGSizeMake(self.bounds.size.width*[pages count], scrollView.bounds.size.height);
    
    float x = 0;
    CGSize size = scrollView.frame.size;
    for (UIView *view in pages) {
        [view setFrame:CGRectMake(x, 0, size.width, view.frame.size.height)];
        [scrollView addSubview:view];
        x += scrollView.frame.size.width;
    }
    
    [pageControl setNumberOfPages:[pages count]];
    [pageControl setCurrentPage:0];
    [self bringSubviewToFront:pageControl];
}

- (void)setAlignmentSegmentPckrBtn:(UIButton *)aBtn covProfileSegmentPckrBtn:(UIButton *)cBtn {
    showAlignmentViewSegmentPckrBtn = aBtn;
    showCoverageProfileSegmentPckrBtn = cBtn;
}

- (void)addDoneBtnForTxtFields:(NSArray*)txtFields {

    UIToolbar* keyboardToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, kKeyboardToolbarHeight)];
    
    keyboardToolbar.items = [NSArray arrayWithObjects:
                             [[UIBarButtonItem alloc]initWithTitle:kKeyboardDoneBtnTxt style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard:)],
                             nil];
    
    UITextField *txtField;
    for (int i = 0; i < [txtFields count]; i++) {
        txtField = [txtFields objectAtIndex:i];
        txtField.inputAccessoryView = keyboardToolbar;
        [txtField setDelegate:self];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.bounds.size.width;
    int page = floorf((scrollView.contentOffset.x - pageWidth/2.0f) / pageWidth) + 1;
    pageControl.currentPage = page;
}

- (IBAction)pageChanged:(id)sender {
    CGRect rect = self.frame;
    [scrollView scrollRectToVisible:CGRectMake((pageControl.currentPage-1)*rect.size.width, 0, rect.size.width, rect.size.height) animated:YES];
}

- (IBAction)dismissKeyboard:(id)sender {
    [self endEditing:YES];
    for (UITextField* field in [self subviews]) {
        [field resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditing:YES];
    return YES;
}

- (IBAction)showAlignmentsPressed:(id)sender {
    BOOL calledByPicker = [sender isEqual:showAlignmentViewSegmentPckrBtn];
    int index = 0;
    if (calledByPicker) {
        UIPickerView *segmentPckr;
        for (UIPickerView *picker in [segSelectView subviews]) {
            segmentPckr = picker;
            break;
        }
        index = (int)[segmentPckr selectedRowInComponent:0];
    }
    [delegate readyViewForAlignments];
    if (calledByPicker)
        [delegate readyViewCalledBySegPickerView:index];
    [self hide];
}
- (IBAction)showCovProfilePressed:(id)sender {
    BOOL calledByPicker = [sender isEqual:showCoverageProfileSegmentPckrBtn];
    int index = 0;
    if (calledByPicker) {
        UIPickerView *segmentPckr;
        for (UIPickerView *picker in [segSelectView subviews]) {
            segmentPckr = picker;
            break;
        }
        index = (int)[segmentPckr selectedRowInComponent:0];
    }
    [delegate readyViewForCovProfile];
    if (calledByPicker)
        [delegate readyViewCalledBySegPickerView:index];
    [self hide];
}

- (IBAction)donePressed:(id)sender {
    self.hidden = YES;
}

- (void)importantMutationAtPosPressedInImptMutDispView:(int)pos {
    [delegate scrollToPos:pos];
    [self hide];
}

- (void)hide {
    self.hidden = YES;
}
@end
