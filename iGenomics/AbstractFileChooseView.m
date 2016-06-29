//
//  AbstractFileChooseView.m
//  iGenomics
//
//  Created by Stuckinaboot on 6/29/16.
//
//

#import "AbstractFileChooseView.h"

@implementation AbstractFileChooseView

@synthesize delegate;

- (void)setUpWithDescriptionTxt:(NSString*)descriptTxt chosenFileTxt:(NSString*)chosenTxt {
    DNAColors *dnaColors = [[DNAColors alloc] init];
    [dnaColors setUp];
    
    CGRect frame = self.frame;
    self.backgroundColor = [dnaColors.defaultBtn UIColorObj];
    
    descriptionLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width * kAbstractFileChooseViewDescriptionLblRelativeWidth, frame.size.height / 2)];
    descriptionLbl.center = CGPointMake(frame.size.width/2, descriptionLbl.center.y);
    [descriptionLbl setFont:[UIFont boldSystemFontOfSize:kAbstractFileChooseViewDescriptionLblFontSize]];
    [descriptionLbl setTextAlignment:NSTextAlignmentCenter];
    [descriptionLbl setMinimumScaleFactor:kAbstractFileChooseViewDescriptionLblFontMinScaleFactor];
    [descriptionLbl setAdjustsFontSizeToFitWidth:YES];
    [self addSubview:descriptionLbl];
    
    chosenFileLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height / 2, frame.size.width * kAbstractFileChooseViewChosenFileLblRelativeWidth, frame.size.height / 2)];
    [chosenFileLbl setTextAlignment:NSTextAlignmentCenter];
    [chosenFileLbl setFont:[UIFont systemFontOfSize:kAbstractFileChooseViewChosenFileLblFontSize]];
    [chosenFileLbl setNumberOfLines:kAbstractFileChooseViewChosenFileLblNumOfLines];
    [chosenFileLbl setMinimumScaleFactor:kAbstractFileChooseViewChosenFileLblFontMinScaleFactor];
    [chosenFileLbl setAdjustsFontSizeToFitWidth:YES];
    [self addSubview:chosenFileLbl];
    
    chooseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [chooseBtn setTitle:kAbstractFileChooseViewChooseBtnTitle forState:UIControlStateNormal];
    [chooseBtn setBackgroundColor:[UIColor blueColor]];
    [chooseBtn setFrame:CGRectMake(0, 0, frame.size.width * kAbstractFileChooseViewChooseBtnRelWidth, frame.size.height * kAbstractFileChooseViewChooseBtnRelHeight)];
    chooseBtn.center = CGPointMake(chosenFileLbl.frame.size.width + (frame.size.width - chosenFileLbl.frame.size.width) / 2, frame.size.height / 2 + frame.size.height / 4);
    [chooseBtn addTarget:self action:@selector(choosePressed:) forControlEvents:UIControlEventTouchUpInside];
    [chooseBtn setBackgroundColor:[dnaColors.defaultBtnSpecial UIColorObj]];
    [chooseBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [chooseBtn setShowsTouchWhenHighlighted:YES];
    [self addSubview:chooseBtn];
    
    [descriptionLbl setText:descriptTxt];
    [chosenFileLbl setText:chosenTxt];
}

- (void)updateChosenFileTxt:(NSString*)chosenTxt {
    [chosenFileLbl setText:chosenTxt];
}

- (IBAction)choosePressed:(id)sender {
    [delegate choosePressedForChooseView:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
