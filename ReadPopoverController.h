//
//  ReadPopoverController.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 7/18/14.
//
//

#import <UIKit/UIKit.h>
#import "CopyLabel.h"
#import "ED_Info.h"
#import "IPhonePopoverHandler.h"
#import "GlobalVars.h"
#import "DNAColors.h"

#define kReadPopoverReadNameLblTxt @"Read Name: %s"
#define kReadPopoverGappedALblTxt @"Found:      %s"
#define kReadPopoverGappedBLblTxt @"Reference:  %s"
#define kReadPopoverEDLblTxt @"Edit Distance: %i"
#define kReadPopoverFoRevLblTxt @"Fo/Rev: %@"
#define kReadPopoverFoRevLblForwardTxt @"Forward"
#define kReadPopoverFoRevLblReverseTxt @"Reverse"

@interface ReadPopoverController : IPhonePopoverHandler {
    IBOutlet CopyLabel *readNameLbl;
    IBOutlet CopyLabel *gappedALbl;
    IBOutlet CopyLabel *gappedBLbl;
    IBOutlet CopyLabel *edLbl;
    IBOutlet CopyLabel *foRevLbl;
    
    IBOutlet UIScrollView *gappedLblsScrollView;
    
    ED_Info *read;
}
- (void)setUpWithRead:(ED_Info*)r;
- (void)highlightDifferencesInGappedLbls;
@end
