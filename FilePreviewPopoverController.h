//
//  FilePreviewPopoverController.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 2/25/14.
//
//

#import <UIKit/UIKit.h>
#import "GlobalVars.h"
#import "IPhonePopoverHandler.h"

#define kFilePreviewPopoverFontName @"Courier"
#define kFilePreviewPopoverFontSize 14

#define kFilePreviewPopoverTitleInIPhonePopoverHandler @"File Preview"

@interface FilePreviewPopoverController : UIViewController {
    IBOutlet UITextView *txtView;
    NSString *txtViewContents;
}
@property (nonatomic) IBOutlet UITextView *txtView;
- (void)updateTxtViewContents:(NSString*)contents;
@end
