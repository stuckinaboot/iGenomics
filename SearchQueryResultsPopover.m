//
//  SearchQueryResultsPopover.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 2/4/13.
//
//

#import "SearchQueryResultsPopover.h"

@interface SearchQueryResultsPopover ()

@end

@implementation SearchQueryResultsPopover

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

- (void)loadWithResults:(NSArray *)arr {
    foundResults = arr;
}

#pragma TableView Delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [foundResults count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row > 0) {
        int pos = [[foundResults objectAtIndex:indexPath.row-1] intValue];//-1 because first row shows total # of results
        [cell.textLabel setText:[NSString stringWithFormat:@"Pos: %i",pos+1]];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;//Show the little arrow
    }
    else {
        //Show total number of results
        [cell.textLabel setText:[NSString stringWithFormat:@"Total Results: %i",(int)[foundResults count]]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row>0)//didn't select "Total Results" row
        [delegate queryResultPosPicked:[[foundResults objectAtIndex:indexPath.row-1] intValue]];//-1 because first row shows total # of results
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
