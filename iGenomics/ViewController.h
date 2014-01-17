//
//  ViewController.h
//  LabProject5
//
//  Created by Stuckinaboot Inc. on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FilePickerController.h"
#import "AboutSectionViewController.h"

#import "BWT.h"
#import "EditDistance.h"
#import "APTimer.h"

#define kPrintIndevelopmentVars 1

@interface ViewController : UIViewController {
    FilePickerController *filePickerController;
    AboutSectionViewController *abtSectController;
    
    BWT *bwt;
}
- (IBAction)showFilePickerPressed:(id)sender;
- (IBAction)showAboutPressed:(id)sender;
@end
