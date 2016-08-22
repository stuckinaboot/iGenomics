//
//  ViewController.m
//  LabProject5
//
//  Created by Stuckinaboot Inc. on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFileIntoFilePicker:) name:kFilePickerControllerNotificationExternalFileLoadedKey object:nil];
    
    filePickerController = [[FilePickerController alloc] init];
    abtSectController = [[AboutSectionViewController alloc] init];
}

//- (void)viewDidAppear:(BOOL)animated {
//    [self viewDidAppear:animated];
//    isPresented = TRUE;
//}
//
//- (void)viewDidDisappear:(BOOL)animated {
//    [self viewDidDisappear:animated];
//    isPresented = FALSE;
//}

- (void)loadFileIntoFilePicker:(NSNotification*)notification {
//    [self showFilePickerPressed:nil];
    if (self.isViewLoaded && self.view.window) {
        [self presentViewController:filePickerController animated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kFilePickerControllerNotificationExternalFileLoadedKey object:nil userInfo:notification.userInfo];
        }];
    }
}

- (IBAction)showFilePickerPressed:(id)sender {
    [filePickerController resetScrollViewOffset];
    [self presentViewController:filePickerController animated:YES completion:nil];
}

- (IBAction)showAboutPressed:(id)sender {
    [self presentViewController:abtSectController animated:YES completion:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (![GlobalVars isIpad])
        return UIInterfaceOrientationMaskPortrait;
    else
        return UIInterfaceOrientationMaskLandscape;
}


@end
