//
//  AnalysisPopoverController.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/19/13.
//
//

#import "AnalysisPopoverController.h"

@implementation AnalysisPopoverController

@synthesize posLbl, heteroLbl, heteroStr, position;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [self updateLbls];
}

- (void)updateLbls {
    posLbl.text = [NSString stringWithFormat:kAnalysisPopoverPosLblTxt,position+1];//+1 so doesn't start at 0
    heteroLbl.text = heteroStr;
    posLbl.text = [NSString stringWithFormat:kAnalysisPopoverPosLblTxt,position];
    aLbl.text = [NSString stringWithFormat:kPopoverACGTLblTxt,'A',posOccArray[0][position-1]];
    cLbl.text = [NSString stringWithFormat:kPopoverACGTLblTxt,'C',posOccArray[1][position-1]];
    gLbl.text = [NSString stringWithFormat:kPopoverACGTLblTxt,'G',posOccArray[2][position-1]];
    tLbl.text = [NSString stringWithFormat:kPopoverACGTLblTxt,'T',posOccArray[3][position-1]];
    delLbl.text = [NSString stringWithFormat:kPopoverACGTLblTxt,'-',posOccArray[4][position-1]];
    insLbl.text = [NSString stringWithFormat:kPopoverACGTLblTxt,'+',posOccArray[5][position-1]];
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
