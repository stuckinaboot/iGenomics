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
    
    if ([GlobalVars isIpad])
        graphRowHeight = kGraphRowHeightIPad;
    else
        graphRowHeight = kGraphRowHeightIPhone;
    
    pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchOccurred:)];
    [gridView addGestureRecognizer:pinchRecognizer];
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapOccured:)];
    tapRecognizer.numberOfTapsRequired = kNumOfTapsRequiredToDisplayAnalysisPopover;
    [gridView addGestureRecognizer:tapRecognizer];
    
    [gridView firstSetUp];
    
    if ([GlobalVars isIpad])
        gridView.boxWidth = kDefaultIpadBoxWidth;
    else
        gridView.boxWidth = kDefaultIphoneBoxWidth;
    
    mutationSupportStpr.maximumValue = kMutationSupportMax;
    
    gridView.currOffset = 0;//May need to be changed, intented to make it start at first position when new files are analyzed
    
    analysisControllerIPhoneToolbar.hidden = NO;
    
    [self resetDisplay];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    
    //Fixes problems caused by constraints on old iPhone
    gridView.scrollingView.frame = CGRectMake(0, 0, gridView.frame.size.width, gridView.frame.size.height);
    gridView.drawingView.frame = gridView.scrollingView.frame;
    [pxlOffsetSlider setMaximumValue:((gridView.totalCols*(gridView.kGridLineWidthCol+gridView.boxWidth))/gridView.numOfBoxesPerPixel)-gridView.frame.size.width];
    [gridView setUpGridViewForPixelOffset:gridView.currOffset];
    
    [analysisControllerIPhoneToolbar addDoneBtnForTxtFields:[NSArray arrayWithObjects:seqSearchTxtFld, posSearchTxtFld,nil]];
}

- (void)readyViewForDisplay:(char*)unraveledStr andInsertions:(NSMutableArray *)iArr andBWT:(BWT *)myBwt andExportData:(NSString*)exportDataString andBasicInfo:(NSArray*)basicInfArr andSeparateGenomeNamesArr:(NSMutableArray *)sepGNA andSeparateGenomeLensArr:(NSMutableArray *)sepGLA andCumulativeGenomeLensArr:(NSMutableArray *)cGLA {
    NSLog(@"About to ready view for display");
    
    originalStr = unraveledStr;
    insertionsArr = iArr;
    bwt = myBwt;
    exportDataStr = exportDataString;
    
    coverageHistogram = [[CoverageHistogram alloc] init];
    
    //genome file name, reads file name, read length, genome length, number of reads
    genomeFileSegmentNames = [basicInfArr objectAtIndex:0];
    readsFileName = [basicInfArr objectAtIndex:1];
    readLen = [[basicInfArr objectAtIndex:2] intValue];
    genomeLen = [[basicInfArr objectAtIndex:3] intValue];
    numOfReads = [[basicInfArr objectAtIndex:4] intValue];
    editDistance = [[basicInfArr objectAtIndex:5] intValue];
    numOfReadsMatched = [[basicInfArr objectAtIndex:6] intValue];
    
    
    NSRange genomeFileNameRange = NSMakeRange(0, [genomeFileSegmentNames rangeOfString:kRefFileInternalDivider].location);
    genomeFileName = [genomeFileSegmentNames substringWithRange:genomeFileNameRange];
//    genomeFileSegmentNames = [genomeFileSegmentNames substringFromIndex:genomeFileNameRange.length+kRefFileInternalDivider.length];
    
//    NSMutableArray *arr = (NSMutableArray*)[genomeFileSegmentNames componentsSeparatedByString:kRefFileInternalDivider];
    
    separateGenomeNames = sepGNA;
    separateGenomeLens = sepGLA;
    cumulativeSeparateGenomeLens = cGLA;
    
//    NSLog(@"About to create separateGenomeNames and separateGenomeLens arrays");
    
//    for (int i = 0, x = 0; i < [arr count]; i += 2, x++) {
//        [separateGenomeNames addObject:[arr objectAtIndex:i]];
//        [separateGenomeLens addObject:[NSNumber numberWithInt:[[arr objectAtIndex:i+1] intValue]]];
//        if (i > 0)
//            [cumulativeSeparateGenomeLens addObject:[NSNumber numberWithInt:[[separateGenomeLens objectAtIndex:x] intValue]+[[cumulativeSeparateGenomeLens objectAtIndex:x-1] intValue]]];
//        else
//            [cumulativeSeparateGenomeLens addObject:[NSNumber numberWithInt:[[separateGenomeLens objectAtIndex:x] intValue]]];
//    }
    
    fileExporter = [[FileExporter alloc] init];
    [fileExporter setDelegate:self];
    [fileExporter setGenomeFileName:genomeFileName andReadsFileName:readsFileName andEditDistance:editDistance andExportDataStr:exportDataStr];
}

- (void)resetDisplay {
    //Set up info lbls
    [genomeNameLbl setText:[NSString stringWithFormat:@"%@",[separateGenomeNames objectAtIndex:0]]];
    [genomeLenLbl setText:[NSString stringWithFormat:@"%@%i",kGenomeLengthLblStart,genomeLen]];
    
    [readsNameLbl setText:[NSString stringWithFormat:@"%@",readsFileName]];
    [readLenLbl setText:[NSString stringWithFormat:@"%@%i",kReadLengthLblStart,readLen]];
    
    double coverage = (double)((double)numOfReads * readLen)/(double)genomeLen;
    
    [genomeCoverageLbl setText:[NSString stringWithFormat:@"%@%.02fx",kGenomeCoverageLblStart,coverage]];
    mutPosArray = [[NSMutableArray alloc] init];
    allMutPosArray = [[NSMutableArray alloc] init];
    
    [readNumOfLbl setText:[NSString stringWithFormat:@"%@%i",kNumOfReadsLblStart,numOfReads]];
    [readPercentMatchedLbl setText:[NSString stringWithFormat:@"%@%1.0f%%",kReadPercentMatchedLblStart, ((float)numOfReadsMatched/numOfReads)*100.0f]];
    
    [totalNumOfMutsLbl setText:[NSString stringWithFormat:@"%@%i",kTotalNumOfMutsLblStart,[mutPosArray count]]];
    
    mutationSupportStpr.value = bwt.bwtMutationFilter.kHeteroAllowance;
    [mutationSupportNumLbl setText:[NSString stringWithFormat:@"%i",(int)mutationSupportStpr.value]];
    
    if ([GlobalVars isOldIPhone]) {
        CGRect rect = gridView.frame;
        gridView.frame = CGRectMake(rect.origin.x, rect.origin.y, self.view.frame.size.width-rect.origin.x, rect.size.height);
        rect = pxlOffsetSlider.frame;
        pxlOffsetSlider.frame = CGRectMake(rect.origin.x, rect.origin.y, self.view.frame.size.width-rect.origin.x, rect.size.height);
    }
    
    [self performSelector:@selector(setUpGridLbls) withObject:nil afterDelay:0];
    
    [gridViewTitleLblHolder.layer setBorderWidth:kGridViewTitleLblHolderBorderWidth];
    //Set up gridView
    int len = dgenomeLen-1;//-1 so to not include $ sign
    
    [gridView setDelegate:self];
    gridView.refSeq = originalStr;
    [gridView setUpWithNumOfRows:kNumOfRowsInGridView andCols:len andGraphBoxHeight:graphRowHeight];
    [pxlOffsetSlider setMaximumValue:((gridView.totalCols*(gridView.kGridLineWidthCol+gridView.boxWidth))/gridView.numOfBoxesPerPixel)-gridView.frame.size.width];
    [self mutationSupportStepperChanged:mutationSupportStpr];
}

- (void)setUpGridLbls {
    CGRect rect = CGRectMake(0, 0, kSideLblW, kSideLblH);
    
    NSArray *txtArr = [[NSArray alloc] initWithObjects:@"Cov",@"Ref",@"Qry",@"A",@"C",@"G",@"T",@"-",@"+", nil];
    
    int yPos = gridView.frame.origin.y+kPosLblHeight+(gridView.graphBoxHeight/2);
    
    for (int i  = 0; i<kNumOfRowsInGridView; i++) {
        nLbl[i] = [[UILabel alloc] initWithFrame:rect];
        [nLbl[i] setFont:[UIFont systemFontOfSize:kSideLblFontSize]];
        [nLbl[i] setAdjustsFontSizeToFitWidth:NO];
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
    if (!analysisControllerIPhoneToolbar.hidden)
        [self.view bringSubviewToFront:analysisControllerIPhoneToolbar];
}

//Interactive UI Elements besides gridview
- (IBAction)posSearch:(id)sender {
    int i = [posSearchTxtFld.text doubleValue];
    if (i > 0 && i<= dgenomeLen) {//is a valid number
        [gridView scrollToPos:i-1];//converts it to the normal scale where pos 0 is 0
    }
    [posSearchTxtFld resignFirstResponder];
    if (![GlobalVars isIpad])
        analysisControllerIPhoneToolbar.hidden = YES;
}

- (IBAction)seqSearch:(id)sender {
    if (![seqSearchTxtFld.text isEqualToString:@""]) {//is not an empty query
        querySeqPosArr = [[NSArray alloc] initWithArray:[bwt simpleSearchForQuery:(char*)[seqSearchTxtFld.text.uppercaseString UTF8String]]];
        int c = [querySeqPosArr count];
        if (c>0) {//At least one match
            
            int diff = INT_MAX;
            int closestPos = INT_MAX;
            int possiblePos;
            int currPos = [gridView firstPtToDrawForOffset:gridView.currOffset];
            for (int i = 0; i < c; i++) {
                possiblePos = [[querySeqPosArr objectAtIndex:i] intValue];
                if (possiblePos < currPos)
                    diff = (genomeLen-currPos-1)+possiblePos;
                else
                    diff = possiblePos-currPos;
                if (closestPos > currPos && diff<abs(closestPos-currPos) && diff != 0)//lowest diff and Not same exact pos
                    closestPos = possiblePos;
                else if (closestPos < currPos && diff<abs(closestPos+(genomeLen-currPos-1)) && diff != 0)
                    closestPos = possiblePos;
                if (diff == 1/* || (possiblePos<currPos && diff > abs(closestPos-currPos))*/)
                    break;
            }
            [gridView scrollToPos:closestPos];
        }
        else {
            //Show an error
        }
    }
    [seqSearchTxtFld resignFirstResponder];
    if (![GlobalVars isIpad])
        analysisControllerIPhoneToolbar.hidden = YES;
}

- (IBAction)showSeqSearchResults:(id)sender {
    SearchQueryResultsPopover *sq = [[SearchQueryResultsPopover alloc] init];
    [sq setDelegate:self];
    [sq loadWithResults:querySeqPosArr];
    
    
    popoverController = [[UIPopoverController alloc] initWithContentViewController:sq];
    [popoverController presentPopoverFromRect:showQueryResultsBtn.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (IBAction)showMutTBView:(id)sender {
    if ([GlobalVars isIpad]) {
        popoverController = [[UIPopoverController alloc] initWithContentViewController:mutsPopover];
        [popoverController presentPopoverFromRect:showMutTBViewBtn.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    else {
        [self presentViewController:mutsPopover animated:YES completion:nil];
    }
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
    [mutsPopover setUpWithMutationsArr:mutPosArray andCumulativeGenomeLenArr:cumulativeSeparateGenomeLens andGenomeFileNameArr:separateGenomeNames];
    
//    [gridView clearAllPoints];
    [gridView setUpGridViewForPixelOffset:gridView.currOffset];
    
    [totalNumOfMutsLbl setText:[NSString stringWithFormat:@"%@%i",kTotalNumOfMutsLblStart,[mutPosArray count]]];
}

//Mutation Info Popover Delegate
- (void)mutationAtPosPressedInPopover:(int)pos {
    [popoverController dismissPopoverAnimated:YES];
    [gridView scrollToPos:pos-1];
    if (![GlobalVars isIpad])
        analysisControllerIPhoneToolbar.hidden = YES;
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

-(void)pinchOccurred:(UIPinchGestureRecognizer*)sender {
    BOOL scaleOccurred = FALSE;
    double s = [sender scale];
    
    float gridViewW = gridView.bounds.size.width;
    
    //PROBLEM IS THAT KTXTFONTSIZE IS TOO BIG WHEN BOX WIDTH IS TOO SMALL
    if (s > 1.0f /*&& (gridView.kTxtFontSize < (([GlobalVars isIpad]) ? kDefaultTxtFontSizeIPad : kDefaultTxtFontSizeIPhone)) */&& (gridView.boxWidth < (([GlobalVars isIpad]) ? kDefaultIpadBoxWidth : kDefaultIphoneBoxWidth))) {//Zoom in
        scaleOccurred = TRUE;
        
        if (nLbl[0].hidden && gridView.kTxtFontSize >= gridView.kMinTxtFontSize && gridView.boxWidth >= kThresholdBoxWidth)
            for (int i = 0; i < kNumOfRowsInGridView; i++)
                nLbl[i].hidden = NO;
    }
    else if (s < 1.0f) {//Zoom out
        
        if (gridView.numOfBoxesPerPixel > kPixelWidth) {
            int potentialNewNumOfBoxesPerPixel = 1.0f/(gridView.boxWidthDecimal*s*kBoxWidthMultFactor);
            if (gridView.totalCols/gridView.numOfBoxesPerPixel < gridViewW || gridView.totalCols/potentialNewNumOfBoxesPerPixel < gridViewW)
                return;
        }
        
        scaleOccurred = TRUE;
        
        if (!(gridView.kTxtFontSize >= gridView.kMinTxtFontSize && gridView.boxWidth >= kThresholdBoxWidth) && !nLbl[0].hidden)
            for (int i = 0; i < kNumOfRowsInGridView; i++)
                nLbl[i].hidden = YES;
    }
    if (scaleOccurred) {
        float proportion = (gridView.currOffset+gridViewW/2)/gridView.scrollingView.contentSize.width;
    
//            [gridView setBoxWidth:ceilf(gridView.boxWidth*kBoxWidthMultFactor*sender.scale)];
        [gridView setBoxWidth:gridView.boxWidthDecimal*kBoxWidthMultFactor*sender.scale];
    
        double w = ([GlobalVars isIpad]) ? kDefaultIpadBoxWidth : kDefaultIphoneBoxWidth;
        double f = ([GlobalVars isIpad]) ? kDefaultTxtFontSizeIPad : kDefaultTxtFontSizeIPhone;
        if (gridView.boxWidth > w) {
            gridView.boxWidth = w;
            gridView.kTxtFontSize = f;
        }
        if (gridView.boxWidth < kMinBoxWidth) {
            [gridView setBoxWidth:kMinBoxWidth];
            gridView.kTxtFontSize = gridView.kMinTxtFontSize;
        }
        gridView.kTxtFontSize *= (kFontSizeMultFactor*sender.scale);
        if (gridView.kTxtFontSize > f)
            gridView.kTxtFontSize = f;
        
        if (gridView.boxWidth >= kThresholdBoxWidth && gridView.kTxtFontSize < gridView.kMinTxtFontSize)
            gridView.kTxtFontSize = gridView.kMinTxtFontSize;
    
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);//Creates background queue
        dispatch_sync(queue, ^{//Opens up a background thread, done synchronously because this block needs to finish before this function gets called again (often times it will be)
            [gridView resetScrollViewContentSize];
            [gridView resetTickMarkInterval];
            
            [pxlOffsetSlider setMaximumValue:((gridView.totalCols*(gridView.kGridLineWidthCol+gridView.boxWidth))/gridView.numOfBoxesPerPixel)-gridView.bounds.size.width];
            gridView.currOffset = (gridView.scrollingView.contentSize.width*proportion)-gridViewW/2;
            if (gridView.currOffset < 0)
                gridView.currOffset = gridView.boxWidth;//Goes to second box to avoid drawing issues
            else if (gridView.currOffset > gridView.scrollingView.contentSize.width-gridViewW-1)
                gridView.currOffset = gridView.scrollingView.contentSize.width-gridViewW-1;
            
            dispatch_async(dispatch_get_main_queue(), ^{
//                [gridView setUpGridViewForPixelOffset:gridView.currOffset];
                gridView.shouldUpdateScrollView = TRUE;
                [gridView.scrollingView setContentOffset:CGPointMake(gridView.currOffset,0) animated:NO];
                if (gridView.shouldUpdateScrollView)
                    [gridView setUpGridViewForPixelOffset:gridView.currOffset];
            });
        });
    }
}

//Single Tap (Treated as a button tap)
- (void)singleTapOccured:(UITapGestureRecognizer*)sender {
    CGPoint pt = [sender locationInView:gridView];
    
    //Get the xCoord in the scrollView
    double xCoord = gridView.currOffset+pt.x;
    
    //Find the box that was clicked
    CGPoint box = CGPointMake([gridView firstPtToDrawForOffset:xCoord],(int)((pt.y-(kPosLblHeight+graphRowHeight))/(kGridLineWidthRow+gridView.boxHeight)));//Get the tapped box
    
    [self gridPointClickedWithCoordInGrid:box andClickedPt:pt];
}

//Coverage Histogram
- (IBAction)showCoverageHistogram:(id)sender {
    if ([GlobalVars isIpad]) {
        popoverController = [[UIPopoverController alloc] initWithContentViewController:coverageHistogram];
        [popoverController presentPopoverFromBarButtonItem:coverageHistogramBtn permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        [coverageHistogram createHistogramWithMaxCovVal:gridView.maxCoverageVal];
    }
    else
        [self presentViewController:coverageHistogram animated:YES completion:^{
            [coverageHistogram createHistogramWithMaxCovVal:gridView.maxCoverageVal];
        }];
}

//Grid view delegate
- (void)gridPointClickedWithCoordInGrid:(CGPoint)c andClickedPt:(CGPoint)o {
    if (gridView.boxWidth < kThresholdBoxWidth)
        return;
    UIViewController *vc;
    if (c.y == kNumOfRowsInGridView-2 /*-2 is because of grid and because the normal use of size-1*/ && posOccArray[kACGTLen+1][(int)c.x] > 0/*there is at least one insertion there*/) {
        InsertionsPopoverController *ipc = [[InsertionsPopoverController alloc] init];
        [ipc setInsArr:insertionsArr forPos:(int)c.x];
        
        ipc.contentSizeForViewInPopover = CGSizeMake(kInsPopoverW, kInsPopoverH);
        
        vc = ipc;
        if (![GlobalVars isIpad])
            [self presentViewController:ipc animated:YES completion:nil];
//        popoverController = [[UIPopoverController alloc] initWithContentViewController:ipc];
        
        if ([GlobalVars isIpad]) {
            popoverController = [[UIPopoverController alloc] initWithContentViewController:vc];
            CGRect rect = CGRectMake(c.x*(gridView.boxWidth+gridView.kGridLineWidthCol)-gridView.currOffset, c.y*(gridView.boxHeight+kGridLineWidthRow)+graphRowHeight+kPosLblHeight, gridView.boxWidth, gridView.boxHeight);
            
            [popoverController presentPopoverFromRect:rect inView:gridView permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
        }
    }
    else {
        AnalysisPopoverController *apc = [[AnalysisPopoverController alloc] init];
        apc.contentSizeForViewInPopover = CGSizeMake(kAnalysisPopoverW, kAnalysisPopoverH);
        
        vc = apc;
        if (![GlobalVars isIpad])
            [self presentViewController:apc animated:YES completion:nil];
        //        popoverController = [[UIPopoverController alloc] initWithContentViewController:apc];
        apc.position = c.x+1;
        
        for (int i = [cumulativeSeparateGenomeLens count]-1; i >= 0; i--) {
            int len = [[cumulativeSeparateGenomeLens objectAtIndex:i] intValue];
            if (c.x < len)
                apc.segment = [separateGenomeNames objectAtIndex:i];
            else
                break;
        }
        [apc updateLbls];
        
        NSMutableString *heteroStr = [[NSMutableString alloc] initWithString:@"Hetero: "];
        
        for (int i = 1; i<kACGTLen+2; i++) {
            [heteroStr appendFormat:@" %c",foundGenome[i][(int)c.x]];
        }
        
        apc.heteroStr = heteroStr;
        apc.heteroLbl.text = heteroStr;
        
        if ([GlobalVars isIpad]) {
            popoverController = [[UIPopoverController alloc] initWithContentViewController:vc];
            CGRect rect = CGRectMake(c.x*(gridView.boxWidth+gridView.kGridLineWidthCol)-gridView.currOffset, c.y*(gridView.boxHeight+kGridLineWidthRow)+graphRowHeight+kPosLblHeight, gridView.boxWidth, gridView.boxHeight);
            
            [popoverController presentPopoverFromRect:rect inView:gridView permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
        }
    }
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
        [mutsPopover setUpWithMutationsArr:[BWT_MutationFilter filteredMutations:mutPosArray forHeteroAllowance:mutationSupportStpr.value] andCumulativeGenomeLenArr:cumulativeSeparateGenomeLens andGenomeFileNameArr:separateGenomeNames];
        mutsPopoverAlreadyUpdated = !mutsPopoverAlreadyUpdated;
    }
    
    pxlOffsetSlider.value = currOffset;//a little bit of a prob here
}

- (NSArray*)getCumulativeSeparateGenomeLenArray {
    return cumulativeSeparateGenomeLens;
}

- (NSString*)genomeSegmentNameForIndexInGenomeNameArr:(int)index {
    return separateGenomeNames[index];
}

- (void)shouldUpdateGenomeNameLabelForIndexInSeparateGenomeLenArray:(int)index {
    genomeFileSegmentNames = [separateGenomeNames objectAtIndex:index];
    [genomeNameLbl setText:genomeFileSegmentNames];
}

//Exports data

- (IBAction)exportDataPressed:(id)sender {
    [fileExporter setMutSupportVal:(int)mutationSupportStpr.value+1/*Mutation support is computed using posOccArr[x]i] > kHeteroAllowance, so for solely greater than, it needs to add one for the sentence in the message to make sense*/ andMutPosArray:mutPosArray];
    [fileExporter displayExportOptionsWithSender:sender];
}

//Return to main menu
- (IBAction)donePressed:(id)sender {
    confirmDoneAlert = [[UIAlertView alloc] initWithTitle:kConfirmDoneAlertTitle message:kConfirmDoneAlertMsg delegate:self cancelButtonTitle:kConfirmDoneAlertCancelBtn otherButtonTitles:kConfirmDoneAlertGoBtn, nil];
    [confirmDoneAlert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView isEqual:confirmDoneAlert]) {
        if (buttonIndex == kConfirmDoneAlertGoBtnIndex)
             [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

//Success box
- (void)displaySuccessBox {
    UIImageView *successBox = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kSuccessBoxImgName]];
    successBox.frame = CGRectMake(0, 0, successBox.image.size.width, successBox.image.size.height);
    successBox.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    successBox.alpha = kSuccessBoxAlpha;
    [self.view addSubview:successBox];
    [UIView animateWithDuration:kSuccessBoxDuration animations:^{
        [successBox setAlpha:0.0f];
    } completion:^(BOOL finished){
        [successBox removeFromSuperview];
    }];
}

- (UIViewController*)getVC {
    return self;
}

//Iphone Support

- (IBAction)displayAnalysisIPhoneToolbar:(id)sender {
    analysisControllerIPhoneToolbar.hidden = NO;
    [self.view bringSubviewToFront:analysisControllerIPhoneToolbar];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

//Memory warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
