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
#import "InsertionsPopoverController.h"


#define kAnalysisPopoverPosLblTxt @"Position: %i"
#define kAnalysisPopoverSegmentLblTxt @"Segment: %@"

#define kAnalysisPopoverInsertionInfoTxt @"Seq: %s, Count: %i"

#define kPopoverACGTLblTxt @"%c: %i"

#define kAnalysisPopoverTitleInIPhonePopoverHandler @"Position Information"

@interface AnalysisPopoverController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet CopyLabel *posLbl;
    IBOutlet CopyLabel *heteroLbl;
    IBOutlet CopyLabel *aLbl;
    IBOutlet CopyLabel *cLbl;
    IBOutlet CopyLabel *gLbl;
    IBOutlet CopyLabel *tLbl;
    IBOutlet CopyLabel *delLbl;
    IBOutlet CopyLabel *insLbl;
    IBOutlet CopyLabel *segmentLbl;
    
    
    IBOutlet UITableView *insertionsTblView;
    NSMutableArray *insertionsArray;
}
- (void)setInsertionsArray:(NSArray*)array;
@property (nonatomic) int displayedPos;//The displayed position relative to the start of the closest segment start
@property (nonatomic, retain) IBOutlet CopyLabel *posLbl;
@property (nonatomic, retain) IBOutlet CopyLabel *heteroLbl;
@property (nonatomic) NSString *heteroStr, *segment;
@property (nonatomic) int position;//The actual position relative to the start of the genome
- (void)updateLbls;
@end
