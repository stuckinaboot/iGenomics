//
//  AnalysisPopoverController.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/19/13.
//
//

#import <UIKit/UIKit.h>

#define kAnalysisPopoverW 150
#define kAnalysisPopoverH 250

@interface AnalysisPopoverController : UIViewController {
    IBOutlet UILabel *posLbl;
    IBOutlet UILabel *heteroLbl;
}
@property (nonatomic, retain) IBOutlet UILabel *posLbl;
@property (nonatomic, retain) IBOutlet UILabel *heteroLbl;
@end
