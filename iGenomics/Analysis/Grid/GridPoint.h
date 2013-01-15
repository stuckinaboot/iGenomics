//
//  GridPoint.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/11/13.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define kBorderW 1

#define kGridPointImgViewAlpha 0.5

@interface GridPoint : UIView {
    
}
@property (nonatomic) CGPoint coord;

@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UIImageView *view;
@property (nonatomic, retain) UIButton *btn;

- (void)setUpLabel;
- (void)setUpView;
- (void)setUpBtn;

- (IBAction)btnTapped:(id)sender;
@end
