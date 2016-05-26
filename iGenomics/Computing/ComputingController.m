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

- (void)setUpWithReadsFile:(APFile*)myReadsFile andRefFile:(APFile*)myRefFile andParameters:(NSMutableDictionary*)myParameters andImptMutsFile:(APFile*)imptMutsFile {
    
    readProgressView.progress = 0;
    readsProcessed = 0;//In case view loaded late
    
    analysisController = [[AnalysisController alloc] init];
    
    bytesForIndexer = ceilf((double)dgenomeLen/kMaxMultipleToCountAt);
    
    //Creates new bwt setup for each new sequencing time
    bwt = [[BWT alloc] init];
    [bwt setDelegate:self];
    [bwt setUpForRefFile:myRefFile];
    exportDataStr = [[NSMutableString alloc] init];
    
    int trimmingValue = [myParameters[kParameterArrayTrimmingValKey] intValue];
    
    if (trimmingValue != kTrimmingOffVal)
        myReadsFile.contents = [self readsAfterTrimmingForReads:myReadsFile.contents andTrimValue:trimmingValue andReferenceQualityChar:[myParameters[kParameterArrayTrimmingRefCharKey] characterAtIndex:0]];
    
    timeRemainingLbl.text = kComputingTimeRemainingPreCalculatedTxt;
    
    //Set up parameters
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);//Creates background queue
    dispatch_async(queue, ^{//Opens up a background thread
        readTimer = [[APTimer alloc] init];
        [readTimer start];
        
        [bwt matchReadsFile:myReadsFile withParameters:myParameters];
        
        dispatch_async(dispatch_get_main_queue(), ^{//Uses the main thread to update once the background thread finishes running
            [timeRemainingUpdateTimer invalidate];
            timeRemainingUpdateTimer = nil;
            
            timeRemaining = 0;
            [self updateReadsProcessedLblTimeRemaining];
            
            timeRemaining = 0;
            [readTimer stop];
            readTimer = nil;
            
            bwt.bwtMutationFilter.kHeteroAllowance = kMutationSupportMin;//[[myParameterArray objectAtIndex:kParameterArrayMutationCoverageIndex] intValue];
            [bwt.bwtMutationFilter resetFoundGenome];//NECESSARY BECAUSE THE FOUND GENOME COULD HAVE OTHER CONTENTS AND THEY MUST BE REMOVED AT ALL COSTS...WHAHAHAHAH
            [bwt.bwtMutationFilter buildOccTableWithUnravStr:originalStr];
//            [bwt.bwtMutationFilter findMutationsWithOriginalSeq:originalStr];
            [bwt.bwtMutationFilter filterMutationsForDetails];
            
            NSString *refFileSegmentNames = myParameters[kParameterArrayRefFileSegmentNamesKey];
            NSString *readFileName = myParameters[kParameterArrayReadFileNameKey];
            
            //genome file name, reads file name, read length, genome length, number of reads, number of reads matched
            NSArray *basicInf = [NSArray arrayWithObjects:refFileSegmentNames, readFileName, [NSNumber numberWithInt:bwt.readLen], [NSNumber numberWithInt:bwt.refSeqLen-1]/*-1 to account for the dollar sign*/, [NSNumber numberWithInt:bwt.numOfReads], [NSNumber numberWithDouble:[myParameters[kParameterArrayERKey] doubleValue]], [NSNumber numberWithInt:bwt.numOfReadsMatched], [NSNumber numberWithInt:[myParameters[kParameterArrayMutationCoverageKey] intValue]], nil];
            [analysisController readyViewForDisplay:originalStr andInsertions:[bwt getInsertionsArray] andBWT:bwt andExportData:exportDataStr andBasicInfo:basicInf andSeparateGenomeNamesArr:bwt.separateGenomeNames andSeparateGenomeLensArr:bwt.separateGenomeLens andCumulativeGenomeLensArr:bwt.cumulativeSeparateGenomeLens andImptMutsFileContents:imptMutsFile.contents andRefFile:myRefFile];
            [NSTimer scheduledTimerWithTimeInterval:kShowAnalysisControllerDelay target:self selector:@selector(showAnalysisController) userInfo:nil repeats:NO];
            
        });
    });
}

- (NSString*)readsAfterTrimmingForReads:(NSString*)reads andTrimValue:(int)trimValue andReferenceQualityChar:(char)refChar {
    
    NSMutableString *newReads = [[NSMutableString alloc] init];
    NSArray *arr = [reads componentsSeparatedByString:kLineBreak];
    NSMutableString *qualStr;
    
    for (int i = 0; i < [arr count]; i += (kFirstQualValueIndexInReadsToTrim+1)) {
        qualStr = [arr objectAtIndex:i+kFirstQualValueIndexInReadsToTrim];//index i is the name of the read
        
        int maxSum = 0;
        int maxPos = 0;
        int curSum = 0;
        
        for (int x = 0; x < qualStr.length; x++) {
            int qualVal = [qualStr characterAtIndex:x]-refChar;
            qualVal -= trimValue; //Subtracts the user inputted trim threshold
            
            curSum += qualVal;
            
            if (curSum > maxSum) {
                maxSum = curSum;
                maxPos = x;
            }
        }
        
        NSString *oldRead = [arr objectAtIndex:i + 1];
        NSString *newRead = [oldRead substringToIndex:maxPos+1];//+1 to include that index
        int minReadLen = kMinReadLengthPercentOfReadThatMustRemain * oldRead.length;
        if (newRead.length >= minReadLen)
            [newReads appendFormat:@"%@\n%@\n",[arr objectAtIndex:i], newRead];//Adds the read and its name
    }
    newReads = (NSMutableString*)[newReads stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return (NSString*)newReads;
}

- (void)showAnalysisController {
    [self presentViewController:analysisController animated:YES completion:^{
//        [analysisController setUpIPhoneToolbar];
        readProgressView.progress = 0;
        readsProcessed = 0;//In case view loaded late (backup protection for the ones uptop)
        readsProcessedLbl.text = [NSString stringWithFormat:kReadProcessedLblTxt,readsProcessed,bwt.numOfReads];
    }];
}

- (void)updateReadsProcessedLblTimeRemaining {
    int seconds = timeRemaining % 60;
    int minutes = (timeRemaining / 60) % 60;
    int hours = timeRemaining / 3600;
    
    if (timeRemaining >= 0) {
        timeRemainingLbl.text = [NSString stringWithFormat:kComputingTimeRaminingCalculatedTxt, hours, minutes, seconds];
        timeRemaining -= kComputingTimeRemainingUpdateInterval;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//BWT_Delegate
- (void)readProccesed:(NSString *)readData {
    if (readsProcessed < kComputingTimeRemainingNumOfReadsToBaseTimeOffOf) {
        [readTimer stop];
        timesToProcessComputingReads[readsProcessed] = [readTimer getTotalRecordedTime];
        [readTimer start];
    }
    readsProcessed++;
    [self performSelectorOnMainThread:@selector(updateProgressView) withObject:nil waitUntilDone:NO];//Updates the main thread because readProcessed is called from a background thread
    [exportDataStr appendFormat:@"%@",readData];
}

- (void)bwtLoadedWithLoadingText:(NSString*)txt {
    [self performSelectorOnMainThread:@selector(setReadProcessLblText:) withObject:txt waitUntilDone:NO];
}

- (void)setReadProcessLblText:(NSString*)txt {//Method so that performSelectorOnMainThread can call it
    [readsProcessedLbl setText:txt];
}

- (void)updateProgressView {
    if (readsProcessed >= kComputingTimeRemainingNumOfReadsToBaseTimeOffOf && timeRemainingUpdateTimer == nil) {
        [readTimer stop];
        [self computeInitialTimeRemaining];
        
        timeRemainingUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:kComputingTimeRemainingUpdateInterval target:self selector:@selector(updateReadsProcessedLblTimeRemaining) userInfo:nil repeats:YES];
    }
    else if (readsProcessed >= (int)bwt.numOfReads*kComputingTimeRemainingFracOfReadsToBeginFreqUpdatingAt && readsProcessed % kComputingTimeRemainingNumOfReadsToBaseTimeOffOf == 0) {
        [readTimer stop];
        timeRemaining = (bwt.numOfReads-readsProcessed)*([readTimer getTotalRecordedTime]/readsProcessed);
        [readTimer start];
    }
    
    readProgressView.progress += (1.0f/bwt.numOfReads);
    readsProcessedLbl.text = [NSString stringWithFormat:kReadProcessedLblTxt,readsProcessed,bwt.numOfReads];
    if (kPrintReadProcessedInConsole>0)
        printf("\n%i reads processed",readsProcessed);
}

- (void)computeInitialTimeRemaining {
    timeRemaining = [readTimer getTotalRecordedTime] * (bwt.numOfReads-kComputingTimeRemainingNumOfReadsToBaseTimeOffOf) / kComputingTimeRemainingNumOfReadsToBaseTimeOffOf;
    
    double timeRemainingSD = 0;
    
    double sumOfSquaredDiffs = 0;
    for (int i = 0; i < kComputingTimeRemainingNumOfReadsToBaseTimeOffOf; i++) {
        sumOfSquaredDiffs += pow((timesToProcessComputingReads[i]-((i > 0) ? timesToProcessComputingReads[i-1] : 0)) - timeRemaining, 2);
    }
    
    timeRemainingSD = sqrt(sumOfSquaredDiffs/kComputingTimeRemainingNumOfReadsToBaseTimeOffOf);
    
    timeRemaining += kComputingTimeRemainingNumOfSDsToAddToMeanTimeRemaining * timeRemainingSD;
    
    [readTimer start];
}

//Supported Orientations
- (NSUInteger)supportedInterfaceOrientations {
    if (![GlobalVars isIpad])
        return UIInterfaceOrientationMaskPortrait;
    else
        return UIInterfaceOrientationMaskLandscape;
}

@end
