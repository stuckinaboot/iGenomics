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

- (void)readyViewForDisplay:(char*)unraveledStr andInsertions:(NSMutableArray *)iArr andBWT:(BWT *)myBwt {
    originalStr = unraveledStr;
    insertionsArr = iArr;
    bwt = myBwt;
}

- (void)resetDisplay {
    mutPosArray = [[NSMutableArray alloc] init];
    
    int len = strlen(originalStr);
    
    [gridView firstSetUp];
    [gridView setDelegate:self];
    [gridView setUpWithNumOfRows:kNumOfRowsInGridView andCols:len];
    
    GridPoint *point[kNumOfRowsInGridView];
    for (int i = 0; i<len; i++) {
        point[0] = [gridView getGridPoint:0 :i];
        [point[0] setUpBtn];//Sets up the btn property
        [point[0].label setText:[NSString stringWithFormat:@"%c",originalStr[i]]];
        
        point[1] = [gridView getGridPoint:1 :i];
        [point[1] setUpBtn];//Sets up the btn property
        [point[1].label setText:[NSString stringWithFormat:@"%c",foundGenome[0][i]]];
        
        if (originalStr[i] != foundGenome[0][i]) {//Mutation
            [point[0] setUpView];
            [point[1] setUpView];
            
            [point[0].view setBackgroundColor:[UIColor blueColor]];
            [point[1].view setBackgroundColor:[UIColor blueColor]];
            
            [mutPosArray addObject:[NSNumber numberWithInt:i]];
        }
        
        //Highlight for hetero?
        
        point[2] = [gridView getGridPoint:2 :i];
        [point[2].label setText:[NSString stringWithFormat:@"%i",posOccArray[0][i]]];
        
        point[3] = [gridView getGridPoint:3 :i];
        [point[3].label setText:[NSString stringWithFormat:@"%i",posOccArray[1][i]]];
        
        point[4] = [gridView getGridPoint:4 :i];
        [point[4].label setText:[NSString stringWithFormat:@"%i",posOccArray[2][i]]];
        
        point[5] = [gridView getGridPoint:5 :i];
        [point[5].label setText:[NSString stringWithFormat:@"%i",posOccArray[3][i]]];
        
        point[6] = [gridView getGridPoint:6 :i];
        [point[6].label setText:[NSString stringWithFormat:@"%i",posOccArray[4][i]]];
        
        point[7] = [gridView getGridPoint:7 :i];
        [point[7] setUpBtn];
        [point[7].label setText:[NSString stringWithFormat:@"%i",posOccArray[5][i]]];
    }
    
    mutsPopover = [[MutationsInfoPopover alloc] init];
    [mutsPopover setDelegate:self];
    [mutsPopover setUpWithMutationsArr:mutPosArray];
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

- (IBAction)showMutTBView:(id)sender {
    popoverController = [[UIPopoverController alloc] initWithContentViewController:mutsPopover];
    [popoverController presentPopoverFromRect:showMutTBViewBtn.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

//Mutation Info Popover Delegate
- (void)mutationAtPosPressedInPopover:(int)pos {
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
        
        apc.posLbl.text = [NSString stringWithFormat:@"Position: %1.0f",c.y];
        
        NSMutableString *heteroStr = [[NSMutableString alloc] initWithString:@"Hetero: "];
        
        for (int i = 1; i<kACGTLen+2; i++) {
            [heteroStr appendFormat:@" %c",foundGenome[i][(int)c.y]];
        }
        
        apc.heteroLbl.text = heteroStr;
    }
    else if (c.x == 7) {
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
