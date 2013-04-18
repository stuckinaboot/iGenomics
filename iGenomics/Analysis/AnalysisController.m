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

- (void)readyViewForDisplay:(char*)unraveledStr andInsertions:(NSMutableArray *)iArr andBWT:(BWT *)myBwt andBasicInfo:(NSArray*)basicInfArr {
    originalStr = unraveledStr;
    insertionsArr = iArr;
    bwt = myBwt;
    
    mutationSupportStpr.value = bwt.bwtMutationFilter.kHeteroAllowance;
    
    //genome file name, reads file name, read length, genome length, number of reads
    genomeFileName = [basicInfArr objectAtIndex:0];
    readsFileName = [basicInfArr objectAtIndex:1];
    readLen = [[basicInfArr objectAtIndex:2] intValue];
    genomeLen = [[basicInfArr objectAtIndex:3] intValue];
    numOfReads = [[basicInfArr objectAtIndex:4] intValue];
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
    
    [readNumOfLbl setText:[NSString stringWithFormat:@"%@%i",kNumOfReadsLblStart,numOfReads]];
    
    [mutationSupportNumLbl setText:[NSString stringWithFormat:@"%i",(int)mutationSupportStpr.value]];
    
    //Set up letters for the gridView
    /*nLbl[0] = covLbl;
    nLbl[1] = refLbl;
    nLbl[2] = foundLbl;
    nLbl[3] = aLbl;
    nLbl[4] = cLbl;
    nLbl[5] = gLbl;
    nLbl[6] = tLbl;
    nLbl[7] = delLbl;
    nLbl[8] = insLbl;
    
    UIColor *colors[kNumOfRGBVals];
    
    for (int i = 0; i<kNumOfRGBVals; i++) {
        colors[i] = [UIColor colorWithRed:rgbVals[i][0] green:rgbVals[i][1] blue:rgbVals[i][2] alpha:1.0];
        if (i >= kStartOfRefInRGBVals+2) {
            nLbl[i-kStartOfRefInRGBVals].textColor = colors[i];
        }
        else if (i >= kStartOfRefInRGBVals) {
            nLbl[i-kStartOfRefInRGBVals].textColor = [UIColor blackColor];
        }
    }*/
    
    [self performSelector:@selector(setUpGridLbls) withObject:nil afterDelay:0];
    
    [gridViewTitleLblHolder.layer setBorderWidth:kGridViewTitleLblHolderBorderWidth];
    //Set up gridView
    int len = strlen(originalStr)-1;//-1 so to not include $ sign
    
    //[gridView firstSetUp];
    [gridView setDelegate:self];
    gridView.refSeq = originalStr;
    [gridView setUpWithNumOfRows:kNumOfRowsInGridView andCols:len andGraphBoxHeight:kGraphRowHeight];
    [pxlOffsetSlider setMaximumValue:((gridView.totalCols*(kGridLineWidthCol+gridView.kIpadBoxWidth)))-gridView.frame.size.width];
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
    if (i > 0 && i<= strlen(originalStr)) {//is a valid number
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
    
    mutationSupportNumLbl.text = [NSString stringWithFormat:@"%i",val];
    
    [mutPosArray removeAllObjects];
    bwt.bwtMutationFilter.kHeteroAllowance = val;
    
    [bwt.bwtMutationFilter filterMutationsForDetails];
    
//    [gridView clearAllPoints];
    [self resetDisplay];
}

//Mutation Info Popover Delegate
- (void)mutationAtPosPressedInPopover:(int)pos {
    [popoverController dismissPopoverAnimated:YES];
    [gridView scrollToPos:pos];
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
                gridView.kTxtFontSize += kPinchZoomFontSizeFactor;
                zoomLevel--;
                
                [gridView resetScrollViewContentSize];
                [gridView resetTickMarkInterval];
                [pxlOffsetSlider setMaximumValue:((gridView.totalCols*(kGridLineWidthCol+gridView.kIpadBoxWidth)))-gridView.frame.size.width];
                gridView.currOffset = [gridView offsetOfPt:pt];
                [gridView setUpGridViewForPixelOffset:gridView.currOffset];
            }
        }
        else if (s < 1.0f) {//Zoom out
            if (zoomLevel<kPinchZoomMinLevel) {
                int pt = [gridView firstPtToDrawForOffset:gridView.currOffset];
                gridView.kIpadBoxWidth /= kPinchZoomFactor;
                gridView.kTxtFontSize -= kPinchZoomFontSizeFactor;

                zoomLevel++;
                
                [gridView resetScrollViewContentSize];
                [gridView resetTickMarkInterval];
                [pxlOffsetSlider setMaximumValue:((gridView.totalCols*(kGridLineWidthCol+gridView.kIpadBoxWidth)))-gridView.frame.size.width];
                gridView.currOffset = [gridView offsetOfPt:pt];
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
    CGPoint box = CGPointMake([gridView firstPtToDrawForOffset:xCoord],(int)(pt.y/(kGridLineWidthRow+gridView.boxHeight)));//Get the tapped box
    
    [self gridPointClickedWithCoordInGrid:box andClickedPt:pt];
}

//Grid view delegate
- (void)gridPointClickedWithCoordInGrid:(CGPoint)c andClickedPt:(CGPoint)o {
    
    if (c.y < 3 && c.y > 0) {
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
    else if (c.y == kNumOfRowsInGridView-1 && posOccArray[kACGTLen+2][(int)c.x] > 0/*there is at least one insertion there*/) {//NEED TO CONFIRM THIS WORKS
        InsertionsPopoverController *ipc = [[InsertionsPopoverController alloc] init];
        [ipc setInsArr:insertionsArr forPos:(int)c.x];
        
        ipc.contentSizeForViewInPopover = CGSizeMake(kInsPopoverW, kInsPopoverH);
        
        popoverController = [[UIPopoverController alloc] initWithContentViewController:ipc];
    }
    else
        return;
    CGRect rect = CGRectMake(c.x*(gridView.kIpadBoxWidth+kGridLineWidthCol)-gridView.currOffset, c.y*(gridView.boxHeight+kGridLineWidthRow), gridView.kIpadBoxWidth, gridView.boxHeight);
    
    [popoverController presentPopoverFromRect:rect inView:gridView permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

- (void)mutationFoundAtPos:(int)pos {
    [mutPosArray addObject:[NSNumber numberWithInt:pos]];
}

- (void)gridFinishedUpdatingWithOffset:(double)currOffset {
    if (!mutsPopoverAlreadyUpdated) {
        mutsPopover = [[MutationsInfoPopover alloc] init];
        [mutsPopover setDelegate:self];
        [mutsPopover setUpWithMutationsArr:mutPosArray];
        mutsPopoverAlreadyUpdated = !mutsPopoverAlreadyUpdated;
    }
    
    pxlOffsetSlider.value = currOffset;//a little bit of a prob here
}
//Memory warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
