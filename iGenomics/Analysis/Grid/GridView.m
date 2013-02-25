//
//  GridView.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/11/13.
//
//

#import "GridView.h"

@implementation GridView

@synthesize delegate, boxHeight, kIpadBoxWidth;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)firstSetUp {
    [scrollView removeFromSuperview];//Just in case it was there
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:scrollView];
}

- (void)setUpWithNumOfRows:(int)rows andCols:(int)cols andGraphBoxHeight:(double)gbHeight {
    [scrollView setContentSize:CGSizeMake(cols*kIpadBoxWidth, self.frame.size.height)];
    
    totalRows = rows;
    totalCols = cols;
    
    graphBoxHeight = gbHeight;
    boxHeight = (double)(self.frame.size.height-graphBoxHeight)/(rows-1);//Finds the boxHeight for the remaining rows
    
    for (int i = 0; i<rows; i++) {
        for (int j = 0; j<cols; j++) {
            if (i > 0) {//Not Graph Row
                points[i][j] = [[GridPoint alloc] initWithFrame:CGRectMake(j*kIpadBoxWidth, graphBoxHeight+((i-1)*boxHeight), kIpadBoxWidth, boxHeight)];//-1 because i is equal to 1 when it is first going through for the 1st box that is not a graph, and it was being put too far down on the y axis
                [points[i][j] setDelegate:self];
                points[i][j].coord = CGPointMake(i, j);
                [points[i][j] setUpView];//Sets up the img view property
                [points[i][j] setUpLabel];//Sets up the label property
                [scrollView addSubview:points[i][j]];
            }
            else {//Graph Row
                points[i][j] = [[GridPoint alloc] initWithFrame:CGRectMake(j*kIpadBoxWidth, 0, kIpadBoxWidth, graphBoxHeight)];
                [points[i][j] setDelegate:self];
                points[i][j].coord = CGPointMake(i, j);
                [points[i][j] setUpView];//Sets up the img view property
                [scrollView addSubview:points[i][j]];
            }
        }
    }
}

- (void)scrollToPos:(double)p {
    CGSize s = self.frame.size;
    CGRect frame = CGRectMake(kIpadBoxWidth*p, s.height/2, s.width, s.height);
    
    [UIView animateWithDuration:kScrollSpeed animations:^{
        [scrollView scrollRectToVisible:frame animated:NO];
    } completion:^(BOOL finished){
        
        CGPoint rc = [scrollView convertPoint:points[0][(int)p].frame.origin toView:self];
        CGPoint c = rc;
        
        [delegate gridPointClickedWithCoordInGrid:CGPointMake(0, p) andOriginInGrid:c];//Display info
    }];
}

- (void)clearAllPoints {
    for (int i = 0; i<totalRows; i++) {
        for (int j = 0; j<totalCols; j++) {
            [points[i][j] removeFromSuperview];
            points[i][j] = NULL;
        }
    }
}

- (GridPoint*)getGridPoint:(int)row :(int)col {
    return points[row][col];
}

//Grid Point Delegate
- (void)gridPointClickedWithCoord:(CGPoint)c {
    [delegate gridPointClickedWithCoordInGrid:c andOriginInGrid:[scrollView convertPoint:points[(int)c.x][(int)c.y].frame.origin toView:self]];
}

@end
