//
//  HamburgerMenuController.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 8/8/14.
//
//

#import <UIKit/UIKit.h>

#define kHamburgerMenuSlideOutDuration 0.5

@interface HamburgerMenuController : NSObject {
    UIPanGestureRecognizer *panRecognizer;
    UIViewController *mainController;
    UIViewController *sideController;
}
@property (nonatomic, readonly) BOOL menuOpen;
- (IBAction)panOccurred:(id)sender;
- (id)initWithCentralController:(UIViewController*)centralController andSlideOutController:(UIViewController*)slideOutController;
- (void)openHamburgerMenu;
- (void)closeHamburgerMenu;
@end
