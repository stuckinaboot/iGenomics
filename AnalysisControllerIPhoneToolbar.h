//
//  AnalysisControllerIPhoneToolbar.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 3/29/14.
//
//

#import <UIKit/UIKit.h>
#import "GlobalVars.h"

@interface AnalysisControllerIPhoneToolbar : UIView {

}
- (IBAction)donePressed:(id)sender;
- (void)addDoneBtnForTxtFields:(NSArray*)txtFields;
@end
