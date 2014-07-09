//
//  MutationsInfoPopover.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 2/3/13.
//
//

#import "MutationsInfoPopover.h"

@interface MutationsInfoPopover ()

@end

@implementation MutationsInfoPopover

@synthesize delegate;

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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)setUpWithMutationsArr:(NSArray *)arr andCumulativeGenomeLenArr:(NSArray *)lenArr andGenomeFileNameArr:(NSArray*)nameArr {
    mutationsArray = (NSMutableArray*)arr;
    [mutationsTBView reloadData];
    [delegate mutationsPopoverDidFinishUpdating];
    if ([lenArr count] > 1) {
        int index = 0;
        for (int x = 0; x < [mutationsArray count]; x++) {
            MutationInfo *info = [mutationsArray objectAtIndex:x];
            for (int i = [lenArr count]-1; i >= 0; i--) {
                int len = [[lenArr objectAtIndex:i] intValue];
                if (info.pos < len)
                    info.genomeName = [nameArr objectAtIndex:i];
                else {
                    index = i+1;
                    break;
                }
            }
            if (index > 0)
                info.displayedPos -= [[lenArr objectAtIndex:index-1] intValue];
            [mutationsArray setObject:info atIndexedSubscript:x];
        }
    }
}

#pragma TableView Delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [mutationsArray count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row > 0) {
        MutationInfo *info = [mutationsArray objectAtIndex:indexPath.row-1];
        int pos = info.displayedPos;//-1 because first row shows total # of muts
        [cell.textLabel setText:[NSString stringWithFormat:kMutationFormat,pos+1, [MutationInfo createMutStrFromOriginalChar:info.refChar andFoundChars:info.foundChars], [MutationInfo createMutCovStrFromFoundChars:info.foundChars andPos:info.pos]]];//+1 because the first pos is considered 0
        [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
        [cell.detailTextLabel setText:info.genomeName];
        [cell.detailTextLabel setAdjustsFontSizeToFitWidth:YES];
        cell.accessoryType = UITableViewCellAccessoryDetailButton;//Show the little arrow
    }
    else {
        //Show total number of mutations
        [cell.textLabel setText:[NSString stringWithFormat:kMutationTotalFormat,[mutationsArray count]]];
        [cell.detailTextLabel setText:@""];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row>0) {//didn't select "Total Mutations" row
//        MutationInfo *info = [mutationsArray objectAtIndex:indexPath.row-1];//-1 because first row shows total # of muts
//        [delegate mutationAtPosPressedInPopover:info.pos+1];//+1 because it starts at 0
//    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if (![GlobalVars isIpad])
//        [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row>0) {//didn't select "Total Mutations" row
        MutationInfo *info = [mutationsArray objectAtIndex:indexPath.row-1];//-1 because first row shows total # of muts
        [delegate mutationAtPosPressedInPopover:info.pos+1];//+1 because it starts at 0
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (![GlobalVars isIpad])
        [self dismissViewControllerAnimated:YES completion:nil];
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
