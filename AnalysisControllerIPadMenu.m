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
    genomeInteractionElementsArr = [NSArray arrayWithObjects:kAnalysisControllerIPadTblElementSearch, kAnalysisControllerIPadTblElementSegmentPicker, nil];
    genomeInteractionElementContentsArr = [NSArray arrayWithObjects:elementSearchView, elementSegmentPckrView, nil];
    
    genomeInformationElementsArr = [NSArray arrayWithObjects:kAnalysisControllerIPadTblElementCovHistogram, kAnalysisControllerIPadTblElementViewMuts, kAnalysisControllerIPadTblElementViewImptMuts, nil];
    genomeInformationElementContentsArr = [NSArray arrayWithObjects:covHistogram, mutInfoPopover, imptMutsDisplayView, nil];
    
    settingsElementsArr = [NSArray arrayWithObjects:kAnalysisControllerIPadTblElementSettings, nil];
    settingsElementContentsArr = [NSArray arrayWithObjects:elementSettingsView, nil];
    
    exportElementsArr = [NSArray arrayWithObjects:kAnalysisControllerIPadTblElementExport, nil];
    SEL fileExportSelector = @selector(displayExportActionSheetOutOfCell:);
    exportElementContentsArr = [NSArray arrayWithObjects:NSStringFromSelector(fileExportSelector), nil];
    
    sectionNameArr = [NSArray arrayWithObjects:kAnalysisControllerIPadTblSectionGenomeInteraction, kAnalysisControllerIPadTblSectionInformation, kAnalysisControllerIPadTblSectionExport,kAnalysisControllerIPadTblSectionSettings, nil];
    
    completeSecElArr = [NSArray arrayWithObjects:genomeInteractionElementsArr, genomeInformationElementsArr, exportElementsArr, settingsElementsArr, nil];
    
    completeSecElContentsArr = [NSArray arrayWithObjects:genomeInteractionElementContentsArr, genomeInformationElementContentsArr, exportElementContentsArr, settingsElementContentsArr, nil];
//    tblElementsArr = [NSArray arrayWithObjects:kAnalysisControllerIPadTblElementCovHistogram,kAnalysisControllerIPadTblElementSearch, kAnalysisControllerIPadTblElementSegmentPicker, kAnalysisControllerIPadTblElementMutSupport,
//        kAnalysisControllerIPadTblElementExport, nil];
    [super viewDidLoad];
    tblView.backgroundColor = [UIColor clearColor];
    tblView.tableFooterView = [UIView new];
    // Do any additional setup after loading the view from its nib.
}

- (void)setCoverageHistogram:(CoverageHistogram *)histo {
    if ([histo isEqual:covHistogram])
        return;
    covHistogram = histo;
    genomeInformationElementContentsArr = [NSArray arrayWithObjects:covHistogram, mutInfoPopover, imptMutsDisplayView, nil];
    [self updateCompleSecElContentsArr];
}

- (void)setFileExporter:(id)exporter {
    fileExporter = exporter;
}

- (void)setMutationsInfoPopover:(MutationsInfoPopover*)m {
    if ([mutInfoPopover isEqual:m])
        return;
    mutInfoPopover = m;
    genomeInformationElementContentsArr = [NSArray arrayWithObjects:covHistogram, mutInfoPopover, imptMutsDisplayView, nil];
    [self updateCompleSecElContentsArr];
}

- (void)setImptMutationsView:(ImportantMutationsDisplayView*)i {
    if ([imptMutsDisplayView isEqual:i])
        return;
    imptMutsDisplayView = i;
    genomeInformationElementContentsArr = [NSArray arrayWithObjects:covHistogram, mutInfoPopover, imptMutsDisplayView, nil];
    [self updateCompleSecElContentsArr];
}

- (void)updateCompleSecElContentsArr {
    completeSecElContentsArr = [NSArray arrayWithObjects:genomeInteractionElementContentsArr, genomeInformationElementContentsArr, exportElementContentsArr, settingsElementContentsArr, nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sectionNameArr count];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [sectionNameArr objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [(NSArray*)[completeSecElArr objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.backgroundColor = [UIColor colorWithWhite:1.0f alpha:kAnalysisControllerIPadTblCellAlpha];
    cell.textLabel.text = [(NSArray*)[completeSecElArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (popoverController.isPopoverVisible)
        [popoverController dismissPopoverAnimated:YES];
    
    UIViewController *controller;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    id object = [[(NSArray*)completeSecElContentsArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[UIViewController class]])
        controller = (UIViewController*)object;
    else if ([object isKindOfClass:[UIView class]]) {
        UIView *v = (UIView*)object;
        controller = [[UIViewController alloc] init];
        controller.view.frame = v.frame;
        [controller.view addSubview:v];
    }
    else {//Object is a selector
        SEL method = NSSelectorFromString((NSString*)object);
        [self performSelector:method withObject:cell];
        return;
    }
    [self displayViewController:controller outOfCell:cell];
}

- (void)displayViewController:(UIViewController *)controller outOfCell:(UITableViewCell *)cell {
    controller.preferredContentSize = controller.view.bounds.size;
    
    popoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
    
    CGRect presentingRect = cell.frame;
    presentingRect = CGRectMake(presentingRect.origin.x, presentingRect.origin.y+tblView.frame.origin.y, presentingRect.size.width, presentingRect.size.height);
    
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

- (void)displayExportActionSheetOutOfCell:(UITableViewCell *)cell {
    [fileExporter displayExportOptionsWithSender:cell];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
