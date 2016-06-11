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

#define kGridPointImgViewAlpha 1.0

#define kDefFontSize 30

@protocol GridPointDelegate <NSObject>
- (void)gridPointClickedWithCoord:(CGPoint)c;
@end

@interface GridPoint : UIView {
    id delegate;
}
@property (nonatomic) id <GridPointDelegate> delegate;

@property (nonatomic) CGPoint coord;

@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UIImageView *view;
@property (nonatomic, retain) UIButton *btn;

- (void)setUpLabel;
- (void)setUpView;
- (void)setUpBtn;

- (IBAction)btnTapped:(id)sender;
@end
