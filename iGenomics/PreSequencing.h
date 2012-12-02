//
//  PreSequencing.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 12/1/12.
//
//

#import <UIKit/UIKit.h>

#import "FileChooser.h"

@interface PreSequencing : UIViewController <FileChooserDelegate> {
    IBOutlet FileChooser *fileChooser;
    
    BOOL readsPicked, seqPicked;
    NSString *reads;
    NSString *seq;
}
- (IBAction)chooseReads:(id)sender;
- (IBAction)chooseSeqs:(id)sender;

- (IBAction)backPressed:(id)sender;
- (IBAction)donePressed:(id)sender;
@end
