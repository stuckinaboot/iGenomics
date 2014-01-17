//
//  AboutSectionViewController.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/17/14.
//
//

#import <UIKit/UIKit.h>

#define kAboutSectionFileName @"About"
#define kAboutSectionFileExt @"txt"

@interface AboutSectionViewController : UIViewController {
    IBOutlet UITextView *abtView;
}
- (IBAction)done:(id)sender;
@end
