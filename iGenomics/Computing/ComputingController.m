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
    
    NSLog(@"==> setUpWithReads:(NSString*)myReads andSeq:(NSString*)mySeq andParameters:(NSArray*)myParameterArray method entered");
    
    readProgressView.progress = 0;
    readsProcessed = 0;//In case view loaded late
    
    analysisController = [[AnalysisController alloc] init];
    
    bytesForIndexer = ceilf((double)dgenomeLen/kMaxMultipleToCountAt);
    
    //Creates new bwt setup for each new sequencing time
    bwt = [[BWT alloc] init];
    [bwt setDelegate:self];
    [bwt setUpForRefFileContents:mySeq];
    exportDataStr = [[NSMutableString alloc] init];
    
    int trimmingValue = [[myParameterArray objectAtIndex:kParameterArrayTrimmingValIndex] intValue];
    if (trimmingValue != kTrimmingOffVal)
        myReads = [self readsAfterTrimmingForReads:myReads andTrimValue:trimmingValue andReferenceQualityChar:[[myParameterArray objectAtIndex:kParameterArrayTrimmingRefCharIndex] characterAtIndex:0]];
    
    //Set up parameters
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);//Creates background queue
    dispatch_async(queue, ^{//Opens up a background thread
        NSLog(@"About to call matchReedsFileContentsAndParametersArr");
        [bwt matchReedsFileContentsAndParametersArr:[NSArray arrayWithObjects:myReads, myParameterArray, nil]];
        dispatch_async(dispatch_get_main_queue(), ^{//Uses the main thread to update once the background thread finishes running
            bwt.bwtMutationFilter.kHeteroAllowance = [[myParameterArray objectAtIndex:kParameterArrayMutationCoverageIndex] intValue];
            [bwt.bwtMutationFilter buildOccTableWithUnravStr:bwt.originalString];
            [bwt.bwtMutationFilter findMutationsWithOriginalSeq:bwt.originalString];
            [bwt.bwtMutationFilter filterMutationsForDetails];
            
            NSString *refFileName = [myParameterArray objectAtIndex:kParameterArrayRefFileNameIndex];
            NSString *readFileName = [myParameterArray objectAtIndex:kParameterArrayReadFileNameIndex];
            
            //genome file name, reads file name, read length, genome length, number of reads
            NSArray *basicInf = [NSArray arrayWithObjects:refFileName, readFileName, [NSNumber numberWithInt:bwt.readLen], [NSNumber numberWithInt:bwt.refSeqLen], [NSNumber numberWithInt:bwt.numOfReads], [NSNumber numberWithInt:[[myParameterArray objectAtIndex:kParameterArrayEDIndex] intValue]], nil];
            
            [analysisController readyViewForDisplay:bwt.originalString andInsertions:[bwt getInsertionsArray] andBWT:bwt andExportData:exportDataStr andBasicInfo:basicInf];
            [NSTimer scheduledTimerWithTimeInterval:kShowAnalysisControllerDelay target:self selector:@selector(showAnalysisController) userInfo:nil repeats:NO];
        });
    });
}

- (NSString*)readsAfterTrimmingForReads:(NSString*)reads andTrimValue:(int)trimValue andReferenceQualityChar:(char)refChar {
    NSMutableString *newReads = [[NSMutableString alloc] init];
    NSArray *arr = [reads componentsSeparatedByString:@"\n"];
    NSMutableString *qualStr;
    
    for (int i = 0; i < [arr count]; i += (kFirstQualValueIndexInReadsToTrim+1)) {
        qualStr = [arr objectAtIndex:i+kFirstQualValueIndexInReadsToTrim];//index i is the name of the read
        
        int maxSum = 0;
        int maxPos = 0;
        int curSum = 0;
        
        for (int x = 0; x < qualStr.length-1; x++) {
            int qualVal = [qualStr characterAtIndex:x]-refChar;
            qualVal -= trimValue; //Subtracts the user inputted trim threshold
            
            curSum += qualVal;
            
            if (curSum > maxSum) {
                maxSum = curSum;
                maxPos = x;
            }
        }
        
        NSString *newRead = [[arr objectAtIndex:i+1] substringToIndex:maxPos+1];//+1 to include that index
        [newReads appendFormat:@"%@\n%@\n",[arr objectAtIndex:i], newRead];//Adds the read and its name
    }
    newReads = (NSMutableString*)[newReads stringByReplacingCharactersInRange:NSMakeRange(newReads.length-1, 1) withString:@""];//Takes away the last line break
    
    printf("%s",[newReads UTF8String]);
    
    return (NSString*)newReads;
}

- (void)showAnalysisController {
    [self presentViewController:analysisController animated:YES completion:^{
        readProgressView.progress = 0;
        readsProcessed = 0;//In case view loaded late (backup protection for the ones uptop)
        readsProcessedLbl.text = [NSString stringWithFormat:kReadProcessedLblTxt,readsProcessed,bwt.numOfReads];
    }];
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

//Supported Orientations
- (NSUInteger)supportedInterfaceOrientations {
    if (![GlobalVars isIpad])
        return UIInterfaceOrientationMaskPortrait;
    else
        return UIInterfaceOrientationMaskLandscape;
}

@end
