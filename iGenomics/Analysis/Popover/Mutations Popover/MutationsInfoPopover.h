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

#define kMutationsPopoverNoMutationsAlertMsg @"No mutations found"

#define kMutationsPopoverMutationLoadingAlertMsg @"Please wait for mutation identification to finish"

#define kMutationsInfoPopoverTitleInIPhonePopoverHandler @"Mutations List"

@protocol MutationsInfoPopoverDelegate <NSObject>
- (void)mutationAtPosPressedInPopover:(int)pos;
- (void)mutationsPopoverDidFinishUpdating;
@end

@interface MutationsInfoPopover : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *mutationsTBView;
    
    NSMutableArray *mutationsArray;
    NSMutableArray *numOfRowsInSectionArr;
    
    id delegate;
}
@property (nonatomic) id <MutationsInfoPopoverDelegate> delegate;
- (void)setUpWithMutationsArr:(NSArray *)arr andCumulativeGenomeLenArr:(NSArray *)lenArr andGenomeFileNameArr:(NSArray*)nameArr;
- (int)indexInMutationsArrayForIndexPath:(NSIndexPath*)indexPath;
@end
