//
//  GridPoint.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/11/13.
//
//

#import "GridPoint.h"

@implementation GridPoint

@synthesize coord, label, view, btn, delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderWidth = kBorderW;
        [self.layer setBorderColor:[UIColor whiteColor].CGColor];
    }
    return self;
}

- (void)setUpLabel {
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    label.textAlignment = NSTextAlignmentCenter;
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont systemFontOfSize:kDefFontSize]];//Until A different font is used
    [label setAdjustsFontSizeToFitWidth:YES];
    [self addSubview:label];
}
- (void)setUpView {
    view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    view.alpha = kGridPointImgViewAlpha;
    [self addSubview:view];
}
- (void)setUpBtn {
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [btn addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
}

- (IBAction)btnTapped:(id)sender {
    [delegate gridPointClickedWithCoord:coord];
}
@end
