//
//  ParametersController.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/4/13.
//
//

#import "ParametersController.h"

@interface ParametersController ()

@end

@implementation ParametersController

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
    computingController = [[ComputingController alloc] init];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)passInSeq:(NSString*)mySeq andReads:(NSString*)myReads {
    seq = mySeq;
    reads = myReads;
}

- (IBAction)startSequencingPressed:(id)sender {
    [computingController setUpWithReads:reads andSeq:seq andParameters:NULL];
    [self presentModalViewController:computingController animated:YES];
}

- (IBAction)backPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
