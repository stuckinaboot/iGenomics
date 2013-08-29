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

- (void)setUpWithMutationsArr:(NSArray *)arr {
    mutationsArray = arr;
    [mutationsTBView reloadData];
    [delegate mutationsPopoverDidFinishUpdating];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row > 0) {
        MutationInfo *info = [mutationsArray objectAtIndex:indexPath.row-1];
        int pos = info.pos;//-1 because first row shows total # of muts
        [cell.textLabel setText:[NSString stringWithFormat:@"Pos: %i %s",pos+1, [MutationInfo createMutStrFromOriginalChar:info.refChar andFoundChars:info.foundChars]]];//+1 because the first pos is considered 0
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;//Show the little arrow
    }
    else {
        //Show total number of mutations
        [cell.textLabel setText:[NSString stringWithFormat:@"Total Mutations: %i",[mutationsArray count]]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row>0) {//didn't select "Total Mutations" row
        MutationInfo *info = [mutationsArray objectAtIndex:indexPath.row-1];//-1 because first row shows total # of muts
        [delegate mutationAtPosPressedInPopover:info.pos+1];//+1 because it starts at 0
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
