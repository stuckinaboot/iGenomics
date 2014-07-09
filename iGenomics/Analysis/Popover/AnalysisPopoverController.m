//
//  AnalysisPopoverController.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/19/13.
//
//

#import "AnalysisPopoverController.h"

@implementation AnalysisPopoverController

@synthesize posLbl, heteroLbl, heteroStr, segment, position, displayedPos;

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
    segmentLbl.text = [NSString stringWithFormat:kAnalysisPopoverSegmentLblTxt,segment];
    heteroLbl.text = heteroStr;
    posLbl.text = [NSString stringWithFormat:kAnalysisPopoverPosLblTxt,displayedPos];
    aLbl.text = [NSString stringWithFormat:kPopoverACGTLblTxt,'A',posOccArray[0][position]];
    cLbl.text = [NSString stringWithFormat:kPopoverACGTLblTxt,'C',posOccArray[1][position]];
    gLbl.text = [NSString stringWithFormat:kPopoverACGTLblTxt,'G',posOccArray[2][position]];
    tLbl.text = [NSString stringWithFormat:kPopoverACGTLblTxt,'T',posOccArray[3][position]];
    delLbl.text = [NSString stringWithFormat:kPopoverACGTLblTxt,'-',posOccArray[4][position]];
    insLbl.text = [NSString stringWithFormat:kPopoverACGTLblTxt,'+',posOccArray[5][position]];
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
