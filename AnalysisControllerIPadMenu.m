//
//  AnalysisControllerIPadMenu.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 8/8/14.
//
//

#import "AnalysisControllerIPadMenu.h"

@interface AnalysisControllerIPadMenu ()

@end

@implementation AnalysisControllerIPadMenu

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    tblElementsArr = [NSArray arrayWithObjects:kAnalysisControllerIPadTblElementCovHistogram,kAnalysisControllerIPadTblElementSearch, kAnalysisControllerIPadTblElementSegmentPicker, kAnalysisControllerIPadTblElementMutSupport, nil];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)setCoverageHistogram:(CoverageHistogram *)histo {
    covHistogram = histo;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tblElementsArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [tblElementsArr objectAtIndex:indexPath.row];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (popoverController.isPopoverVisible)
        [popoverController dismissPopoverAnimated:YES];
    
    UIView *v;
    UIViewController *controller = [[UIViewController alloc] init];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.textLabel.text isEqual:kAnalysisControllerIPadTblElementSearch])
        v = elementSearchView;
    else if ([cell.textLabel.text isEqual:kAnalysisControllerIPadTblElementSegmentPicker])
        v = elementSegmentPckrView;
    else if ([cell.textLabel.text isEqual:kAnalysisControllerIPadTblElementMutSupport])
        v = elementMutSprtView;
    else if ([cell.textLabel.text isEqual:kAnalysisControllerIPadTblElementCovHistogram]) {
        [self displayCovHistogramOutOfCell:cell];
        return;
    }
    
    controller.preferredContentSize = v.bounds.size;
    [controller.view addSubview:v];
    
    CGRect presentingRect = cell.frame;
    presentingRect = CGRectMake(presentingRect.origin.x, presentingRect.origin.y+tableView.frame.origin.y, presentingRect.size.width, presentingRect.size.height);
    
    popoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
    [popoverController presentPopoverFromRect:presentingRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

- (void)displayCovHistogramOutOfCell:(UITableViewCell *)cell {
    if (!covHistogram) {
        [GlobalVars displayiGenomicsAlertWithMsg:kCoverageHistogramNoReadsAlignedAlertMsg];
        return;
    }
    if (popoverController.isPopoverVisible)
            [popoverController dismissPopoverAnimated:YES];
    covHistogram.preferredContentSize = covHistogram.view.bounds.size;
    popoverController = [[UIPopoverController alloc] initWithContentViewController:covHistogram];
    
    CGRect presentingRect = cell.frame;
    presentingRect = CGRectMake(presentingRect.origin.x, presentingRect.origin.y+tblView.frame.origin.y, presentingRect.size.width, presentingRect.size.height);
    
    [popoverController presentPopoverFromRect:presentingRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
