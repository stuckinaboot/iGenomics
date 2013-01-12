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
    
    filePickerController = [[FilePickerController alloc] init];
    [filePickerController setUpDefaultFiles];
    /*
    
    bwt = [[BWT alloc] init];
    [bwt setUpForRefFile:@"New.Ecoli.5k" fileExt:@"txt"];
    [bwt matchReedsFile:@"new.reads" fileExt:@"txt" withNumOfSubs:2];
    
    [bwt.bwtMutationFilter buildOccTableWithUnravStr:bwt.originalString];
    [bwt.bwtMutationFilter findMutationsWithOriginalSeq:bwt.originalString];
    [bwt.bwtMutationFilter filterMutationsForDetails];
    
    */
    
    if (kPrintIndevelopmentVars>0) {
    }
    
    [super viewDidLoad];
}

- (IBAction)showFilePickerPressed:(id)sender {
    [self presentModalViewController:filePickerController animated:YES];
}

- (IBAction)showAboutPressed:(id)sender {}

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


@end
