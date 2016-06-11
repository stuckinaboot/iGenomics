//
//  PreSequencing.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 12/1/12.
//
//

#import "PreSequencing.h"

@interface PreSequencing ()

@end

@implementation PreSequencing

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [fileChooser setDelegate:self];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
- (IBAction)chooseReads:(id)sender {
    [fileChooser loadForReads:YES];
    [self presentModalViewController:fileChooser animated:YES];
}
- (IBAction)chooseSeqs:(id)sender {
    [fileChooser loadForReads:NO];
    [self presentModalViewController:fileChooser animated:YES];
}
- (IBAction)backPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
- (IBAction)donePressed:(id)sender {
    if (readsPicked && seqPicked) {
    }
}

//FileChooser Delegate
- (void)fileChosen:(NSString *)fileContents {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
