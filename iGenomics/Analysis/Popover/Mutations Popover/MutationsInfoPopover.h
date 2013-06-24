//
//  MutationsInfoPopover.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 2/3/13.
//
//

#import <UIKit/UIKit.h>
#import "MutationInfo.h"

#define kIsHeteroStr "(Hetero)"
#define kIsNotHeteroStr ""

@protocol MutationsInfoPopoverDelegate <NSObject>
- (void)mutationAtPosPressedInPopover:(int)pos;
@end

@interface MutationsInfoPopover : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *mutationsTBView;
    
    NSArray *mutationsArray;
    
    id delegate;
}
@property (nonatomic) id <MutationsInfoPopoverDelegate> delegate;
- (void)setUpWithMutationsArr:(NSArray*)arr;
@end
