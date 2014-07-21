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

@interface ReadPopoverController : IPhonePopoverHandler {
    IBOutlet CopyLabel *readNameLbl;
    IBOutlet CopyLabel *gappedALbl;
    IBOutlet CopyLabel *gappedBLbl;
    IBOutlet CopyLabel *edLbl;
    IBOutlet CopyLabel *foRevLbl;
    
    ED_Info *read;
}
- (void)setUpWithRead:(ED_Info*)r;
@end
