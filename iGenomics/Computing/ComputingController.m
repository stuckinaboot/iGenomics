//
//  ComputingController.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/11/13.
//
//

#import "ComputingController.h"

@interface ComputingController ()

@end

@implementation ComputingController

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
    readProgressView.progress = 0;
    readsProcessed = 0;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)setUpWithReads:(NSString*)myReads andSeq:(NSString*)mySeq andParameters:(NSArray*)myParameterArray {
    analysisController = [[AnalysisController alloc] init];
    
//    NSArray *a = [myReads componentsSeparatedByString:@"."];
//    NSString *readsFileExt = [a objectAtIndex:[a count]-1];
    
//    a = [mySeq componentsSeparatedByString:@"."];
//    NSString *refFileExt = [a objectAtIndex:[a count]-1];
    
    //Creates new bwt setup for each new sequencing time
    bwt = [[BWT alloc] init];
    [bwt setDelegate:self];
    [bwt setUpForRefFileContents:mySeq];
    
    //Set up parameters    
//    [bwt matchReedsFileContents:myReads withParameters:myParameterArray];//Obviously make this variable
    [bwt matchReedsFileContentsAndParametersArr:[NSArray arrayWithObjects:myReads, myParameterArray, nil]];
//    [bwt performSelectorInBackground:@selector(matchReedsFileContentsAndParametersArr:) withObject:[NSArray arrayWithObjects:myReads, myParameterArray, nil]];
    
    bwt.bwtMutationFilter.kHeteroAllowance = [[myParameterArray objectAtIndex:3] intValue];
    [bwt.bwtMutationFilter buildOccTableWithUnravStr:bwt.originalString];
    [bwt.bwtMutationFilter findMutationsWithOriginalSeq:bwt.originalString];
    [bwt.bwtMutationFilter filterMutationsForDetails];
    
    NSString *refFileName = [myParameterArray objectAtIndex:5];
    NSString *readFileName = [myParameterArray objectAtIndex:6];
    
    //genome file name, reads file name, read length, genome length, number of reads
    NSArray *basicInf = [NSArray arrayWithObjects:refFileName, readFileName, [NSNumber numberWithInt:bwt.readLen], [NSNumber numberWithInt:bwt.refSeqLen], [NSNumber numberWithInt:bwt.numOfReads],nil];
    
    [analysisController readyViewForDisplay:bwt.originalString andInsertions:[bwt getInsertionsArray] andBWT:bwt andBasicInfo:basicInf];
}

- (void)viewDidAppear:(BOOL)animated {
    [self presentModalViewController:analysisController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//BWT_Delegate
- (void)readProccesed {
    readsProcessed++;
    [self updateProgressView];
//    [self performSelectorOnMainThread:@selector(updateProgressView) withObject:nil waitUntilDone:NO];
}

- (void)updateProgressView {
    readProgressView.progress += (1.0f/bwt.numOfReads);//This is 0 and everything is on main thread, this needs to change
    if (kPrintReadProcessedInConsole>0)
        printf("\n%i reads processed",readsProcessed);
}
@end
