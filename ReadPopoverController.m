//
//  ReadPopoverController.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 7/18/14.
//
//

#import "ReadPopoverController.h"

@interface ReadPopoverController ()

@end

@implementation ReadPopoverController

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
    
    readNameLbl.text = [NSString stringWithFormat:kReadPopoverReadNameLblTxt,read.readName];
    gappedALbl.text = [NSString stringWithFormat:kReadPopoverGappedALblTxt,read.gappedA];
    gappedBLbl.text = [NSString stringWithFormat:kReadPopoverGappedBLblTxt,read.gappedB];
    edLbl.text = [NSString stringWithFormat:kReadPopoverEDLblTxt,read.distance];
    foRevLbl.text = [NSString stringWithFormat:kReadPopoverFoRevLblTxt,(!read.isRev) ? kReadPopoverFoRevLblForwardTxt : kReadPopoverFoRevLblReverseTxt];
    // Do any additional setup after loading the view from its nib.
}

- (void)setUpWithRead:(ED_Info *)r {
    read = r;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
