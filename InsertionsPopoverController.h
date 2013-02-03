//
//  InsertionsPopoverController.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/27/13.
//
//

#import <UIKit/UIKit.h>
#import "BWT_Matcher_InsertionDeletion_InsertionHolder.h"

#define kInsPopoverW 450
#define kInsPopoverH 250

@interface InsertionsPopoverController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *insTBView;
    
    NSMutableArray *arr;
}
- (void)setInsArr:(NSArray*)array forPos:(int)pos;
@end
