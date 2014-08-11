//
//  AnalysisControllerIPadMenu.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 8/8/14.
//
//

#import <UIKit/UIKit.h>
#import "CoverageHistogram.h"
#import "FileExporter.h"
#import "MutationsInfoPopover.h"
#import "ImportantMutationInfo.h"

#define kAnalysisControllerIPadTblSectionInformation @"Genome Information"
#define kAnalysisControllerIPadTblSectionGenomeInteraction @"Genome Interaction"
#define kAnalysisControllerIPadTblSectionSettings @"Settings"
#define kAnalysisControllerIPadTblSectionExport @"Export"

#define kAnalysisControllerIPadTblElementViewMuts @"Mutation List"
#define kAnalysisControllerIPadTblElementViewImptMuts @"Important Mutation List"
#define kAnalysisControllerIPadTblElementSearch @"Search"
#define kAnalysisControllerIPadTblElementSegmentPicker @"Segment Picker"
#define kAnalysisControllerIPadTblElementMutSupport @"Mutation Support"
#define kAnalysisControllerIPadTblElementSettings @"Settings"
#define kAnalysisControllerIPadTblElementCovHistogram @"Coverage Histogram"
#define kAnalysisControllerIPadTblElementExport @"Export Alignment Data"

#define kAnalysisControllerIPadTblCellAlpha 0.5f

@class ImportantMutationsDisplayView, MutationsInfoPopover;

@interface AnalysisControllerIPadMenu : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *tblView;
    NSArray *sectionNameArr;
    
    NSArray *completeSecElArr;//An array of all of the arrays of elements
    NSArray *completeSecElContentsArr;//An array of all of the arrays of contents of the elements
    
    NSArray *genomeInteractionElementsArr;
    NSArray *genomeInteractionElementContentsArr;
    
    NSArray *genomeInformationElementsArr;
    NSArray *genomeInformationElementContentsArr;
    
    NSArray *settingsElementsArr;
    NSArray *settingsElementContentsArr;
    
    NSArray *exportElementsArr;
    NSArray *exportElementContentsArr;
    
    
    IBOutlet UIView *elementSearchView;
    
    IBOutlet UIView *elementSegmentPckrView;
    IBOutlet UIView *elementMutSprtView;
    IBOutlet UIView *elementSettingsView;
    
    CoverageHistogram *covHistogram;
    MutationsInfoPopover *mutInfoPopover;
    ImportantMutationsDisplayView *imptMutsDisplayView;
    FileExporter *fileExporter;
    
    UIPopoverController *popoverController;
}
- (void)setCoverageHistogram:(CoverageHistogram*)histo;
- (void)setMutationsInfoPopover:(MutationsInfoPopover*)m;
- (void)setImptMutationsView:(ImportantMutationsDisplayView*)i;
- (void)setFileExporter:(FileExporter*)exporter;

- (void)displayViewController:(UIViewController*)controller outOfCell:(UITableViewCell*)cell;

- (void)displayCovHistogramOutOfCell:(UITableViewCell*)cell;
- (void)displayExportActionSheetOutOfCell:(UITableViewCell*)cell;
@end
