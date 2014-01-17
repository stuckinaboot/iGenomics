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
    
    readProgressView.progress = 0;
    readsProcessed = 0;//In case view loaded late
    
    analysisController = [[AnalysisController alloc] init];
    
    bytesForIndexer = ceilf((double)dgenomeLen/kMaxMultipleToCountAt);
    
    //Creates new bwt setup for each new sequencing time
    bwt = [[BWT alloc] init];
    [bwt setDelegate:self];
    [bwt setUpForRefFileContents:mySeq];
    exportDataStr = [[NSMutableString alloc] init];
    
    //Set up parameters
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);//Creates background queue
    dispatch_async(queue, ^{//Opens up a background thread
        [bwt matchReedsFileContentsAndParametersArr:[NSArray arrayWithObjects:myReads, myParameterArray, nil]];
        dispatch_async(dispatch_get_main_queue(), ^{//Uses the main thread to update once the background thread finishes running
            bwt.bwtMutationFilter.kHeteroAllowance = [[myParameterArray objectAtIndex:3] intValue];
            [bwt.bwtMutationFilter buildOccTableWithUnravStr:bwt.originalString];
            [bwt.bwtMutationFilter findMutationsWithOriginalSeq:bwt.originalString];
            [bwt.bwtMutationFilter filterMutationsForDetails];
            
            NSString *refFileName = [myParameterArray objectAtIndex:5];
            NSString *readFileName = [myParameterArray objectAtIndex:6];
            
            //genome file name, reads file name, read length, genome length, number of reads
            NSArray *basicInf = [NSArray arrayWithObjects:refFileName, readFileName, [NSNumber numberWithInt:bwt.readLen], [NSNumber numberWithInt:bwt.refSeqLen], [NSNumber numberWithInt:bwt.numOfReads], [NSNumber numberWithInt:[[myParameterArray objectAtIndex:1] intValue]], nil];
            
            [analysisController readyViewForDisplay:bwt.originalString andInsertions:[bwt getInsertionsArray] andBWT:bwt andExportData:exportDataStr andBasicInfo:basicInf];
            [NSTimer scheduledTimerWithTimeInterval:kShowAnalysisControllerDelay target:self selector:@selector(showAnalysisController) userInfo:nil repeats:NO];
        });
    });
}

- (void)showAnalysisController {
    [self presentViewController:analysisController animated:YES completion:^{
        readProgressView.progress = 0;
        readsProcessed = 0;//In case view loaded late (backup protection for the ones uptop)
        readsProcessedLbl.text = [NSString stringWithFormat:kReadProcessedLblTxt,readsProcessed,bwt.numOfReads];
    }];
}

- (void)viewDidAppear:(BOOL)animated {

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//BWT_Delegate
- (void)readProccesed:(NSString *)readData {
    readsProcessed++;
    [self performSelectorOnMainThread:@selector(updateProgressView) withObject:nil waitUntilDone:NO];//Updates the main thread because readProcessed is called from a background thread
    [exportDataStr appendFormat:@"%@",readData];
}

- (void)updateProgressView {
    readProgressView.progress += (1.0f/bwt.numOfReads);//This is 0 and everything is on main thread, this needs to change
    readsProcessedLbl.text = [NSString stringWithFormat:kReadProcessedLblTxt,readsProcessed,bwt.numOfReads];
    if (kPrintReadProcessedInConsole>0)
        printf("\n%i reads processed",readsProcessed);
}
@end
