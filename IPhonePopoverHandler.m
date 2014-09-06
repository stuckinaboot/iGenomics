//
//  IPhonePopoverHandler.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 3/29/14.
//
//

#import "IPhonePopoverHandler.h"

@implementation IPhonePopoverHandler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    modifiableView.frame = CGRectMake(0, navBar.frame.size.height, modifiableView.frame.size.width, modifiableView.frame.size.height);
    
    mainController.view.frame = CGRectMake(0, 0, modifiableView.frame.size.width, modifiableView.frame.size.height);
    
    navBar.topItem.title = navBarTitle;

    [modifiableView addSubview:mainController.view];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapOccurred:)];
    recognizer.numberOfTapsRequired = kIPhonePopoverMinTapsRequired;
    [modifiableView addGestureRecognizer:recognizer];
}

- (void)viewDidLayoutSubviews {
    if (([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft) ||
        ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight)) {
        modifiableView.frame = CGRectMake(0, navBar.frame.size.height, modifiableView.frame.size.width, modifiableView.frame.size.height);
        mainController.view.frame = CGRectMake(0, 0, modifiableView.frame.size.width, modifiableView.frame.size.height);
    }
    [modifiableView layoutSubviews];
}

- (void)setMainViewController:(UIViewController *)controller andTitle:(NSString *)title {
    mainController = controller;
    navBarTitle = title;
}

- (IBAction)doubleTapOccurred:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSUInteger)supportedInterfaceOrientations {
    return mainController.supportedInterfaceOrientations;
}

@end