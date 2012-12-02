//
//  ViewController.h
//  LabProject5
//
//  Created by Stuckinaboot Inc. on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BWT.h"
#import "EditDistance.h"

#define kPrintIndevelopmentVars 1

#import "PreSequencing.h"

@interface ViewController : UIViewController {
    BWT *bwt;
    IBOutlet PreSequencing *preSequencing;
}
- (IBAction)startSequencingStep1:(id)sender;
@end
