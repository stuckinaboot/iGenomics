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

typedef enum {
    FileTypeMutations,
    FileTypeData
} FileType;

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
#define kExportAlertBtnExportTitle @"Export"

#define kExportDropboxSaveFileFormatMuts @"%@%@.var.txt"//reads(1..2..3 or no ()).var...
#define kExportDropboxSaveFileFormatData @"%@%@.data.acp"//reads(1..2..3 or no ()).data...
#define kExportDropboxSaveFileExt @".txt"
#define kExportDropboxSaveDataFileExt @".acp"
#define kExportDropboxSaveMutsFileExt @".mcs"

#define kErrorAlertExportTitle @"iGenomics: Error"
#define kErrorAlertExportBody @"An error occurred exporting the file."
#define kErrorAlertExportBodyFileNameAlreadyInUse @"File name already used. Would you like to overwrite or cancel?"
#define kErrorAlertExportBtnTitleOverwrite @"Overwrite"


#define kExportDataFileName @"ExportData"
#define kExportDataEmailSubject @"iGenomics- Export Data for Aligning %@ to %@"
#define kExportDataEmailMsg @"Read alignment information for aligning %@ to %@ for a maximum edit distance of %i. The format is for the export is as follows: Read Number, Position Matched, Segment, Forward(+)/Reverse complement(-) Matched, Edit Distance, Gapped Reference, Gapped Read.The export information is attached to this email as an ACP (Alignment Compressed Protocol) file. \n\nPowered by iGenomics"

#define kExportMutsFileName @"Mutations"
#define kExportMutsEmailSubject @"iGenomics- Mutations for Aligning %@ to %@"
#define kExportMutsEmailMsg @"Mutation export information for aligning %@ to %@ for a maximum edit distance of %i. Also, for a position to be considered heterozygous, the heterozygous character must have been recorded at least %i times. The export information is attached to this email as an MCS (Mutation Compressed String) file. \n\nPowered by iGenomics"

#define kNoMutationsFoundStr @"No Mutations Found"

@protocol FileExporterDelegate <NSObject>
- (UIViewController*)getVC;
- (NSArray*)getCumulativeLenArray;
- (NSArray*)getSeparateGenomeSegmentNamesArray;
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
- (void)fixExportDataStr;

- (void)setMutSupportVal:(int)mutSupVal andMutPosArray:(NSArray*)mutPosArr;

- (void)displayExportOptionsWithSender:(id)sender;

- (void)emailInfoForOption:(EmailInfoOption)option;
- (BOOL)saveFileAtPath:(NSString*)path andContents:(NSString*)contents andFileType:(FileType)fileType;
- (BOOL)overwriteFileAtPath:(NSString*)path andContents:(NSString*)contents andFileType:(FileType)fileType;
- (int)firstAvailableDefaultFileNameForMutsOrData:(int)choice;
- (NSString*)fixChosenExportPathExt:(NSString*)path forFileType:(FileType)fileType;

@end
