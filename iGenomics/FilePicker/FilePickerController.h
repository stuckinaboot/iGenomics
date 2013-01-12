//
//  FilePickerController.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/4/13.
//
//

#import <UIKit/UIKit.h>

#import "ParametersController.h"

#define kTxt @"txt"

#define kDefaultRefFilesNamesFile @"NamesOfDefaultReferenceFiles"
#define kDefaultReadsFilesNamesFile @"NamesOfDefaultReadsFiles"

#define kNumOfComponentsInPickers 1

#define kComponent1Title @"Default"

@interface FilePickerController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
    ParametersController *parametersController;
    
    IBOutlet UIPickerView *referenceFilePicker;
    IBOutlet UIPickerView *readsFilePicker;
    
    NSMutableArray *defaultRefFilesNames;
    NSMutableArray *defaultReadsFilesNames;
}
- (IBAction)showParametersPressed:(id)sender;
- (IBAction)backPressed:(id)sender;

- (void)setUpDefaultFiles;
@end
