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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    readNameLbl.text = [NSString stringWithFormat:kReadPopoverReadNameLblTxt,read.readName];
    gappedALbl.text = [NSString stringWithFormat:kReadPopoverGappedALblTxt,read.gappedA];
    gappedBLbl.text = [NSString stringWithFormat:kReadPopoverGappedBLblTxt,read.gappedB];
    edLbl.text = [NSString stringWithFormat:kReadPopoverEDLblTxt,read.distance];
    foRevLbl.text = [NSString stringWithFormat:kReadPopoverFoRevLblTxt,(!read.isRev) ? kReadPopoverFoRevLblForwardTxt : kReadPopoverFoRevLblReverseTxt];
    
    UIFont *font = gappedALbl.font;
    CGSize gappedATxtSize = [gappedALbl.text sizeWithFont:font];
    
//    gappedLblsScrollView.contentSize = CGSizeMake(gappedATxtSize.width, gappedLblsScrollView.frame.size.height);
    // Do any additional setup after loading the view from its nib.
    
    gappedALbl.frame = CGRectMake(gappedALbl.frame.origin.x, gappedALbl.frame.origin.y, gappedATxtSize.width, gappedATxtSize.height);
    gappedBLbl.frame = CGRectMake(gappedBLbl.frame.origin.x, gappedBLbl.frame.origin.y, gappedATxtSize.width, gappedATxtSize.height);
    
    [self highlightDifferencesInGappedLbls];
}

- (void)setUpWithRead:(ED_Info *)r {
    read = r;
}

- (void)highlightDifferencesInGappedLbls {
    if (read.gappedB[0] == kNoGappedBChar[0])
        return;
    
    DNAColors *dnaColors = [[DNAColors alloc] init];
    [dnaColors setUp];
    
    NSMutableAttributedString *gappedAStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:kReadPopoverGappedALblTxt,read.gappedA]];
    NSMutableAttributedString *gappedBStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:kReadPopoverGappedBLblTxt,read.gappedB]];
    
    int startIndex = (int)kReadPopoverGappedALblTxt.length-2;//-2 subtracts off the %s
    for (int i = 0; i < gappedAStr.length; i++) {
        if (read.gappedA[i] != read.gappedB[i]) {
            [gappedAStr addAttribute:NSBackgroundColorAttributeName value:[dnaColors.mutHighlight UIColorObj] range:NSMakeRange(startIndex+i, 1)];
            [gappedBStr addAttribute:NSBackgroundColorAttributeName value:[dnaColors.mutHighlight UIColorObj] range:NSMakeRange(startIndex+i, 1)];
        }
    }
    
    gappedALbl.attributedText = gappedAStr;
    gappedBLbl.attributedText = gappedBStr;
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
