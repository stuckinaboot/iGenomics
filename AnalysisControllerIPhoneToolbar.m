//
//  AnalysisControllerIPhoneToolbar.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 3/29/14.
//
//

#import "AnalysisControllerIPhoneToolbar.h"

@implementation AnalysisControllerIPhoneToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)addDoneBtnForTxtFields:(NSArray*)txtFields {
    UIToolbar* keyboardToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, kKeyboardToolbarHeight)];
    
    keyboardToolbar.items = [NSArray arrayWithObjects:
                             [[UIBarButtonItem alloc]initWithTitle:kKeyboardDoneBtnTxt style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard:)],
                             nil];
    
    UITextField *txtField;
    for (int i = 0; i < [txtFields count]; i++) {
        txtField = [txtFields objectAtIndex:i];
        txtField.inputAccessoryView = keyboardToolbar;
    }
}

- (IBAction)dismissKeyboard:(id)sender {
    for (UITextField* field in [self subviews]) {
        [field resignFirstResponder];
    }
}

- (IBAction)donePressed:(id)sender {
    [self removeFromSuperview];
}

@end
