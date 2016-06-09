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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFileIntoFilePicker:) name:kFilePickerControllerNotificationExternalFileLoadedKey object:self];
    
    filePickerController = [[FilePickerController alloc] init];
    abtSectController = [[AboutSectionViewController alloc] init];
}

- (void)loadFileIntoFilePicker:(NSNotification*)notification {
    NSLog(@"occurred");
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (![GlobalVars isIpad])
        return UIInterfaceOrientationMaskPortrait;
    else
        return UIInterfaceOrientationMaskLandscape;
}


@end
