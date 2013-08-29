//
//  AnalysisController.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/11/13.
//
//

#import "AnalysisController.h"

@interface AnalysisController ()

@end

@implementation AnalysisController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    dnaColors = [[DNAColors alloc] init];
    [dnaColors setUp];
    
    zoomLevel = kPinchZoomStartingLevel;
    
    pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchOccurred:)];
    [gridView addGestureRecognizer:pinchRecognizer];
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapOccured:)];
    [gridView addGestureRecognizer:tapRecognizer];
    
    [gridView firstSetUp];
    
    gridView.kIpadBoxWidth = kDefaultIpadBoxWidth;
    
    mutationSupportStpr.maximumValue = kMutationSupportMax;
    
    [self resetDisplay];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)readyViewForDisplay:(char*)unraveledStr andInsertions:(NSMutableArray *)iArr andBWT:(BWT *)myBwt andExportData:(NSString*)exportDataString andBasicInfo:(NSArray*)basicInfArr {
    originalStr = unraveledStr;
    insertionsArr = iArr;
    bwt = myBwt;
    exportDataStr = exportDataString;
    
    //genome file name, reads file name, read length, genome length, number of reads
    genomeFileName = [basicInfArr objectAtIndex:0];
    readsFileName = [basicInfArr objectAtIndex:1];
    readLen = [[basicInfArr objectAtIndex:2] intValue];
    genomeLen = [[basicInfArr objectAtIndex:3] intValue];
    numOfReads = [[basicInfArr objectAtIndex:4] intValue];
    editDistance = [[basicInfArr objectAtIndex:5] intValue];
}

- (void)resetDisplay {
    
    //Set up info lbls
    [genomeNameLbl setText:[NSString stringWithFormat:@"%@",genomeFileName]];
    [genomeLenLbl setText:[NSString stringWithFormat:@"%@%i",kLengthLblStart,genomeLen]];
    
    [readsNameLbl setText:[NSString stringWithFormat:@"%@",readsFileName]];
    [readLenLbl setText:[NSString stringWithFormat:@"%@%i",kLengthLblStart,readLen]];
    
    double coverage = (double)((double)numOfReads * readLen)/(double)genomeLen;
    
    [genomeCoverageLbl setText:[NSString stringWithFormat:@"%@%.02fx",kGenomeCoverageLblStart,coverage]];
    mutPosArray = [[NSMutableArray alloc] init];
    allMutPosArray = [[NSMutableArray alloc] init];
    
    [readNumOfLbl setText:[NSString stringWithFormat:@"%@%i",kNumOfReadsLblStart,numOfReads]];
    
    mutationSupportStpr.value = bwt.bwtMutationFilter.kHeteroAllowance;
    [mutationSupportNumLbl setText:[NSString stringWithFormat:@"%i",(int)mutationSupportStpr.value]];
    
    [self performSelector:@selector(setUpGridLbls) withObject:nil afterDelay:0];
    
    [gridViewTitleLblHolder.layer setBorderWidth:kGridViewTitleLblHolderBorderWidth];
    //Set up gridView
    int len = fileStrLen-1;//-1 so to not include $ sign
    
    [gridView setDelegate:self];
    gridView.refSeq = originalStr;
    [gridView setUpWithNumOfRows:kNumOfRowsInGridView andCols:len andGraphBoxHeight:kGraphRowHeight];
    [pxlOffsetSlider setMaximumValue:((gridView.totalCols*(kGridLineWidthCol+gridView.kIpadBoxWidth)))-gridView.frame.size.width];
    [self mutationSupportStepperChanged:mutationSupportStpr];
}

- (void)setUpGridLbls {
    CGRect rect = CGRectMake(0, 0, kSideLblW, kSideLblH);
    
    NSArray *txtArr = [[NSArray alloc] initWithObjects:@"Cov",@"Ref",@"Fnd",@"A",@"C",@"G",@"T",@"-",@"+", nil];
    
    int yPos = gridView.frame.origin.y+kPosLblHeight+(gridView.graphBoxHeight/2);
    
    for (int i  = 0; i<kNumOfRowsInGridView; i++) {
        nLbl[i] = [[UILabel alloc] initWithFrame:rect];
        [nLbl[i] setFont:[UIFont systemFontOfSize:kSideLblFontSize]];
        [nLbl[i] setAdjustsFontSizeToFitWidth:YES];
        [nLbl[i] setBackgroundColor:[UIColor clearColor]];
        [nLbl[i] setText:[txtArr objectAtIndex:i]];
        [nLbl[i] setTextAlignment:NSTextAlignmentCenter];
        nLbl[i].center = CGPointMake(kSideLblStartingX, yPos);
        
        RGB *rgb;
        
        switch (i) {
            case 0:
                rgb = dnaColors.covLbl;
                break;
            case 1:
                rgb = dnaColors.black;
                break;
            case 2:
                rgb = dnaColors.black;
                break;
            case 3:
                rgb = dnaColors.aLbl;
                break;
            case 4:
                rgb = dnaColors.cLbl;
                break;       
            case 5:
                rgb = dnaColors.gLbl;
                break;
            case 6:
                rgb = dnaColors.tLbl;
                break;
            case 7:
                rgb = dnaColors.delLbl;
                break;
            case 8:
                rgb = dnaColors.insLbl;
                break;
        }
        
        [nLbl[i] setTextColor:[UIColor colorWithRed:rgb.r green:rgb.g blue:rgb.b alpha:1.0f]];
        
        if (i == 0)//graph row
            yPos += gridView.graphBoxHeight/2 + kGridLineWidthRow + gridView.boxHeight/2;
        else
            yPos += gridView.boxHeight + kGridLineWidthRow;
        
        [self.view addSubview:nLbl[i]];
    }
}

//Interactive UI Elements besides gridview
- (IBAction)posSearch:(id)sender {
    int i = [posSearchTxtFld.text doubleValue];
    if (i > 0 && i<= fileStrLen) {//is a valid number
        [gridView scrollToPos:i-1];//converts it to the normal scale where pos 0 is 0
    }
    [posSearchTxtFld resignFirstResponder];
}

- (IBAction)seqSearch:(id)sender {
    if (![seqSearchTxtFld.text isEqualToString:@""]) {//is not an empty query
        querySeqPosArr = [[NSArray alloc] initWithArray:[bwt simpleSearchForQuery:(char*)[seqSearchTxtFld.text UTF8String]]];
        if ([querySeqPosArr count]>0) {//At least one match
            int firstPos = [[querySeqPosArr objectAtIndex:0] intValue];
            [gridView scrollToPos:firstPos];
        }
        else {
            //Show an error
        }
    }
    [seqSearchTxtFld resignFirstResponder];
}

- (IBAction)showSeqSearchResults:(id)sender {
    SearchQueryResultsPopover *sq = [[SearchQueryResultsPopover alloc] init];
    [sq setDelegate:self];
    [sq loadWithResults:querySeqPosArr];
    
    
    popoverController = [[UIPopoverController alloc] initWithContentViewController:sq];
    [popoverController presentPopoverFromRect:showQueryResultsBtn.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (IBAction)showMutTBView:(id)sender {
    popoverController = [[UIPopoverController alloc] initWithContentViewController:mutsPopover];
    [popoverController presentPopoverFromRect:showMutTBViewBtn.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

//Mutation Support Stepper
- (IBAction)mutationSupportStepperChanged:(id)sender {
    UIStepper *stepper = (UIStepper*)sender;
    int val = (int)stepper.value;
    
    [showAllMutsBtn setTitle:kShowAllMutsBtnTxtUpdating forState:UIControlStateNormal];
    showAllMutsBtn.enabled = FALSE;
    
    mutationSupportNumLbl.text = [NSString stringWithFormat:@"%i",val];
    
    [mutPosArray removeAllObjects];
    bwt.bwtMutationFilter.kHeteroAllowance = val;
    
//    [bwt.bwtMutationFilter filterMutationsForDetails];
    mutPosArray = [BWT_MutationFilter filteredMutations:allMutPosArray forHeteroAllowance:val];
//    [gridView initialMutationFind];
    [mutsPopover setUpWithMutationsArr:mutPosArray];
    
//    [gridView clearAllPoints];
    [gridView setUpGridViewForPixelOffset:gridView.currOffset];
}

//Mutation Info Popover Delegate
- (void)mutationAtPosPressedInPopover:(int)pos {
    [popoverController dismissPopoverAnimated:YES];
    [gridView scrollToPos:pos-1];
}

- (void)mutationsPopoverDidFinishUpdating {
    [showAllMutsBtn setTitle:kShowAllMutsBtnTxtNormal forState:UIControlStateNormal];
    showAllMutsBtn.enabled = TRUE;
}

//Search Query Results Delegate
- (void)queryResultPosPicked:(int)pos {
    [popoverController dismissPopoverAnimated:YES];
    [gridView scrollToPos:pos];
}

//Grid View zoom in/out
-(void)pinchOccurred:(UIPinchGestureRecognizer*)sender {
    if ([sender state] == UIGestureRecognizerStateEnded) {
        double s = [sender scale];
        
        if (s > 1.0f) {//Zoom in
            if (zoomLevel>kPinchZoomMaxLevel) {
                int pt = [gridView firstPtToDrawForOffset:gridView.currOffset];
                gridView.kIpadBoxWidth *= kPinchZoomFactor;
                gridView.kTxtFontSize *= kPinchZoomFontSizeFactor;
                zoomLevel--;
                
                [gridView resetScrollViewContentSize];
                [gridView resetTickMarkInterval];
                [pxlOffsetSlider setMaximumValue:((gridView.totalCols*(kGridLineWidthCol+gridView.kIpadBoxWidth)))-gridView.frame.size.width];
                gridView.currOffset = [gridView offsetOfPt:pt];
                [gridView.scrollingView setContentOffset:CGPointMake(gridView.currOffset, 0)];
                [gridView setUpGridViewForPixelOffset:gridView.currOffset];
            }
        }
        else if (s < 1.0f) {//Zoom out
            if (zoomLevel<kPinchZoomMinLevel) {
                int pt = [gridView firstPtToDrawForOffset:gridView.currOffset];
                gridView.kIpadBoxWidth /= kPinchZoomFactor;
                gridView.kTxtFontSize /= kPinchZoomFontSizeFactor;

                zoomLevel++;
                
                [gridView resetScrollViewContentSize];
                [gridView resetTickMarkInterval];
                [pxlOffsetSlider setMaximumValue:((gridView.totalCols*(kGridLineWidthCol+gridView.kIpadBoxWidth)))-gridView.frame.size.width];
                gridView.currOffset = [gridView offsetOfPt:pt];
                [gridView.scrollingView setContentOffset:CGPointMake(gridView.currOffset, 0)];
                [gridView setUpGridViewForPixelOffset:gridView.currOffset];
            }
        }
    }
}

//Single Tap (Treated as a button tap)
- (void)singleTapOccured:(UITapGestureRecognizer*)sender {
    CGPoint pt = [sender locationInView:gridView];
    
    //Get the xCoord in the scrollView
    double xCoord = gridView.currOffset+pt.x;
    
    //Find the box that was clicked
    CGPoint box = CGPointMake([gridView firstPtToDrawForOffset:xCoord],(int)((pt.y-(kPosLblHeight+kGraphRowHeight))/(kGridLineWidthRow+gridView.boxHeight)));//Get the tapped box
    
    [self gridPointClickedWithCoordInGrid:box andClickedPt:pt];
}

//Grid view delegate
- (void)gridPointClickedWithCoordInGrid:(CGPoint)c andClickedPt:(CGPoint)o {
    if (c.y < 2 && c.y >= 0) {
        AnalysisPopoverController *apc = [[AnalysisPopoverController alloc] init];
        apc.contentSizeForViewInPopover = CGSizeMake(kAnalysisPopoverW, kAnalysisPopoverH);
        
        popoverController = [[UIPopoverController alloc] initWithContentViewController:apc];
        
        apc.posLbl.text = [NSString stringWithFormat:@"Position: %1.0f",c.x+1];//+1 so doesn't start at 0
        
        NSMutableString *heteroStr = [[NSMutableString alloc] initWithString:@"Hetero: "];
        
        for (int i = 1; i<kACGTLen+2; i++) {
            [heteroStr appendFormat:@" %c",foundGenome[i][(int)c.x]];
        }
        
        apc.heteroLbl.text = heteroStr;
    }
    else if (c.y == kNumOfRowsInGridView-2 /*-2 is because of grid and because the normal use of size-1*/ && posOccArray[kACGTLen+1][(int)c.x] > 0/*there is at least one insertion there*/) {
        InsertionsPopoverController *ipc = [[InsertionsPopoverController alloc] init];
        [ipc setInsArr:insertionsArr forPos:(int)c.x];
        
        ipc.contentSizeForViewInPopover = CGSizeMake(kInsPopoverW, kInsPopoverH);
        
        popoverController = [[UIPopoverController alloc] initWithContentViewController:ipc];
    }
    else
        return;
    CGRect rect = CGRectMake(c.x*(gridView.kIpadBoxWidth+kGridLineWidthCol)-gridView.currOffset, c.y*(gridView.boxHeight+kGridLineWidthRow)+kGraphRowHeight+kPosLblHeight, gridView.kIpadBoxWidth, gridView.boxHeight);
    
    [popoverController presentPopoverFromRect:rect inView:gridView permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

- (void)mutationFoundAtPos:(int)pos {
    [allMutPosArray addObject:[NSNumber numberWithInt:pos]];
}

- (void)gridFinishedUpdatingWithOffset:(double)currOffset {
    if (!mutsPopoverAlreadyUpdated) {
        mutsPopover = [[MutationsInfoPopover alloc] init];
        [mutsPopover setDelegate:self];
        if ([mutPosArray count] == 0)
            mutPosArray = [[NSMutableArray alloc] initWithArray:allMutPosArray];
        [mutsPopover setUpWithMutationsArr:[BWT_MutationFilter filteredMutations:mutPosArray forHeteroAllowance:mutationSupportStpr.value]];
        mutsPopoverAlreadyUpdated = !mutsPopoverAlreadyUpdated;
    }
    
    pxlOffsetSlider.value = currOffset;//a little bit of a prob here
}

//Exports data
- (IBAction)exportDataPressed:(id)sender {
    exportActionSheet = [[UIActionSheet alloc] initWithTitle:kExportASTitle delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Cancel" otherButtonTitles:kExportASEmailMutations, kExportASEmailData, kExportASDropboxMuts, kExportASDropboxData, nil];
    [exportActionSheet showFromBarButtonItem:(UIBarButtonItem*)sender animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([actionSheet isEqual:exportActionSheet]) {
        if (buttonIndex == kExportASEmailMutsIndex) {
            [self emailInfoForOption:EmailInfoOptionMutations];
        }
        else if (buttonIndex == kExportASEmailDataIndex) {
            [self emailInfoForOption:EmailInfoOptionData];
        }
        else if (buttonIndex == kExportASDropboxMutsIndex) {
            DBFilesystem *sys = [DBFilesystem sharedFilesystem];
            DBFile *file = [sys createFile:[[DBPath alloc] initWithString:[NSString stringWithFormat:kExportDropboxSaveFileFormatMuts,readsFileName,genomeFileName]] error:nil];
            [file writeString:[self getMutationsExportStr] error:nil];
        }
        else if (buttonIndex == kExportASEmailDataIndex) {
            DBFilesystem *sys = [DBFilesystem sharedFilesystem];
            DBFile *file = [sys createFile:[[DBPath alloc] initWithString:[NSString stringWithFormat:kExportDropboxSaveFileFormatData,readsFileName,genomeFileName]] error:nil];
            [file writeString:exportDataStr error:nil];
        }
    }
}

- (void)emailInfoForOption:(EmailInfoOption)option {
    exportMailController = [[MFMailComposeViewController alloc] init];
    exportMailController.mailComposeDelegate = self;
    
    if (option == EmailInfoOptionMutations) {
        [exportMailController setSubject:[NSString stringWithFormat:@"iGenomics- Mutations for Aligning %@ to %@",readsFileName, genomeFileName]];
        [exportMailController setMessageBody:[NSString stringWithFormat:@"Mutation export information for aligning %@ to %@ for a maximum edit distance of %i. Also, for a postion to be considered heterozygous, the heterozygous character must have been recorded at least %i times. The export information is attached to this email as a text file. \n\nPowered by iGenomics", readsFileName, genomeFileName, editDistance, (int)mutationSupportStpr.value+1/*Mutation support is computed using posOccArr[x]i] > kHeteroAllowance, so for solely greater than, it needs to add one for the sentence in the message to make sense*/] isHTML:NO];
        
        NSMutableString *mutString = [self getMutationsExportStr];
        [exportMailController addAttachmentData:[mutString dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"text/plain" fileName:@"Mutations"];
        [self presentModalViewController:exportMailController animated:YES];
    }
    else if (option == EmailInfoOptionData) {
        [exportMailController setSubject:[NSString stringWithFormat:@"iGenomics- Export Data for Aligning %@ to %@",readsFileName, genomeFileName]];
        [exportMailController setMessageBody:[NSString stringWithFormat:@"Read alignment information for aligning %@ to %@ for a maximum edit distance of %i. The format is for the export is as follows: Read Number, Position Matched, Forward(+)/Reverse complement(-) Matched, Edit Distance, Gapped Reference, Gapped Read.The export information is attached to this email as a text file. \n\nPowered by iGenomics", readsFileName, genomeFileName, editDistance/*Mutation support is computed using posOccArr[x]i] > kHeteroAllowance, so for solely greater than, it needs to add one for the sentence in the message to make sense*/] isHTML:NO];
        
        [exportMailController addAttachmentData:[exportDataStr dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"text/plain" fileName:@"ExportData"];
        [self presentModalViewController:exportMailController animated:YES];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [[self parentViewController] dismissModalViewControllerAnimated:YES];
}

- (NSMutableString*)getMutationsExportStr {
    NSMutableString *mutString = [[NSMutableString alloc] init];
    [mutString appendFormat:@"Total Mutations: %i\n",[mutPosArray count]];
    for (MutationInfo *info in mutPosArray) {
        [mutString appendFormat:kMutationFormat,info.pos+1,[MutationInfo createMutStrFromOriginalChar:info.refChar andFoundChars:info.foundChars]];//+1 so it doesn't start at 0
    }
    return mutString;
}

//Return to main menu
- (IBAction)donePressed:(id)sender {
    confirmDoneAlert = [[UIAlertView alloc] initWithTitle:kConfirmDoneAlertTitle message:kConfirmDoneAlertMsg delegate:self cancelButtonTitle:kConfirmDoneAlertCancelBtn otherButtonTitles:kConfirmDoneAlertGoBtn, nil];
    [confirmDoneAlert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView isEqual:confirmDoneAlert]) {
        if (buttonIndex == 1) {
            [self.view.window.rootViewController dismissModalViewControllerAnimated:YES];
        }
    }
}

//Memory warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
