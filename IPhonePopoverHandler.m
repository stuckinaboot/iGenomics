//
//  IPhonePopoverHandler.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 3/29/14.
//
//

#import "IPhonePopoverHandler.h"

@implementation IPhonePopoverHandler

- (void)viewDidLoad {
    UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapOccurred:)];
    [recognizer setNumberOfTapsRequired:kIPhonePopoverMinTapsRequired];
    [self.view addGestureRecognizer:recognizer];
}

- (IBAction)doubleTapOccurred:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
