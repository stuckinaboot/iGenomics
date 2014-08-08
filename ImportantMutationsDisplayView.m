//
//  ImportantMutationsDisplayView.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 7/22/14.
//
//

#import "ImportantMutationsDisplayView.h"

@implementation ImportantMutationsDisplayView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setUpWithMutationsArray:(NSArray*)arr {
    mutationsArray = arr;
    dnaColors = [[DNAColors alloc] init];
    [dnaColors setUp];
    [self setUpNumOfRowsInSectionArr];
}

- (void)setUpNumOfRowsInSectionArr {
    if (!mutationsArray)
        return;
    
    numOfRowsInSectionArr = [[NSMutableArray alloc] init];
    int numOfRows = 0;
    for (int i = 0; i < [mutationsArray count]; i++) {
        if (i > 0) {
            MutationInfo *info1 = [mutationsArray objectAtIndex:i];
            MutationInfo *info2 = [mutationsArray objectAtIndex:i-1];
            
            numOfRows++;
            if (info1.indexInSegmentNameArr != info2.indexInSegmentNameArr) {
                [numOfRowsInSectionArr addObject:[NSNumber numberWithInt:numOfRows]];
                numOfRows = 0;
            }
        }
    }
    
    [numOfRowsInSectionArr addObject:[NSNumber numberWithInt:numOfRows+1]];//+1 includes the last row because the loop exits before that gets added
    [tblView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (!mutationsArray)
        return 1;
    return [numOfRowsInSectionArr count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!mutationsArray)
        return 1;
    return [[numOfRowsInSectionArr objectAtIndex:section] intValue];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:section];
    MutationInfo *info = [mutationsArray objectAtIndex:[self indexInMutationsArrayForIndexPath:index]];
    return info.genomeName;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!mutationsArray) {
        cell.textLabel.text = kImportationMutationDisplayViewNoMutationsListed;
        return cell;
    }
    
    // Set the data for this cell:
    ImportantMutationInfo *info = [mutationsArray objectAtIndex:[self indexInMutationsArrayForIndexPath:indexPath]];
    cell.textLabel.text = [NSString stringWithFormat:kImportantMutationInfoFormat, info.displayedPos, info.refChar, info.foundChars];
    cell.detailTextLabel.text = info.details;
//    cell.imageView.image = [UIImage imageNamed:@"flower.png"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, cell.bounds.size.height*kImportantMutationsInfoMatchIconSizeFactor, cell.bounds.size.height*kImportantMutationsInfoMatchIconSizeFactor);
    btn.showsTouchWhenHighlighted = YES;
    
    switch (info.matchType) {
        case kMatchTypeHeterozygousMutationImportant:
            btn.backgroundColor = [dnaColors.matchTypeHeterozygousMutationImportant UIColorObj];
            break;
        case kMatchTypeHomozygousMutationImportant:
            btn.backgroundColor = [dnaColors.matchTypeHomozygousMutationImportant UIColorObj];
            break;
        case kMatchTypeHeterozygousMutationNormal:
            btn.backgroundColor = [dnaColors.matchTypeHeterozygousMutationNormal UIColorObj];
            break;
        case kMatchTypeHomozygousMutationNormal:
            btn.backgroundColor = [dnaColors.matchTypeHomozygousMutationNormal UIColorObj];
            break;
        case kMatchTypeNoMutationImportant:
            btn.backgroundColor = [dnaColors.matchTypeNoMutation UIColorObj];
            break;
        case kMatchTypeNoAlignment:
            btn.backgroundColor = [dnaColors.matchTypeNoAlignment UIColorObj];
            break;
        default:
            break;
    }
    
    [btn addTarget:self action:@selector(cellAccessoryBtnTapped:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = btn;
    [cell addSubview:btn];

    return cell;
}

- (IBAction)cellAccessoryBtnTapped:(id)sender forEvent:(UIEvent*)event {
    MutationInfo *info = [mutationsArray objectAtIndex:[self indexInMutationsArrayForIndexPath:[tblView indexPathForRowAtPoint:[[[event touchesForView:sender] anyObject] locationInView:tblView]]]];
    [delegate importantMutationAtPosPressedInImptMutDispView:info.pos];
}

- (int)indexInMutationsArrayForIndexPath:(NSIndexPath *)indexPath {
    int totalRows = 0;
    for (int i = 0; i < indexPath.section; i++) {
        int currNumOfRows = [[numOfRowsInSectionArr objectAtIndex:i] intValue];
        totalRows += currNumOfRows;
    }
    totalRows += indexPath.row;
    return totalRows;
}

@end
