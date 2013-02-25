//
//  GridView.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/11/13.
//
//

#import <UIKit/UIKit.h>
#import "GridPoint.h"

#import "BWT_MutationFilter.h"

#define kMaxRows 10
#define kMaxColumns 10000 //Every 10,000 columns, ask user if they would like to view next 10,000

#define kDefaultIpadBoxWidth 57

#define kScrollSpeed 0.5

@protocol GridViewDelegate <NSObject>
- (void)gridPointClickedWithCoordInGrid:(CGPoint)c andOriginInGrid:(CGPoint)o;
@end

@interface GridView : UIView <GridPointDelegate> {
    UIScrollView *scrollView;
    GridPoint *points[kMaxRows][kMaxColumns];
    
    //Constant made into a variable for pinch zoom
    double kIpadBoxWidth;
    
    double graphBoxHeight;
    double boxHeight;
    
    int totalRows;
    int totalCols;
    
    id delegate;
}
@property (nonatomic) double boxHeight, kIpadBoxWidth;
@property (nonatomic) id <GridViewDelegate> delegate;
- (void)firstSetUp;
- (void)setUpWithNumOfRows:(int)rows andCols:(int)cols andGraphBoxHeight:(double)gbHeight;
- (void)clearAllPoints;

- (void)scrollToPos:(double)p;

- (GridPoint*)getGridPoint:(int)row :(int)col;
@end
