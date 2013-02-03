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
        int pos = [[mutationsArray objectAtIndex:indexPath.row-1] intValue];//-1 because first row shows total # of muts
        [cell.textLabel setText:[NSString stringWithFormat:@"Pos: %i",pos]];
        
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
    if (indexPath.row>0)//didn't select "Total Mutations" row
        [delegate mutationAtPosPressedInPopover:[[mutationsArray objectAtIndex:indexPath.row-1] intValue]];//-1 because first row shows total # of muts
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
