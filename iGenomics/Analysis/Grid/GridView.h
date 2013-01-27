//
//  GridView.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/11/13.
//
//

#import <UIKit/UIKit.h>
#import "GridPoint.h"

#define kMaxRows 10
#define kMaxColumns 10000 //Every 10,000 columns, ask user if they would like to view next 10,000

#define kIpadBoxWidth 30

@protocol GridViewDelegate <NSObject>
- (void)gridPointClickedWithCoordInGrid:(CGPoint)c andOriginInGrid:(CGPoint)o;
@end

@interface GridView : UIView <GridPointDelegate> {
    UIScrollView *scrollView;
    GridPoint *points[kMaxRows][kMaxColumns];
    
    double boxHeight;
    
    id delegate;
}
@property (nonatomic) id <GridViewDelegate> delegate;
- (void)firstSetUp;
- (void)setUpWithNumOfRows:(int)rows andCols:(int)cols;

- (GridPoint*)getGridPoint:(int)row :(int)col;
@end
