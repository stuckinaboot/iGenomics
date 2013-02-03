//
//  GridView.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/11/13.
//
//

#import "GridView.h"

@implementation GridView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)firstSetUp {
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:scrollView];
}

- (void)setUpWithNumOfRows:(int)rows andCols:(int)cols {
    [scrollView setContentSize:CGSizeMake(cols*kIpadBoxWidth, self.frame.size.height)];
    
    boxHeight = (double)self.frame.size.height/rows;
    
    for (int i = 0; i<rows; i++) {
        for (int j = 0; j<cols; j++) {
            points[i][j] = [[GridPoint alloc] initWithFrame:CGRectMake(j*kIpadBoxWidth, i*boxHeight, kIpadBoxWidth, boxHeight)];
            [points[i][j] setDelegate:self];
            points[i][j].coord = CGPointMake(i, j);
            [points[i][j] setUpLabel];//Sets up the label propery
            [scrollView addSubview:points[i][j]];
        }
    }
}

- (void)scrollToPos:(double)p {
    CGSize s = self.frame.size;
    CGRect frame = CGRectMake(kIpadBoxWidth*p, s.height/2, s.width, s.height);
    
    [UIView animateWithDuration:kScrollSpeed animations:^{
        [scrollView scrollRectToVisible:frame animated:NO];
    } completion:^(BOOL finished){
        CGPoint c = CGPointMake(0, 0);
        
        [delegate gridPointClickedWithCoordInGrid:CGPointMake(0, p) andOriginInGrid:c];//Display info
    }];
//    [scrollView scrollRectToVisible:frame animated:YES];
    
//    CGPoint c = CGPointMake(0, 0);
    
//    [delegate gridPointClickedWithCoordInGrid:CGPointMake(0, p) andOriginInGrid:c];//Display info
}

- (GridPoint*)getGridPoint:(int)row :(int)col {
    return points[row][col];
}

//Grid Point Delegate
- (void)gridPointClickedWithCoord:(CGPoint)c {
    [delegate gridPointClickedWithCoordInGrid:c andOriginInGrid:[scrollView convertPoint:points[(int)c.x][(int)c.y].frame.origin toView:self]];
}

@end
