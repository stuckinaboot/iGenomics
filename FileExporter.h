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
#import "GlobalVars.h"
#import "MutationInfo.h"

#define kExportASTitle @"Export Data"
#define kExportASEmailMutations @"Email Mutations"
#define kExportASEmailMutsIndex 1 //Index 0 is the cancel button
#define kExportASEmailData @"Email Data"
#define kExportASEmailDataIndex 2
#define kExportASDropboxMuts @"Save Mutations to Dropbox"
#define kExportASDropboxMutsIndex 3
#define kExportASDropboxData @"Save Data to Dropbox"
#define kExportASDropboxDataIndex 4

#define kExportAlertTitle @"File Export"
#define kExportAlertBody @"Enter file name here:"

#define kExportDropboxSaveFileFormatMuts @"%@%@.var.txt"//reads(1..2..3 or no ()).var...
#define kExportDropboxSaveFileFormatData @"%@%@.data.txt"//reads(1..2..3 or no ()).data...
#define kExportDropboxSaveFileExt @".txt"

#define kErrorAlertExportTitle @"iGenomics: Error"
#define kErrorAlertExportBody @"An error occurred exporting the file."
#define kErrorAlertExportBodyFileNameAlreadyInUse @"File name already used. Would you like to overwrite or cancel?"

@protocol FileExporterDelegate <NSObject>
- (UIViewController*)getVC;
- (void)displaySuccessBox;
@end
@interface FileExporter : NSObject <UIActionSheetDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate> {
    //Used to display data export options
    UIActionSheet *exportActionSheet;
    MFMailComposeViewController *exportMailController;
    NSString *exportDataStr;
    
    //Select Export Save File Name Alert
    UIAlertView *exportMutsDropboxAlert;
    UIAlertView *exportMutsDropboxErrorAlert;
    UIAlertView *exportDataDropboxAlert;
    UIAlertView *exportDataDropboxErrorAlert;
    NSString *chosenMutsExportPath;
    NSString *chosenDataExportPath;
    
    NSString *genomeFileName;
    NSString *readsFileName;
    int editDistance;
    int mutationSupportVal;
    NSArray *mutPosArray;
}
@property (nonatomic) id <FileExporterDelegate> delegate;
- (void)setGenomeFileName:(NSString*)gName andReadsFileName:(NSString*)rName andEditDistance:(int)ed andExportDataStr:(NSString*)expDataStr;
- (void)setMutSupportVal:(int)mutSupVal andMutPosArray:(NSArray*)mutPosArr;

- (void)displayExportOptionsWithSender:(id)sender;

- (void)emailInfoForOption:(EmailInfoOption)option;
- (BOOL)saveFileAtPath:(NSString*)path andContents:(NSString*)contents;
- (BOOL)overwriteFileAtPath:(NSString*)path andContents:(NSString*)contents;
- (int)firstAvailableDefaultFileNameForMutsOrData:(int)choice;
- (NSString*)fixChosenExportPathExt:(NSString*)path;

@end
