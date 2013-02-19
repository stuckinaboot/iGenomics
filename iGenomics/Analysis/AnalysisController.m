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
    [self resetDisplay];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)readyViewForDisplay:(char*)unraveledStr andInsertions:(NSMutableArray *)iArr andBWT:(BWT *)myBwt andBasicInfo:(NSArray*)basicInfArr {
    originalStr = unraveledStr;
    insertionsArr = iArr;
    bwt = myBwt;
    
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
    
    [genomeCoverageLbl setText:[NSString stringWithFormat:@"%@%1.0f",kGenomeCoverageLblStart,coverage]];
    mutPosArray = [[NSMutableArray alloc] init];
    
    [readNumOfLbl setText:[NSString stringWithFormat:@"%@%i",kNumOfReadsLblStart,numOfReads]];
    
    //Set up letters for the gridView
    nLbl[0] = refLbl;
    nLbl[1] = foundLbl;
    
//    UIColor *aCol = [UIColor colorWithRed:aRGB[0] green:aRGB[1] blue:aRGB[2] alpha:1.0];
//    [aLbl setTextColor:aCol];
    nLbl[2] = aLbl;
    
//    UIColor *cCol = [UIColor colorWithRed:cRGB[0] green:cRGB[1] blue:cRGB[2] alpha:1.0];
//    [cLbl setTextColor:cCol];
    nLbl[3] = cLbl;
    
//    UIColor *gCol = [UIColor colorWithRed:gRGB[0] green:gRGB[1] blue:gRGB[2] alpha:1.0];
//    [gLbl setTextColor:gCol];
    nLbl[4] = gLbl;
    
//    UIColor *tCol = [UIColor colorWithRed:tRGB[0] green:tRGB[1] blue:tRGB[2] alpha:1.0];
//    [tLbl setTextColor:tCol];
    nLbl[5] = tLbl;
    
//    UIColor *delCol = [UIColor colorWithRed:delRGB[0] green:delRGB[1] blue:delRGB[2] alpha:1.0];
//    [delLbl setTextColor:delCol];
    nLbl[6] = delLbl;
    
//    UIColor *insCol = [UIColor colorWithRed:insRGB[0] green:insRGB[1] blue:insRGB[2] alpha:1.0];
//    [insLbl setTextColor:insCol];
    nLbl[7] = insLbl;
    
    UIColor *colors[kNumOfRGBVals];
    
    for (int i = 0; i<kNumOfRGBVals; i++) {
        colors[i] = [UIColor colorWithRed:rgbVals[i][0] green:rgbVals[i][1] blue:rgbVals[i][2] alpha:1.0];
        if (i >= kStartOfRefInRGBVals+2) {
            nLbl[i-kStartOfRefInRGBVals].textColor = colors[i];
        }
        else if (i >= kStartOfRefInRGBVals) {
            nLbl[i-kStartOfRefInRGBVals].textColor = [UIColor blackColor];
        }
    }
    
    [self performSelector:@selector(setUpGridLbls) withObject:nil afterDelay:kSetUpGridLblsDelay];
    
    [gridViewTitleLblHolder.layer setBorderWidth:kGridViewTitleLblHolderBorderWidth];
    //Set up gridView
    int len = strlen(originalStr)-1;//-1 so to not include $ sign
    
    [gridView firstSetUp];
    [gridView setDelegate:self];
    [gridView setUpWithNumOfRows:kNumOfRowsInGridView andCols:len andGraphBoxHeight:kGraphRowHeight];
    
    GridPoint *point[kNumOfRowsInGridView];
    for (int i = 0; i<len; i++) {
        point[1] = [gridView getGridPoint:0 :i];
        [point[1] setUpBtn];//Sets up the btn property
        [point[1].label setText:[NSString stringWithFormat:@"%c",originalStr[i]]];
        [point[1].label setTextColor:[UIColor whiteColor]];
        [point[1].view setBackgroundColor:colors[kStartOfRefInRGBVals]];
        
        point[2] = [gridView getGridPoint:1 :i];
        [point[2] setUpBtn];//Sets up the btn property
        [point[2].label setText:[NSString stringWithFormat:@"%c",foundGenome[0][i]]];
        [point[2].label setTextColor:[UIColor blackColor]];
        [point[2].view setBackgroundColor:colors[kStartOfRefInRGBVals+1]];
        
        if (posOccArray[kACGTLen+1][i]>0) {
            point[kNumOfRowsInGridView-1] = [gridView getGridPoint:kNumOfRowsInGridView-1 :i];
            [point[kNumOfRowsInGridView-1] setUpBtn];
        }
        if (originalStr[i] != foundGenome[0][i]) {//Mutation
//            [point[0] setUpView];
//            [point[1] setUpView];
            int v = 0;
            for (int t = 0; t<kACGTLen; t++) {
                if (kACGTStr[t] == foundGenome[0][i]) {
                    v = t;
                    break;
                }
                else if (kDelMarker == foundGenome[0][i]) {
                    v = kACGTLen;
                    break;
                }
                else if (kInsMarker == foundGenome[0][i]) {
                    v = kACGTLen+1;
                    break;
                }
            }
            
            [point[2].label setTextColor:colors[kStartOfAInRGBVals+v]];
//            [point[0].view setBackgroundColor:[UIColor blueColor]];
//            [point[1].view setBackgroundColor:[UIColor blueColor]];
            
            [mutPosArray addObject:[NSNumber numberWithInt:i]];
        }
        
        //Highlight for hetero?
        for (int t = 2; t<kNumOfRowsInGridView-1; t++) {
            point[t] = [gridView getGridPoint:t :i];
            [point[t].label setText:[NSString stringWithFormat:@"%i",posOccArray[t-2][i]]];
            point[t].label.textColor = [UIColor colorWithRed:rgbVals[1][0] green:rgbVals[1][1] blue:rgbVals[1][2] alpha:1.0];
            [point[t].view setBackgroundColor:colors[0]];
            
//            if (t == 2) {//A
                if (posOccArray[t-2][i]>0)
                    [point[t].label setTextColor:colors[kStartOfAInRGBVals+(t-2)]];
            /*}
            else if (t == 3) {//C
                if (posOccArray[t-2][i]>0)
                    [point[t].label setTextColor:cCol];
            }
            else if (t == 4) {//G
                if (posOccArray[t-2][i]>0)
                    [point[t].label setTextColor:gCol];
            }
            else if (t == 5) {//T
                if (posOccArray[t-2][i]>0)
                    [point[t].label setTextColor:tCol];
            }
            else if (t == 6) {//-
                if (posOccArray[t-2][i]>0)
                    [point[t].label setTextColor:delCol];
            }
            else if (t == 7) {//+
                if (posOccArray[t-2][i]>0)
                    [point[t].label setTextColor:insCol];
            }*/
        }
    }
    
    mutsPopover = [[MutationsInfoPopover alloc] init];
    [mutsPopover setDelegate:self];
    [mutsPopover setUpWithMutationsArr:mutPosArray];
}

- (void)setUpGridLbls {
    int yPos = gridView.frame.origin.y+(gridView.boxHeight/2);
    for (int i  = 0; i<kNumOfRowsInGridView; i++) {
        nLbl[i].center = CGPointMake(nLbl[i].center.x, yPos);
        yPos += gridView.boxHeight;
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

//Grid view delegate
- (void)gridPointClickedWithCoordInGrid:(CGPoint)c andOriginInGrid:(CGPoint)o {
    GridPoint *point = [gridView getGridPoint:c.x :c.y];
    
    if (c.x < 2) {
        AnalysisPopoverController *apc = [[AnalysisPopoverController alloc] init];
        apc.contentSizeForViewInPopover = CGSizeMake(kAnalysisPopoverW, kAnalysisPopoverH);
        
        popoverController = [[UIPopoverController alloc] initWithContentViewController:apc];
        
        apc.posLbl.text = [NSString stringWithFormat:@"Position: %1.0f",c.y+1];//+1 so doesn't start at 0
        
        NSMutableString *heteroStr = [[NSMutableString alloc] initWithString:@"Hetero: "];
        
        for (int i = 1; i<kACGTLen+2; i++) {
            [heteroStr appendFormat:@" %c",foundGenome[i][(int)c.y]];
        }
        
        apc.heteroLbl.text = heteroStr;
    }
    else if (c.x == kNumOfRowsInGridView-1) {
        InsertionsPopoverController *ipc = [[InsertionsPopoverController alloc] init];
        [ipc setInsArr:insertionsArr forPos:(int)c.y];
        
        ipc.contentSizeForViewInPopover = CGSizeMake(kInsPopoverW, kInsPopoverH);
        
        popoverController = [[UIPopoverController alloc] initWithContentViewController:ipc];
    }
    CGPoint realP = [self.view convertPoint:o fromView:gridView];
    CGRect realR = CGRectMake(realP.x, realP.y, point.frame.size.width, point.frame.size.height);
    [popoverController presentPopoverFromRect:realR inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

//Memory warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
