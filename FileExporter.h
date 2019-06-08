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
//#import <dropbox/dropbox.h>
#import "GlobalVars.h"
#import "MutationInfo.h"

#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

#define kExportASTitle @"Export Data"

#define kExportASExportMutationsHaploid @"Export Mutations (Haploid)"
#define kExportASExportMutationsHaploidIndex 1

#define kExportASExportMutationsDiploid @"Export Mutations (Diploid)"
#define kExportASExportMutationsDiploidIndex 2

#define kExportMutExportEmailMuts @"Email Mutations"
#define kExportMutExportEmailMutsIndex 0 
#define kExportMutExportDropboxMuts @"Save Mutations to Dropbox"
#define kExportMutExportDropboxMutsIndex 1

#define kExportASEmailData @"Email Data"
#define kExportASEmailDataIndex 3
#define kExportASDropboxData @"Save Data to Dropbox"
#define kExportASDropboxDataIndex 4

#define kExportAlertTitle @"File Export"
#define kExportAlertBody @"Enter file name here:"
#define kExportAlertBtnExportTitle @"Export"

#define kExportDropboxSaveFileFormatMuts @"/%@%@.var.vcf"//reads(1..2..3 or no ()).var...
#define kExportDropboxSaveFileFormatData @"/%@%@.data.acp"//reads(1..2..3 or no ()).data...
#define kExportDropboxSaveFileExt @".txt"
#define kExportDropboxSaveDataFileExt @".acp"
#define kExportDropboxSaveMutsFileExt @".vcf"

#define kExportMailSaveFileFormatMuts @"%@%@.var.vcf"
#define kExportMailSaveFileFormatData @"%@%@.data.acp"

#define kErrorAlertExportTitle @"iGenomics: Error"
#define kErrorAlertExportBody @"An error occurred exporting the file."
#define kErrorAlertExportBodyFileNameAlreadyInUse @"File name already used. Would you like to overwrite or cancel?"
#define kErrorAlertExportBtnTitleOverwrite @"Overwrite"

#define kErrorAlertExportBodyGeneralFailError @"Export failed. Please check your connection and try again later."
#define kErrorAlertExportBodyGeneralFailErrorBtnTitleClose @"Dismiss"


#define kExportDataFileName @"ExportData"
#define kExportDataEmailSubject @"iGenomics- Export Data for Aligning %@ to %@"
#define kExportDataEmailMsg @"Read alignment information for aligning %@ to %@ for a maximum error rate of %.02f. The format of the export data is as follows: Read Number  Position Matched    Segment Forward(+)/Reverse complement(-) Matched    Edit Distance   Gapped Reference    Gapped Read.\n\nPowered by iGenomics"

#define kExportMutsFileName @"Mutations"
#define kExportMutsEmailSubject @"iGenomics- Mutations for Aligning %@ to %@"
#define kExportMutsEmailMsg @"Mutation export information for aligning %@ to %@ for a maximum error rate of %.02f.\n\nPowered by iGenomics"

#define kExportMutsHeaderFileName @"mutation_output.sample"
#define kExportMutsHeaderFileExt @"vcf"

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
    UIActionSheet *exportOptionsMutsActionSheet;
    
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
    float errorRate;
    int mutationSupportVal;
    NSArray *mutPosArray;
    
    float totalAlignmentRuntime;
    int totalNumOfReadsAligned;
    int totalNumOfReads;
    NSArray *separateGenomeLens;
    NSArray *separateSegmentNames;
}
@property (nonatomic) id <FileExporterDelegate> delegate;
- (void)setGenomeFileName:(NSString*)gName andReadsFileName:(NSString*)rName andErrorRate:(float)er andExportDataStr:(NSString*)expDataStr andTotalNumOfReads:(int)numOfReads andTotalNumOfReadsAligned:(int)numOfReadsAligned separateGenomeLensArr:(NSArray*)sepGenLens separateGenomeNamesArr:(NSArray*)sepSegNames;
- (void)fixExportDataStr;

- (void)setMutSupportVal:(int)mutSupVal andMutPosArray:(NSArray*)mutPosArr;

- (void)displayExportOptionsWithSender:(id)sender;

- (void)setTotalAlignmentRuntime:(float)runtime;

- (void)emailInfoForOption:(EmailInfoOption)option isDiploid:(BOOL)isDiploid;
- (void)saveFileAtPath:(NSString *)path andContents:(NSString *)contents andFileType:(FileType)fileType completion:(void(^)(BOOL, BOOL))completionBlock;// uploaded succesfully, file already exists error
- (void)overwriteFileAtPath:(NSString*)path andContents:(NSString*)contents andFileType:(FileType)fileType;
- (int)firstAvailableDefaultFileNameForMutsOrData:(int)choice;
- (NSString*)fixChosenExportPathExt:(NSString*)path forFileType:(FileType)fileType;

@end
