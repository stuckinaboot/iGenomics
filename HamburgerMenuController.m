//
//  HamburgerMenuController.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 8/8/14.
//
//

#import "HamburgerMenuController.h"

@interface HamburgerMenuController ()

@end

@implementation HamburgerMenuController

@synthesize menuOpen;

- (id)initWithCentralController:(UIViewController *)centralController andSlideOutController:(UIViewController *)slideOutController {
    self = [super init];
    mainController = centralController;
    sideController = slideOutController;
    
    panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panOccurred:)];
    [mainController.view addGestureRecognizer:panRecognizer];
    
    [mainController addChildViewController:sideController];
    sideController.view.frame = CGRectMake(0, 0, sideController.view.frame.size.width, sideController.view.frame.size.height);
    sideController.view.hidden = YES;
    [mainController.view addSubview:sideController.view];
    [mainController.view sendSubviewToBack:sideController.view];
    [sideController didMoveToParentViewController:mainController];
    return self;
}

- (IBAction)panOccurred:(id)sender {
    UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer*)sender;
    CGPoint pt = [recognizer translationInView:mainController.view];
    if (menuOpen) {
        CGRect rect = mainController.view.bounds;
        if (rect.origin.x-pt.x >= -sideController.view.bounds.size.width && rect.origin.x-pt.x <= 0)
        mainController.view.bounds = CGRectMake(rect.origin.x-pt.x, rect.origin.y, rect.size.width, rect.size.height);
    
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            if (rect.origin.x > -sideController.view.bounds.size.width && pt.x < 0) {
                [self closeHamburgerMenu];
            }
            else {
                [self openHamburgerMenu];
            }
        }
    }
}

- (void)openHamburgerMenu {
    CGRect bounds = mainController.view.bounds;
    float width = sideController.view.bounds.size.width;
    sideController.view.hidden = NO;
    [UIView animateWithDuration:kHamburgerMenuSlideOutDuration animations:^{
        mainController.view.bounds = CGRectMake(-width, bounds.origin.y, bounds.size.width, bounds.size.height);
        sideController.view.center = CGPointMake(-width/2, sideController.view.center.y);
    } completion:^(BOOL finished){
        menuOpen = YES;
    }];
}

- (void)closeHamburgerMenu {
    CGRect bounds = mainController.view.bounds;
    [UIView animateWithDuration:kHamburgerMenuSlideOutDuration animations:^{
        mainController.view.bounds = CGRectMake(0, bounds.origin.y, bounds.size.width, bounds.size.height);
    } completion:^(BOOL finished){
        sideController.view.hidden = YES;
        menuOpen = NO;
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
