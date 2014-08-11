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
    
    covGridView = [[CoverageGridView alloc] initWithFrame:gridView.frame];
    alignmentGridView = [[AlignmentGridView alloc] initWithFrame:gridView.frame];
    [self.view addSubview:covGridView];
    [self.view addSubview:alignmentGridView];
    
    [covGridView firstSetUp];
    [alignmentGridView firstSetUp];
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapOccured:)];
    tapRecognizer.numberOfTapsRequired = kNumOfTapsRequiredToDisplayAnalysisPopover;
    
    pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchOccurred:)];
    
    mutationSupportStpr.maximumValue = kMutationSupportMax;
    mutationSupportStpr.minimumValue = kMutationSupportMin;
    
    [self resetDisplay];
    [self resetGridViewForType:alignmentGridView];
    [super viewDidLoad];

    hamburgerMenuController = [[HamburgerMenuController alloc] initWithCentralController:self andSlideOutController:analysisControllerIPadMenu];
//    [self setUpIPhoneToolbar];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    if (!firstAppeared) {
        [self setUpIPhoneToolbar];
        [analysisControllerIPadToolbar setUp];
        firstAppeared = TRUE;
        if (gridView.maxCoverageVal == 0)
            [gridView setMaxCovValWithNumOfCols:dgenomeLen-1];
        if ([GlobalVars isIpad])
            coverageHistogram.view.frame = CGRectMake(0, 0, kCoverageHistogramPopoverWidth, kCoverageHistogramPopoverHeight);
        [coverageHistogram createHistogramWithMaxCovVal:gridView.maxCoverageVal];
        [analysisControllerIPadMenu setCoverageHistogram:coverageHistogram];
    }
//    [analysisControllerIPhoneToolbar setDelegate:self];
//    
//    CGRect rect = self.view.bounds;
//    [analysisControllerIPhoneToolbar setBounds:rect];
//    [analysisControllerIPhoneToolbar setFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
//    [self.view addSubview:analysisControllerIPhoneToolbar];
//    [self.view layoutIfNeeded];
//    [self.view bringSubviewToFront:analysisControllerIPhoneToolbar];
//    analysisControllerIPhoneToolbar.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    
    //Fixes problems caused by constraints on old iPhone
    gridView.scrollingView.frame = CGRectMake(0, 0, gridView.frame.size.width, gridView.frame.size.height);
    gridView.drawingView.frame = gridView.scrollingView.frame;
    [pxlOffsetSlider setMaximumValue:((gridView.totalCols*(gridView.kGridLineWidthCol+gridView.boxWidth))/gridView.numOfBoxesPerPixel)-gridView.frame.size.width];
    [gridView setUpGridViewForPixelOffset:gridView.currOffset];
    
//    analysisControllerIPadMenu = [[AnalysisControllerIPadMenu alloc] init];
}

- (void)readyViewForDisplay:(char*)unraveledStr andInsertions:(NSMutableArray *)iArr andBWT:(BWT *)myBwt andExportData:(NSString*)exportDataString andBasicInfo:(NSArray*)basicInfArr andSeparateGenomeNamesArr:(NSMutableArray *)sepGNA andSeparateGenomeLensArr:(NSMutableArray *)sepGLA andCumulativeGenomeLensArr:(NSMutableArray *)cGLA andImptMutsFileContents:(NSString *)mutsFileContents {
    NSLog(@"About to ready view for display");
    
    originalStr = unraveledStr;
    insertionsArr = iArr;
    bwt = myBwt;
    exportDataStr = exportDataString;
    imptMutsFileContents = mutsFileContents;
    
    coverageHistogram = [[CoverageHistogram alloc] init];
    
    //genome file name, reads file name, read length, genome length, number of reads
    genomeFileSegmentNames = [basicInfArr objectAtIndex:kBasicInfoArrGenomeFileNameIndex];
    readsFileName = [basicInfArr objectAtIndex:kBasicInfoArrReadsFileNameIndex];
    readLen = [[basicInfArr objectAtIndex:kBasicInfoArrReadLenIndex] intValue];
    genomeLen = [[basicInfArr objectAtIndex:kBasicInfoArrGenomeLenIndex] intValue];
    numOfReads = [[basicInfArr objectAtIndex:kBasicInfoArrNumOfReadsIndex] intValue];
    editDistance = [[basicInfArr objectAtIndex:kBasicInfoArrEDIndex] intValue];
    numOfReadsMatched = [[basicInfArr objectAtIndex:kBasicInfoArrNumOfReadsMatchedIndex] intValue];
    bwt.bwtMutationFilter.kHeteroAllowance = [[basicInfArr objectAtIndex:kBasicInfoArrMutationSupportIndex] intValue];
    
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

- (void)readyViewForCovProfile {
    [self resetGridViewForType:covGridView];
}

- (void)readyViewForAlignments {
    [self resetGridViewForType:alignmentGridView];
}

- (void)readyViewCalledBySegPickerView:(int)indexToScrollTo {
    gridView.indexInGenomeNameArr = indexToScrollTo;
    currSegmentLbl.text = [separateGenomeNames objectAtIndex:gridView.indexInGenomeNameArr];
    if (gridView.indexInGenomeNameArr > 0)
        [gridView scrollToPos:[[cumulativeSeparateGenomeLens objectAtIndex:gridView.indexInGenomeNameArr-1] intValue] inputtedByPosSearchField:NO];
    else
        [gridView scrollToPos:1 inputtedByPosSearchField:NO];//1 because it is interpreted as if it were "user-inputted"
}

- (void)scrollToPos:(int)pos {
    [gridView scrollToPos:pos inputtedByPosSearchField:NO];
}

- (IBAction)gridViewSwitcherCtrlValChanged:(id)sender {
    if (gridViewSwitcherCtrl.selectedSegmentIndex == kGridViewSwitcherCtrlAlignmentsIndex)
        [self resetGridViewForType:alignmentGridView];
    else if (gridViewSwitcherCtrl.selectedSegmentIndex == kGridViewSwitcherCtrlCovProfileIndex)
        [self resetGridViewForType:covGridView];
    [self.view bringSubviewToFront:analysisControllerIPhoneToolbar];
}

- (void)resetGridViewForType:(QuickGridView *)gViewType {
    gridView.scrollingView.minimumZoomScale = 0.5f;
    [gridView removeGestureRecognizer:tapRecognizer];
    [gridView.scrollingView removeGestureRecognizer:[gridView.scrollingView pinchGestureRecognizer]];
    
    [pxlOffsetSlider removeTarget:gridView action:@selector(pxlOffsetSliderValChanged:) forControlEvents:UIControlEventValueChanged];
    gridView = gViewType;
    
    [gridView addGestureRecognizer:tapRecognizer];
    [gridView.scrollingView addGestureRecognizer:pinchRecognizer];
    
    if ([gViewType isEqual:covGridView]) {
        covGridView.hidden = NO;
        alignmentGridView.hidden = YES;
        gridViewSwitcherCtrl.selectedSegmentIndex = kGridViewSwitcherCtrlCovProfileIndex;
    }
    else if ([gViewType isEqual:alignmentGridView]) {
        alignmentGridView.hidden = NO;
        covGridView.hidden = YES;
        gridViewSwitcherCtrl.selectedSegmentIndex = kGridViewSwitcherCtrlAlignmentsIndex;
    }
    
    [pxlOffsetSlider addTarget:gridView action:@selector(pxlOffsetSliderValChanged:) forControlEvents:UIControlEventValueChanged];
    [pxlOffsetSlider setMaximumValue:((gridView.totalCols*(gridView.kGridLineWidthCol+gridView.boxWidth))/gridView.numOfBoxesPerPixel)-gridView.frame.size.width];
    pxlOffsetSlider.value = gridView.currOffset;
    [self.view bringSubviewToFront:pxlOffsetSlider];
    
    [segmentPckr selectRow:gridView.indexInGenomeNameArr inComponent:0 animated:NO];
    currSegmentLbl.text = [separateGenomeNames objectAtIndex:gridView.indexInGenomeNameArr];
}

- (void)resetDisplay {
    //Set up info lbls
    [genomeNameLbl setText:genomeFileName];
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
    
    if ([GlobalVars isOldIPhone]) {
        CGRect rect = gridView.frame;
        gridView.frame = CGRectMake(rect.origin.x, rect.origin.y, self.view.frame.size.width-rect.origin.x, rect.size.height);
        rect = pxlOffsetSlider.frame;
        pxlOffsetSlider.frame = CGRectMake(rect.origin.x, rect.origin.y, self.view.frame.size.width-rect.origin.x, rect.size.height);
    }
    
    currSegmentLbl.text = [separateGenomeNames objectAtIndex:0];
    
    [gridViewTitleLblHolder.layer setBorderWidth:kGridViewTitleLblHolderBorderWidth];
    //Set up gridView
    int len = dgenomeLen-1;//-1 so to not include $ sign
    
    [covGridView setDelegate:self];
    [alignmentGridView setDelegate:self];
    [covGridView setUpWithNumOfRows:kNumOfRowsInGridView andCols:len andGraphBoxHeight:graphRowHeight andDoInitialMutationFind:YES];
    [alignmentGridView setUpWithNumOfRows:kNumOfRowsInGridView andCols:len andGraphBoxHeight:graphRowHeight andDoInitialMutationFind:NO];

    gridView = covGridView;
//    [gridView setDelegate:self];
//    [gridView setUpWithNumOfRows:kNumOfRowsInGridView andCols:len andGraphBoxHeight:graphRowHeight];
    [self performSelector:@selector(setUpGridLbls) withObject:nil afterDelay:0];
    [pxlOffsetSlider setMaximumValue:((gridView.totalCols*(gridView.kGridLineWidthCol+gridView.boxWidth))/gridView.numOfBoxesPerPixel)-gridView.frame.size.width];
    [self mutationSupportStepperChanged:mutationSupportStpr];
}

- (void)setUpGridLbls {
    CGRect rect = CGRectMake(0, 0, kSideLblW, kSideLblH);
    
    NSArray *txtArr = [[NSArray alloc] initWithObjects:@"Cov",@"Ref",@"Qry",@"A",@"C",@"G",@"T",@"-",@"+", nil];
    
    int yPos = gridView.frame.origin.y+kPosLblHeight+(gridView.graphBoxHeight/2);
    
    for (int i  = 0; i<gridView.totalRows; i++) {
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
    if ([gridView scrollToPos:i-1 inputtedByPosSearchField:YES]) {//converts it to the normal scale where pos 0 is 0
        if (![GlobalVars isIpad])
            analysisControllerIPhoneToolbar.hidden = YES;
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kPosSearchPosOutOfRangeAlertTitle message:kPosSearchPosOutOfRangeAlertMsg delegate:self cancelButtonTitle:kPosSearchPosOutOfRangeAlertBtn otherButtonTitles:nil];
        [alert show];
    }
    [posSearchTxtFld resignFirstResponder];
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
            [gridView scrollToPos:closestPos inputtedByPosSearchField:NO];
            if (![GlobalVars isIpad])
                analysisControllerIPhoneToolbar.hidden = YES;
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kSeqSearchNoResultsAlertTitle message:kSeqSearchNoResultsAlertMsg delegate:self cancelButtonTitle:kSeqSearchNoResultsAlertDoneBtn otherButtonTitles:nil];
            [alert show];
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

#pragma Segment Stpr Picker

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//    gridView.indexInGenomeNameArr = (int)row;
//    currSegmentLbl.text = [separateGenomeNames objectAtIndex:gridView.indexInGenomeNameArr];
//    if (gridView.indexInGenomeNameArr > 0)
//        [gridView scrollToPos:[[cumulativeSeparateGenomeLens objectAtIndex:gridView.indexInGenomeNameArr-1] intValue] inputtedByPosSearchField:NO];
//    else
//        [gridView scrollToPos:1 inputtedByPosSearchField:NO];//1 because it is interpreted as if it were "user-inputted"
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [separateGenomeNames objectAtIndex:row];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [separateGenomeNames count];
}

- (IBAction)showMutTBView:(id)sender {
    if ([allMutPosArray count] == 0) {
        [GlobalVars displayiGenomicsAlertWithMsg:kMutationsPopoverNoMutationsAlertMsg];
        return;
    }
    if ([GlobalVars isIpad]) {
        mutsPopover.preferredContentSize = mutsPopover.view.bounds.size;
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
    
    [bwt.bwtMutationFilter resetFoundGenome];
    [bwt.bwtMutationFilter buildOccTableWithUnravStr:originalStr];
    [bwt.bwtMutationFilter filterMutationsForDetails];
    
    mutPosArray = [BWT_MutationFilter filteredMutations:allMutPosArray forHeteroAllowance:val];
//    [gridView initialMutationFind];
    
    [mutsPopover setUpWithMutationsArr:mutPosArray andCumulativeGenomeLenArr:cumulativeSeparateGenomeLens andGenomeFileNameArr:separateGenomeNames];
    
//    [gridView clearAllPoints];
    [gridView setUpGridViewForPixelOffset:gridView.currOffset];
    
    [totalNumOfMutsLbl setText:[NSString stringWithFormat:@"%@%i",kTotalNumOfMutsLblStart,[mutPosArray count]]];
    
    imptMutationsArr = [BWT_MutationFilter compareFoundMutationsArr:mutPosArray toImptMutationsString:imptMutsFileContents andCumulativeLenArr:cumulativeSeparateGenomeLens andSegmentNameArr:separateGenomeNames];
    [analysisControllerIPhoneToolbar.imptMutsDispView setUpWithMutationsArray:imptMutationsArr];
}

//Mutation Info Popover Delegate
- (void)mutationAtPosPressedInPopover:(int)pos {
    [popoverController dismissPopoverAnimated:YES];
    [gridView scrollToPos:pos-1 inputtedByPosSearchField:NO];
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
    [gridView scrollToPos:pos inputtedByPosSearchField:YES];
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

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);//Creates background queue
        dispatch_sync(queue, ^{//Opens up a background thread, done synchronously because this block needs to finish before this function gets called again (often times it will be)
            
            CGPoint prevOffset = gridView.scrollingView.contentOffset;
            
            [gridView resetScrollViewContentSize];
            [gridView resetTickMarkInterval];
            
            gridView.currOffset = (gridView.scrollingView.contentSize.width*proportion)-gridViewW/2;
            if (gridView.currOffset < 0)
                gridView.currOffset = gridView.boxWidth;//Goes to second box to avoid drawing issues
            else if (gridView.currOffset > gridView.scrollingView.contentSize.width-gridViewW-1)
                gridView.currOffset = gridView.scrollingView.contentSize.width-gridViewW-1;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [pxlOffsetSlider setMaximumValue:((gridView.totalCols*(gridView.kGridLineWidthCol+gridView.boxWidth))/gridView.numOfBoxesPerPixel)-gridViewW];
                gridView.shouldUpdateScrollView = TRUE;
                [gridView.scrollingView setContentOffset:CGPointMake(gridView.currOffset, 0)];
                pxlOffsetSlider.value = gridView.currOffset;
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

//Cov Histogram
- (IBAction)showCoverageHistogram:(id)sender {
    if (gridView.maxCoverageVal == 0)
        [gridView setMaxCovValWithNumOfCols:dgenomeLen-1];
    if (numOfReadsMatched == 0) {
        [GlobalVars displayiGenomicsAlertWithMsg:kCoverageHistogramNoReadsAlignedAlertMsg];
        return;
    }
    if ([GlobalVars isIpad]) {
        if (popoverController.isPopoverVisible)
            [popoverController dismissPopoverAnimated:YES];
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
    /*if (c.y == kNumOfRowsInGridView-2 /*-2 is because of grid and because the normal use of size-1 && posOccArray[kACGTLen+1][(int)c.x] > 0/*there is at least one insertion there) {
        InsertionsPopoverController *ipc = [[InsertionsPopoverController alloc] init];
        [ipc setInsArr:insertionsArr forPos:(int)c.x];
        
        ipc.preferredContentSize = CGSizeMake(kInsPopoverW, kInsPopoverH);
        
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
    else {*/
        AnalysisPopoverController *apc = [[AnalysisPopoverController alloc] init];
        apc.preferredContentSize = apc.view.bounds.size;
        
        vc = apc;
        if (![GlobalVars isIpad])
            [self presentViewController:apc animated:YES completion:nil];
        //        popoverController = [[UIPopoverController alloc] initWithContentViewController:apc];
        
        int index = [cumulativeSeparateGenomeLens count]-1;
        for (int i = [cumulativeSeparateGenomeLens count]-1; i >= 0; i--) {
            int len = [[cumulativeSeparateGenomeLens objectAtIndex:i] intValue];
            if (c.x < len) {
                apc.segment = [separateGenomeNames objectAtIndex:i];
                index--;
            }
            else
                break;
        }
        
        int amountToSub = (index >= 0) ? [[cumulativeSeparateGenomeLens objectAtIndex:index] intValue] : 0;
        apc.displayedPos = c.x+1-amountToSub;
        apc.position = c.x;
        
        if (posOccArray[kACGTLen+1][(int)c.x] > 0)
            [apc setInsertionsArray:insertionsArr];
        
        [apc updateLbls];
        
        NSMutableString *heteroStr = [[NSMutableString alloc] initWithString:@"Hetero: "];
        
        for (int i = 1; i<kACGTwithInDelsLen; i++) {
            [heteroStr appendFormat:@" %c",foundGenome[i][(int)c.x]];
        }
        
        apc.heteroStr = heteroStr;
        apc.heteroLbl.text = heteroStr;
        
        if ([GlobalVars isIpad]) {
            popoverController = [[UIPopoverController alloc] initWithContentViewController:vc];
            CGRect rect = CGRectMake(c.x*(gridView.boxWidth+gridView.kGridLineWidthCol)-gridView.currOffset, c.y*(gridView.boxHeight+kGridLineWidthRow)+graphRowHeight+kPosLblHeight, gridView.boxWidth, gridView.boxHeight);
            
            [popoverController presentPopoverFromRect:rect inView:gridView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
}

- (void)mutationFoundAtPos:(int)pos {
    [allMutPosArray addObject:[NSNumber numberWithInt:pos]];
}

- (void)gridFinishedUpdatingWithOffset:(double)currOffset andGridScrollViewContentSizeChanged:(BOOL)sizeChanged {
    if (!mutsPopoverAlreadyUpdated) {
        mutsPopover = [[MutationsInfoPopover alloc] init];
        [mutsPopover setDelegate:self];
        if ([mutPosArray count] == 0)
            mutPosArray = [[NSMutableArray alloc] initWithArray:allMutPosArray];
        [mutsPopover setUpWithMutationsArr:[BWT_MutationFilter filteredMutations:mutPosArray forHeteroAllowance:mutationSupportStpr.value] andCumulativeGenomeLenArr:cumulativeSeparateGenomeLens andGenomeFileNameArr:separateGenomeNames];
        mutsPopoverAlreadyUpdated = !mutsPopoverAlreadyUpdated;
    }
    if (!sizeChanged)
        pxlOffsetSlider.value = currOffset;
//    pxlOffsetSlider.value = currOffset;//a little bit of a prob here
}

- (NSArray*)getCumulativeSeparateGenomeLenArray {
    return cumulativeSeparateGenomeLens;
}

- (NSString*)genomeSegmentNameForIndexInGenomeNameArr:(int)index {
    return separateGenomeNames[index];
}

- (void)shouldUpdateGenomeNameLabelForIndexInSeparateGenomeLenArray:(int)index {
    genomeFileSegmentNames = [separateGenomeNames objectAtIndex:index];
    gridView.indexInGenomeNameArr = index;
    [segmentPckr selectRow:index inComponent:0 animated:NO];
    currSegmentLbl.text = [separateGenomeNames objectAtIndex:index];
}

- (void)displayPopoverWithViewController:(UIViewController *)controller atPoint:(CGPoint)point {
    if ([GlobalVars isIpad]) {
        popoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        [popoverController presentPopoverFromRect:CGRectMake(point.x, point.y, 1, 1) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        [self presentViewController:controller animated:YES completion:nil];
    }
}

//Exports data

- (IBAction)exportDataPressed:(id)sender {
    [fileExporter setMutSupportVal:(int)mutationSupportStpr.value andMutPosArray:mutPosArray];
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

- (NSArray*)getCumulativeLenArray {
    return cumulativeSeparateGenomeLens;
}

- (NSArray*)getSeparateGenomeSegmentNamesArray {
    return separateGenomeNames;
}

//Extra iPad Support
- (IBAction)showHamburgerMenu:(id)sender {
    if (hamburgerMenuController.menuOpen)
        [hamburgerMenuController closeHamburgerMenu];
    else
        [hamburgerMenuController openHamburgerMenu];
}

- (IBAction)showImportantMutationsPopover:(id)sender {
    if (popoverController.isPopoverVisible)
        return;
    UIViewController *controller = [[UIViewController alloc] init];
    UINib *myNib = [UINib nibWithNibName:kImportantMutationsDisplayViewNibName bundle:nil];
    ImportantMutationsDisplayView *myView = [[myNib instantiateWithOwner:self options:0] objectAtIndex:0];
    [myView setDelegate:self];
    [myView setUpWithMutationsArray:imptMutationsArr];
    controller.view = myView;
    controller.preferredContentSize = myView.bounds.size;
    popoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
    CGRect rect = showImportantMutationsBtn.frame;
    [popoverController presentPopoverFromRect:CGRectMake(rect.origin.x, rect.origin.y+rect.size.height, 1, 1) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}
//Impt muts disp view delegate start
- (void)importantMutationAtPosPressedInImptMutDispView:(int)pos {
    [self scrollToPos:pos];
}
//Impt muts disp view delegate end

- (IBAction)showCoverageProfileGridView:(id)sender {
    BOOL calledByPicker = [sender isEqual:showCoverageProfileSegmentPckrBtn];
    int index = 0;
    if (calledByPicker)
        index = (int)[segmentPckr selectedRowInComponent:0];
    [self resetGridViewForType:covGridView];
    if (calledByPicker)
        [self readyViewCalledBySegPickerView:index];
}
- (IBAction)showAlignmentsGridView:(id)sender {
    BOOL calledByPicker = [sender isEqual:showAlignmentViewSegmentPckrBtn];
    int index = 0;
    if (calledByPicker)
        index = (int)[segmentPckr selectedRowInComponent:0];
    [self resetGridViewForType:alignmentGridView];
    if (calledByPicker)
        [self readyViewCalledBySegPickerView:index];
}
//Iphone Support

- (IBAction)displayAnalysisIPhoneToolbar:(id)sender {
    analysisControllerIPhoneToolbar.hidden = NO;
    [self.view bringSubviewToFront:analysisControllerIPhoneToolbar];
}

- (void)setUpIPhoneToolbar {
    [analysisControllerIPhoneToolbar setDelegate:self];
    
    CGRect rect = self.view.bounds;
    [analysisControllerIPhoneToolbar setFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    [self.view addSubview:analysisControllerIPhoneToolbar];
    [analysisControllerIPhoneToolbar layoutIfNeeded];

    [analysisControllerIPhoneToolbar setUpWithImptMutationList:imptMutationsArr];
    [analysisControllerIPhoneToolbar setAlignmentSegmentPckrBtn:showAlignmentViewSegmentPckrBtn covProfileSegmentPckrBtn:showCoverageProfileSegmentPckrBtn];
    [analysisControllerIPhoneToolbar addDoneBtnForTxtFields:[NSArray arrayWithObjects:seqSearchTxtFld, posSearchTxtFld,nil]];
    [self.view bringSubviewToFront:analysisControllerIPhoneToolbar];
    analysisControllerIPhoneToolbar.hidden = NO;
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
