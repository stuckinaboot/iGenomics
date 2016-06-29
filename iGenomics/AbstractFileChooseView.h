//
//  AbstractFileChooseView.h
//  iGenomics
//
//  Created by Stuckinaboot on 6/29/16.
//
//

#import <UIKit/UIKit.h>
#import "DNAColors.h"

#define kAbstractFileChooseViewDescriptionLblRelativeWidth 0.8
#define kAbstractFileChooseViewDescriptionLblFontSize 25
#define kAbstractFileChooseViewDescriptionLblFontMinScaleFactor 18/25.0f

#define kAbstractFileChooseViewChosenFileLblRelativeWidth 0.65
#define kAbstractFileChooseViewChosenFileLblFontSize 21
#define kAbstractFileChooseViewChosenFileLblNumOfLines 3
#define kAbstractFileChooseViewChosenFileLblFontMinScaleFactor 12/25.0f

#define kAbstractFileChooseViewChooseBtnRelWidth 0.3
#define kAbstractFileChooseViewChooseBtnRelHeight 0.3
#define kAbstractFileChooseViewChooseBtnTitle @"Select File"

@protocol AbstractFileChooseViewDelegate <NSObject>
- (void)choosePressedForChooseView:(id)chooseView;
@end
@interface AbstractFileChooseView : UIView {
    UILabel *descriptionLbl;
    UILabel *chosenFileLbl;
    UIButton *chooseBtn;
}
@property (nonatomic) id <AbstractFileChooseViewDelegate> delegate;
- (void)setUpWithDescriptionTxt:(NSString*)descriptTxt chosenFileTxt:(NSString*)chosenTxt;
- (void)updateChosenFileTxt:(NSString*)chosenTxt;
@end
