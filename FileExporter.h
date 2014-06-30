//
//  FileExporter.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 6/30/14.
//
//

typedef enum {
    EmailInfoOptionMutations,
    EmailInfoOptionData
} EmailInfoOption;

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import <dropbox/dropbox.h>

@protocol FileExporterDelegate <NSObject>
- (UIViewController*)getVC;
@end
@interface FileExporter : NSObject <UIAlertViewDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic) id <FileExporterDelegate> delegate;
- (void)emailInfoForOption:(EmailInfoOption)option;
- (BOOL)saveFileAtPath:(NSString*)path andContents:(NSString*)contents;
- (BOOL)overwriteFileAtPath:(NSString*)path andContents:(NSString*)contents;
- (int)firstAvailableDefaultFileNameForMutsOrData:(int)choice;
- (NSString*)fixChosenExportPathExt:(NSString*)path;

@end
