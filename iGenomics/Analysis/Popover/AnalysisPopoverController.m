//
//  AnalysisPopoverController.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/19/13.
//
//

#import "AnalysisPopoverController.h"

@implementation AnalysisPopoverController

@synthesize posLbl, heteroLbl, heteroStr, segment, position, displayedPos;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [self updateLbls];
}

- (void)viewWillAppear:(BOOL)animated {
    insertionsTblView.hidden = (insertionsArray == nil || insertionsArray == NULL);
}

- (void)setInsertionsArray:(NSArray *)array {
    insertionsArray = [[NSMutableArray alloc] init];
    
    //Find the insertions at that position
    for (int i = 0; i<array.count; i++) {
        BWT_Matcher_InsertionDeletion_InsertionHolder *info = [array objectAtIndex:i];
        
        if (info.pos == position) {
            [insertionsArray addObject:info];
        }
    }
    
    insertionsTblView.hidden = (insertionsArray == nil || insertionsArray == NULL);
}

#pragma TABLEVIEW DELEGATE

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [insertionsArray count];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Insertion List";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    BWT_Matcher_InsertionDeletion_InsertionHolder *info = [insertionsArray objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:[NSString stringWithFormat:kAnalysisPopoverInsertionInfoTxt,info.seq,info.count]];//Displayed Pos bc the info.pos is not relative to each segment and the insertion listed here occurs at the position that was clicked, so just display that position
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)updateLbls {
    segmentLbl.text = [NSString stringWithFormat:kAnalysisPopoverSegmentLblTxt,segment];
    heteroLbl.text = heteroStr;
    posLbl.text = [NSString stringWithFormat:kAnalysisPopoverPosLblTxt,displayedPos];
    aLbl.text = [NSString stringWithFormat:kPopoverACGTLblTxt,'A',posOccArray[0][position]];
    cLbl.text = [NSString stringWithFormat:kPopoverACGTLblTxt,'C',posOccArray[1][position]];
    gLbl.text = [NSString stringWithFormat:kPopoverACGTLblTxt,'G',posOccArray[2][position]];
    tLbl.text = [NSString stringWithFormat:kPopoverACGTLblTxt,'T',posOccArray[3][position]];
    delLbl.text = [NSString stringWithFormat:kPopoverACGTLblTxt,'-',posOccArray[4][position]];
    insLbl.text = [NSString stringWithFormat:kPopoverACGTLblTxt,'+',posOccArray[5][position]];
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
