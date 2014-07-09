//
//  AnalysisPopoverController.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/19/13.
//
//

#import <UIKit/UIKit.h>
#import "IPhonePopoverHandler.h"
#import "CopyLabel.h"
#import "BWT.h"


#define kAnalysisPopoverPosLblTxt @"Position: %i"
#define kAnalysisPopoverSegmentLblTxt @"Segment: %@"

#define kPopoverACGTLblTxt @"%c: %i"

@interface AnalysisPopoverController : IPhonePopoverHandler {
    IBOutlet CopyLabel *posLbl;
    IBOutlet CopyLabel *heteroLbl;
    IBOutlet CopyLabel *aLbl;
    IBOutlet CopyLabel *cLbl;
    IBOutlet CopyLabel *gLbl;
    IBOutlet CopyLabel *tLbl;
    IBOutlet CopyLabel *delLbl;
    IBOutlet CopyLabel *insLbl;
    IBOutlet CopyLabel *segmentLbl;
}
@property (nonatomic) int displayedPos;//The displayed position relative to the start of the closest segment start
@property (nonatomic, retain) IBOutlet CopyLabel *posLbl;
@property (nonatomic, retain) IBOutlet CopyLabel *heteroLbl;
@property (nonatomic) NSString *heteroStr, *segment;
@property (nonatomic) int position;//The actual position relative to the start of the genome
- (void)updateLbls;
@end
