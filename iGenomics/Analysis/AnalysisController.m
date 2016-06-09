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
    [super viewDidLoad];
    
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

    if ([GlobalVars isIpad])
        hamburgerMenuController = [[HamburgerMenuController alloc] initWithCentralController:self andSlideOutController:analysisControllerIPadMenu];
}

- (void)viewWillAppear:(BOOL)animated {
    if (!firstAppeared) {
        [self resetDisplay];
        
        [self resetGridViewForType:alignmentGridView];
        
        [self setUpIPhoneToolbar];
        [analysisControllerIPadToolbar setUp];

        if (gridView.maxCoverageVal == 0)
            [gridView setMaxCovValWithNumOfCols:dgenomeLen-1];
        if ([GlobalVars isIpad])
            coverageHistogram.view.frame = CGRectMake(0, 0, kCoverageHistogramPopoverWidth, kCoverageHistogramPopoverHeight);
        else
            coverageHistogram.view.bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-kIPhonePopoverNavBarLandscapeHeight);
        [coverageHistogram createHistogramWithMaxCovVal:gridView.maxCoverageVal andNumOfReads:numOfReads andReadLen:readLen andGenomeLen:genomeLen];
        [analysisControllerIPadMenu setCoverageHistogram:(gridView.maxCoverageVal > 0) ? coverageHistogram : NULL];
        
        covGridView.frame = gridView.frame;
        covGridView.drawingView.frame = gridView.drawingView.frame;
        covGridView.scrollingView.frame = gridView.scrollingView.frame;
        
        alignmentGridView.frame = gridView.frame;
        alignmentGridView.drawingView.frame = gridView.drawingView.frame;
        alignmentGridView.scrollingView.frame = gridView.scrollingView.frame;
        
        [pxlOffsetSlider setMinimumValue:0];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [pxlOffsetSlider setMaximumValue:((gridView.totalCols*(gridView.kGridLineWidthCol+gridView.boxWidth))/gridView.numOfBoxesPerPixel)-gridView.frame.size.width];
    [gridView setUpGridViewForPixelOffset:gridView.currOffset];
    
    if ([GlobalVars isOldIPhone] && !firstAppeared) {
        [self setUpIPhoneToolbar];
    }
    
    firstAppeared = TRUE;
//    analysisControllerIPadMenu = [[AnalysisControllerIPadMenu alloc] init];
}

- (void)readyViewForDisplay:(char*)unraveledStr andInsertions:(NSMutableArray *)iArr andBWT:(BWT *)myBwt andExportData:(NSString*)exportDataString andBasicInfo:(NSArray*)basicInfArr andSeparateGenomeNamesArr:(NSMutableArray *)sepGNA andSeparateGenomeLensArr:(NSMutableArray *)sepGLA andCumulativeGenomeLensArr:(NSMutableArray *)cGLA andImptMutsFileContents:(NSString *)mutsFileContents andRefFile:(APFile*)refFile andTotalAlignmentRuntime:(float)totalAlRt {
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
    errorRate = [[basicInfArr objectAtIndex:kBasicInfoArrERIndex] floatValue];
    numOfReadsMatched = [[basicInfArr objectAtIndex:kBasicInfoArrNumOfReadsMatchedIndex] intValue];
    bwt.bwtMutationFilter.kHeteroAllowance = [[basicInfArr objectAtIndex:kBasicInfoArrMutationSupportIndex] intValue];
    
    //NOTE: This is a band-aid. It does not solve the root problem of passing in a weirdly coded string (fix this during the refactoring process)
    NSRange refFileDividerRange = [refFile.name rangeOfString:kRefFileInternalDivider];
    if ((int)refFileDividerRange.location != NSNotFound)
        genomeFileName = [refFile.name substringToIndex:refFileDividerRange.location];
    
    separateGenomeNames = sepGNA;
    separateGenomeLens = sepGLA;
    cumulativeSeparateGenomeLens = cGLA;
    
    totalAlignmentRuntime = totalAlRt;
    
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
    [fileExporter setGenomeFileName:genomeFileName andReadsFileName:readsFileName andErrorRate:errorRate andExportDataStr:exportDataStr andTotalAlignmentRuntime:totalAlignmentRuntime andTotalNumOfReads:numOfReads andTotalNumOfReadsAligned:numOfReadsMatched];
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
    currSegmentLenLbl.text = [NSString stringWithFormat:kCurrSegmentLenLblStart,[[separateGenomeLens objectAtIndex:gridView.indexInGenomeNameArr] intValue]];
    if (gridView.indexInGenomeNameArr > 0)
        [gridView scrollToPos:[[cumulativeSeparateGenomeLens objectAtIndex:gridView.indexInGenomeNameArr-1] intValue] inputtedByPosSearchField:NO];
    else
        [gridView scrollToPos:0 inputtedByPosSearchField:NO];
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
    currSegmentLenLbl.text = [NSString stringWithFormat:kCurrSegmentLenLblStart,[[separateGenomeLens objectAtIndex:gridView.indexInGenomeNameArr] intValue]];
    
    BOOL isCovGridView = [gridView isEqual:covGridView];
    if (gridView.kTxtFontSize >= gridView.kMinTxtFontSize && gridView.boxWidth >= kThresholdBoxWidth)
        for (int i = 0; i < kNumOfRowsInGridView; i++) {
            if (!isCovGridView && i >= ARow)
                nLbl[i].hidden = YES;
            else
                nLbl[i].hidden = NO;
        }
    else if (!(gridView.kTxtFontSize >= gridView.kMinTxtFontSize && gridView.boxWidth >= kThresholdBoxWidth))
        for (int i = 0; i < kNumOfRowsInGridView; i++)
            nLbl[i].hidden = YES;
    
    if ([GlobalVars isOldIPhone]) {
        CGRect rect = gridView.frame;
        float w = self.view.bounds.size.width;
        gridView.frame = CGRectMake(rect.origin.x, rect.origin.y, w-rect.origin.x, rect.size.height);
        gridView.scrollingView.frame = CGRectMake(0, 0, gridView.frame.size.width, gridView.frame.size.height);
        gridView.drawingView.frame = gridView.scrollingView.frame;
        
        rect = pxlOffsetSlider.frame;
        pxlOffsetSlider.frame = CGRectMake(rect.origin.x, rect.origin.y, w-rect.origin.x, rect.size.height);
    }
}

- (void)resetDisplay {
    //Set up info lbls
    [genomeNameLbl setText:genomeFileName];
    
    [readsNameLbl setText:[NSString stringWithFormat:@"%@",readsFileName]];
    
    mutPosArray = [[NSMutableArray alloc] init];
    allMutPosArray = [[NSMutableArray alloc] init];
    
    [readPercentMatchedLbl setText:[NSString stringWithFormat:@"%@%0.02 f%%",kReadPercentMatchedLblStart, ((float)numOfReadsMatched/numOfReads)*100.0f]];
    
    [totalNumOfMutsLbl setText:[NSString stringWithFormat:@"%@%i",kTotalNumOfMutsLblStart,[mutPosArray count]]];
    
    mutationSupportStpr.value = bwt.bwtMutationFilter.kHeteroAllowance;
    
    currSegmentLbl.text = [separateGenomeNames objectAtIndex:0];
    currSegmentLenLbl.text = [NSString stringWithFormat:kCurrSegmentLenLblStart,[[separateGenomeLens objectAtIndex:0] intValue]];
    
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
    [self setUpGridLbls];
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
        IPhonePopoverHandler *handler = [[IPhonePopoverHandler alloc] init];
        [handler addChildViewController:mutsPopover];
        [handler setMainViewController:mutsPopover andTitle:kMutationsInfoPopoverTitleInIPhonePopoverHandler];
        [mutsPopover didMoveToParentViewController:handler];
        [self presentViewController:handler animated:YES completion:nil];
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
    
    mutPosArray = [BWT_MutationFilter filteredMutations:allMutPosArray
                                     forHeteroAllowance:val insertionsArr:insertionsArr];
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
            for (int i = 0; i < ([gridView isEqual:covGridView] ? kNumOfRowsInGridView : ARow); i++)
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
            for (int i = 0; i < ([gridView isEqual:covGridView] ? kNumOfRowsInGridView : ARow); i++)
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
            if (gridView.currOffset <= gridView.boxWidth)
                gridView.currOffset = gridView.boxWidth*gridView.numOfBoxesPerPixel;//Goes to the next box to avoid drawing issues
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
    }
    else {
        IPhonePopoverHandler *handler = [[IPhonePopoverHandler alloc] init];
        [handler addChildViewController:coverageHistogram];
        [handler setMainViewController:coverageHistogram andTitle:kCoverageHistogramTitleInIPhoneHandlerPopover];
        [coverageHistogram didMoveToParentViewController:handler];
        [self presentViewController:handler animated:YES completion:^{
            [coverageHistogram createHistogramWithMaxCovVal:gridView.maxCoverageVal andNumOfReads:numOfReads andReadLen:readLen andGenomeLen:genomeLen];
        }];
    }
}

//Grid view delegate
- (void)gridPointClickedWithCoordInGrid:(CGPoint)c andClickedPt:(CGPoint)o {
    if (gridView.boxWidth < kThresholdBoxWidth)
        return;
    UIViewController *vc;
    AnalysisPopoverController *apc = [[AnalysisPopoverController alloc] init];
    apc.preferredContentSize = apc.view.bounds.size;
    
    vc = apc;
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
    else {
        IPhonePopoverHandler *handler = [[IPhonePopoverHandler alloc] init];
        [handler addChildViewController:apc];
        [handler setMainViewController:apc andTitle:kAnalysisPopoverTitleInIPhonePopoverHandler];
        [apc didMoveToParentViewController:handler];
        [self presentViewController:handler animated:YES completion:nil];
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
        [mutsPopover setUpWithMutationsArr:[BWT_MutationFilter filteredMutations:mutPosArray forHeteroAllowance:mutationSupportStpr.value insertionsArr:insertionsArr] andCumulativeGenomeLenArr:cumulativeSeparateGenomeLens andGenomeFileNameArr:separateGenomeNames];
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
    return (index < [separateGenomeNames count]) ? [separateGenomeNames objectAtIndex:index] : @"";
}

- (void)shouldUpdateGenomeNameLabelForIndexInSeparateGenomeLenArray:(int)index {
    genomeFileSegmentNames = [separateGenomeNames objectAtIndex:index];
    gridView.indexInGenomeNameArr = index;
    [segmentPckr selectRow:index inComponent:0 animated:NO];
    currSegmentLbl.text = [separateGenomeNames objectAtIndex:index];
    currSegmentLenLbl.text = [NSString stringWithFormat:kCurrSegmentLenLblStart,[[separateGenomeLens objectAtIndex:index] intValue]];
}

- (void)displayPopoverWithViewController:(UIViewController *)controller atPoint:(CGPoint)point withTitle:(NSString *)title {
    if ([GlobalVars isIpad]) {
        if (popoverController.isPopoverVisible)
            return;
        popoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        [popoverController presentPopoverFromRect:CGRectMake(point.x, point.y, 1, 1) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    }
    else {
        IPhonePopoverHandler *handler = [[IPhonePopoverHandler alloc] init];
        [handler addChildViewController:controller];
        [handler setMainViewController:controller andTitle:title];
        [controller didMoveToParentViewController:handler];
        [self presentViewController:handler animated:YES completion:nil];
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
            [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:^{
                [self freeUsedMemory];
            }];
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
    [analysisControllerIPadMenu setFileExporter:fileExporter];
    [analysisControllerIPadMenu setMutationsInfoPopover:mutsPopover];
    
    UINib *imptMutsNib = [UINib nibWithNibName:kImportantMutationsDisplayViewNibName bundle:nil];
    ImportantMutationsDisplayView *imptMutsView = [[imptMutsNib instantiateWithOwner:self options:0] objectAtIndex:0];
    [imptMutsView setDelegate:self];
    [imptMutsView setUpWithMutationsArray:imptMutationsArr];
    
    [analysisControllerIPadMenu setImptMutationsView:imptMutsView];
    
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
    [analysisControllerIPhoneToolbar removeFromSuperview];
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

- (void)freeUsedMemory {
    for (int i = 0; i < [readAlignmentsArr count]; i++) {
        ED_Info *read = [readAlignmentsArr objectAtIndex:i];
        [read freeUsedMemory];
        read = nil;
    }
    [mutPosArray removeAllObjects];
    mutPosArray = nil;
    [allMutPosArray removeAllObjects];
    allMutPosArray = nil;
    [readAlignmentsArr removeAllObjects];
    readAlignmentsArr = nil;
    [alignmentGridView freeUsedMemory];
    coverageHistogram = nil;
    covGridView = nil;
    alignmentGridView = nil;
}

//Memory warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
