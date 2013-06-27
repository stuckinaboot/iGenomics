//
//  InsertionsPopoverController.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/27/13.
//
//

#import "InsertionsPopoverController.h"

@interface InsertionsPopoverController ()

@end

@implementation InsertionsPopoverController

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

- (void)setInsArr:(NSArray *)array forPos:(int)pos {
    arr = [[NSMutableArray alloc] init];
    
    //Find the insertions at that position
    for (int i = 0; i<array.count; i++) {
        BWT_Matcher_InsertionDeletion_InsertionHolder *info = [array objectAtIndex:i];
        
        if (info.pos == pos) {
            [arr addObject:info];
        }
    }
}

#pragma TABLEVIEW DELEGATE

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    BWT_Matcher_InsertionDeletion_InsertionHolder *info = [arr objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:[NSString stringWithFormat:@"Pos: %i, Seq: %s, Count: %i",info.pos+1,info.seq,info.count]];//Not positive about gappedA, info.pos + 1 because position 0 is considered 1
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
