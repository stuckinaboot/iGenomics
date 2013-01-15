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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)setUpWithReads:(NSString*)myReads andSeq:(NSString*)mySeq andParameters:(NSArray*)myParameterArray {
    
    /*
     SET OF PARAMETERS:
     
     0-Exact match (0), substitution (1), subs + indels (2) | TYPE: int (exact,sub,subs+indels), int (ED)
     +Max ED
     
     1-Forward alignment(0), forward and reverse alignments (1) | TYPE: int
     
     2-Mutation support (num of disagreements before a position is reported as a mutation): (inputted by user) | TYPE: int
     
     3-Trimming (if selected, chop off last x (user is allowed to chose num) bases) | TYPE: int
     
     4-Seed (chunk) length: automatic, manual (user inputs seed length)  | TYPE: int
     +(Advanced feature)       -------NOT IMPLEMENTED YET
     
     */
    
    analysisController = [[AnalysisController alloc] init];
    
    NSArray *a = [myReads componentsSeparatedByString:@"."];
    NSString *readsFileExt = [a objectAtIndex:[a count]-1];
    
    a = [mySeq componentsSeparatedByString:@"."];
    NSString *refFileExt = [a objectAtIndex:[a count]-1];
    
    //Creates new bwt setup for each new sequencing time
    bwt = [[BWT alloc] init];
    [bwt setUpForRefFile:[mySeq substringToIndex:(mySeq.length)-(refFileExt.length)-1] fileExt:refFileExt];
    
    [bwt matchReedsFile:[myReads substringToIndex:(myReads.length)-(readsFileExt.length)-1] fileExt:readsFileExt withNumOfSubs:2];//Obviously make this variable
    
    [bwt.bwtMutationFilter buildOccTableWithUnravStr:bwt.originalString];
    [bwt.bwtMutationFilter findMutationsWithOriginalSeq:bwt.originalString];
    [bwt.bwtMutationFilter filterMutationsForDetails];
    
    [analysisController readyViewForDisplay:bwt.originalString];
}

- (void)viewDidAppear:(BOOL)animated {
    [self presentModalViewController:analysisController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
