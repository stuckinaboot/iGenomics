//
//  APTableViewCell.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 8/6/15.
//
//

#import "APTableViewCell.h"

@implementation APTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
