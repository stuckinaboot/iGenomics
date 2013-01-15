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

- (void)readyViewForDisplay:(char*)unraveledStr {
    originalStr = unraveledStr;
}

- (void)resetDisplay {
    int len = strlen(originalStr);
    
    [gridView firstSetUp];
    [gridView setUpWithNumOfRows:kNumOfRowsInGridView andCols:len];
    
    GridPoint *point[kNumOfRowsInGridView];
    for (int i = 0; i<len; i++) {
        point[0] = [gridView getGridPoint:0 :i];
        [point[0].label setText:[NSString stringWithFormat:@"%c",originalStr[i]]];
        
        point[1] = [gridView getGridPoint:1 :i];
        [point[1].label setText:[NSString stringWithFormat:@"%c",foundGenome[0][i]]];
        
        if (originalStr[i] != foundGenome[0][i]) {//Mutation
            [point[0] setUpView];
            [point[1] setUpView];
            
            [point[0].view setBackgroundColor:[UIColor blueColor]];
            [point[1].view setBackgroundColor:[UIColor blueColor]];
        }
        
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
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
