//
//  FilePreviewPopoverController.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 2/25/14.
//
//

#import "FilePreviewPopoverController.h"

@interface FilePreviewPopoverController ()

@end

@implementation FilePreviewPopoverController

@synthesize txtView;

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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    txtView.text = txtViewContents;
    txtView.font = [UIFont fontWithName:kFilePreviewPopoverFontName size:kFilePreviewPopoverFontSize];
    if (![GlobalVars isIpad]) {
        self.view.frame = [[UIScreen mainScreen] bounds];
        txtView.frame = self.view.frame;
    }
}

- (void)updateTxtViewContents:(NSString *)contents {
    txtViewContents = [NSString stringWithString:contents];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
