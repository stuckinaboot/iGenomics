//
//  ImportantMutationsDisplayView.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 7/22/14.
//
//

#import <UIKit/UIKit.h>
#import "ImportantMutationInfo.h"
#import "DNAColors.h"

#define kImportantMutationsDisplayViewNibName @"ImportantMutationsDisplayView"

#define kImportantMutationInfoFormat @"Pos: %i Ref: %c Mut: %s %i"
#define kImportantMutationsInfoMatchIconSizeFactor 0.5 //Is multiplied by the table view cell height

#define kImportationMutationDisplayViewNoMutationsListed @"No important mutation file loaded"

@class MutationsInfoPopover;

@protocol ImportantMutationsDisplayViewDelegate <NSObject>
- (void)importantMutationAtPosPressedInImptMutDispView:(int)pos;
@end
@interface ImportantMutationsDisplayView : UIView <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tblView;
    NSMutableArray *numOfRowsInSectionArr;
    DNAColors *dnaColors;
    NSArray *mutationsArray;
}
@property (nonatomic) id <ImportantMutationsDisplayViewDelegate> delegate;
- (IBAction)cellAccessoryBtnTapped:(id)sender forEvent:(UIEvent*)event;
- (void)setUpWithMutationsArray:(NSArray*)arr;
- (int)indexInMutationsArrayForIndexPath:(NSIndexPath*)indexPath;
@end
