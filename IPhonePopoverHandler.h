//
//  IPhonePopoverHandler.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 3/29/14.
//
//

#import <Foundation/Foundation.h>
#import "GlobalVars.h"

#define kIPhonePopoverMinTapsRequired 2
#define kIPhonePopoverNavBarHeight 44
#define kIPhonePopoverNavBarLandscapeHeight 32

@interface IPhonePopoverHandler : UIViewController {
    IBOutlet UIView *modifiableView;
    IBOutlet UINavigationBar *navBar;
    NSString *navBarTitle;
    
    UIViewController *mainController;
}
- (void)setMainViewController:(UIViewController *)controller andTitle:(NSString*)title;
- (IBAction)doubleTapOccurred:(id)sender;
@end