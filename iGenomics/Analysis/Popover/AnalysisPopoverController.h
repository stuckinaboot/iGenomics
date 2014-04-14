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

#define kAnalysisPopoverW 150
#define kAnalysisPopoverH 250

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
}
@property (nonatomic, retain) IBOutlet UILabel *posLbl;
@property (nonatomic, retain) IBOutlet UILabel *heteroLbl;
@property (nonatomic) NSString *heteroStr;
@property (nonatomic) int position;
- (void)updateLbls;
@end
