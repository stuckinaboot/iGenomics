//
//  MutationsInfoPopover.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 2/3/13.
//
//

#import <UIKit/UIKit.h>
#import "MutationInfo.h"
#import "IPhonePopoverHandler.h"
#import "GlobalVars.h"
#import "AnalysisControllerIPhoneToolbar.h"

#define kIsHeteroStr "(Hetero)"
#define kIsNotHeteroStr ""

@protocol MutationsInfoPopoverDelegate <NSObject>
- (void)mutationAtPosPressedInPopover:(int)pos;
- (void)mutationsPopoverDidFinishUpdating;
@end

@interface MutationsInfoPopover : IPhonePopoverHandler <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *mutationsTBView;
    
    NSArray *mutationsArray;
    
    id delegate;
}
@property (nonatomic) id <MutationsInfoPopoverDelegate> delegate;
- (void)setUpWithMutationsArr:(NSArray*)arr;
@end
