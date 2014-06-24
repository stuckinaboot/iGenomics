//
//  GridView.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/11/13.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "BWT_MutationFilter.h"
#import "DNAColors.h"

#define kMaxRows 10
#define kMaxColumns 10000 //Every 10,000 columns, ask user if they would like to view next 10,000

#define kDefaultIpadBoxWidth 64
#define kDefaultIphoneBoxWidth 64
#define kMinBoxWidth 1 //Smallest box width possible, will be showing coverage graph at this point
#define kThresholdBoxWidth 16 //Smallest box width possible to still be showing text (not full screen coverage graph)


#define kDefaultTxtFontSizeIPad 50
#define kMinTxtFontSizeIPad 40
#define kDefaultTxtFontSizeIPhone 20
#define kFontSizeMultFactor 0.93
#define kBoxWidthMultFactor 0.95
#define kMinTxtFontSizeIPhone 15

#define kScrollSpeed 0.5

#define kGridLineWidthRow 2
#define kGridLineWidthColDefault 2
#define kGridLineWidthColDefaultMin 0

#define kPosLblNum 5
#define kDefPosLblInterval 5 //20 cells
#define kPosLblTickMarkHeight 10
#define kPosLblFontSize 20
#define kPosLblHeight 40

#define kStartOfAInRGBVals 4
#define kStartOfRefInRGBVals 2

#define kMutHighlightOpacity 0.2

#define kMaxCovValLblW 80
#define kMaxCovValLblH 20

//POSITION LABELS--DONE (IF NEEDS TO BE CHANGED, WILL BE CHANGED)
//                                                                 5        10      15
//         --Should be above grid looking kinda like this |--------|---------|-------|
//         --When zoomed in, should be a smaller interval, when zoomed out should be a greater interval

//ADD KGRIDLINEWIDTHCOL BEFORE GRAPH SO IT DOESN'T PUSH IT OFF--DONE
//NEED TO MAKE ONE LARGE RECTANGLE FOR THE ACGT ROWS RATHER THAN A BUNCH OF RECTS OF THE SAME COLOR--DONE
//COMPUTE MAXVAL (FROM COVERAGEARRAY) AS IT LOADS, AND GENOME LENGTH AS IT LOADS--DONE
//_&_*_*_*_*_&_*_PAINT EVERYTHING IN SAME UIGRAPHICSCONTEXT &_*_*_*_*_&_*_--DONE
//RATHER THAN MAKING RGBVALS A STATIC DOUBLE, MAKE A DNACOLORS CLASS SO I CAN NAME THE COLORS--DONE

//Highlight the whole column with the color of the mutation when there is a mutation--DONE

//ADD LBL FOR COV, MAKE THEM ALL COMPLETELY DYNAMIC--DONE

//UPDATE MUTPOSARR WHEN THE MUTATION SUPPORT IS INCREASED/DECREASED
//CREATE A MUTATION CLASS THAT HAS POSITION, REF BASE, NEW BASE AND DISPLAY IN MUTATION POPOVER SHOULD SHOW THAT 

//SWITCH FORWARD AND REVERSE WITH FORWARD ON UISEGMENTEDCONTROL (FORWARD AND REVERSE IS USALLY SELECTED MORE OFTEN THEN FORWARD ONLY)--                         CHECK THE REVERSE ALIGNMENT ALGORITHM, IT IS OFF--DONE
//SHOW POS OCC ARR Lbls in the center of their cell, ALSO SHOW COVERAGE IN THE UIPOPOVER CONTROLLER
//If there is > 50 bases displayed on the screen at a time, fill in each pos occ arr lbl box with its color if their is coverage at that point (darker color means there is more coverage coverage at that spot)

//CREATE A [0,MAXVAL] LABEL A SMALLER FONT
//WHEN THE USER ZOOMS OUT, AND TAPS ON THE SCROLL VIEW MAKE SURE IT STAYS AT CURRENT POS
//FOR THEH INTERVAL ON ZOOM IN/OUT ON THE FLY SHOW FIVE TICK MARKS (THE NUM OF COLUMNS ON THE SCREEN/4) ON THE SCREEN AT ALL TIMES (UNLESS THE FIFTH IS OFF THE SCREEN, THEN DO FOUR). The point is to find a number that is nicer (ex. 900 instead of 892) If the bases being shown on the screen is from 880-1070, the interval is 47.5 (an ugly number), so round that to 50
    /*
     zeros = 0;  do while num>10 zeroes++ num = floorf(num/10), then do for x = 0, x<zeroes x++) num *= 10
     num = 3123;
     */
//Display a horizontal line connecting all the tick marks (through their vertical center), and a horizontal white line at the top of the coverage graph--DONE
//Do not count the insertions in the coverage graph--DONE
//SHOWING COMPUTING CONTROLLER AS SOON AS BUTTON IS SELECTED--DONE
//MAKE TIMER CLASS
//IN PARAMETERS VIEW, DISPLAY EDIT DISTANCE SELECTION AS A UIPOPOVER WITH A TABLE OF VALUES 1 thru x (currently 10)

//&$&#&**#Q*----Make sure to NOT update pos occ arr for both forward and reverse sequence when indels are matched---()($*QQ*(#**Q#$*
        //******TOP PRIORITY

//*#%*#@&*&*THE UPDATE POS OCC ARR METHOD DOES NOT NEED ORIGINAL STR PASSED IN

//ADD BUTTON TO ANALYSIS CONTROLLER THAT DISPLAYS A POP UP WITH A HISTOGRAM (X AXIS: 0 TO MAXCOVERAGEVAL, Y AXIS: # OF BASES THAT HAVE THAT COVERAGE)

//FOR GETBESTMATCHFORQUERY, MAKE AN OBJECT TO RETURN (WITH POS, ISREVERSE, AND POSSIBLY OTHER FIELDS)
//Problem: Making kIpadBoxWidth an int prevents flicker, but making it a double makes zoom in/out correct--DONE


//The error in console is for this reason: http://stackoverflow.com/questions/7471027/overriding-layoutsubviews-causes-cgaffinetransforminvert-singular-matrix-ran
//IF FONT IS BELOW kMinFontSize (4 or 5), than don't even draw the txt

@protocol QuickGridViewDelegate <NSObject>
//- (void)gridPointClickedWithCoordInGrid:(CGPoint)c andOriginInGrid:(CGPoint)o;
- (void)mutationFoundAtPos:(int)pos;
- (void)gridFinishedUpdatingWithOffset:(double)currOffset;
- (NSArray*)getCumulativeSeparateGenomeLenArray;
- (void)shouldUpdateGenomeNameLabelForIndexInSeparateGenomeLenArray:(int)index;
@end

@interface QuickGridView : UIView <UIScrollViewDelegate> {
    
    UILabel *maxCovLbl;
    UIImageView *tickMarkConnectingLine;
    
    DNAColors *dnaColors;
    
    UIScrollView *scrollingView;
    UIImageView *drawingView;
    
    double currOffset;
    
    //Constants made into a variable for pinch zoom
    double boxWidth;
    double kTxtFontSize;
    double kMinTxtFontSize;
    int kPosLblInterval;
    
    double graphBoxHeight;
    double boxHeight;
    
    int totalRows;
    int totalCols;
    
    int maxCoverageVal;
    
    id delegate;
    
    //Temp variable
    float prevOffset;
    
    UIImage *newDrawingViewImg;
    
}
@property (nonatomic) double boxHeight, currOffset, kTxtFontSize, kMinTxtFontSize, graphBoxHeight;
@property (nonatomic) double boxWidth;
@property (nonatomic) BOOL shouldUpdateScrollView;
@property (nonatomic) int totalRows, totalCols, kGridLineWidthCol;
@property (nonatomic) UIScrollView *scrollingView;
@property (nonatomic) UIImageView *drawingView;
@property (nonatomic) id <QuickGridViewDelegate> delegate;
@property (nonatomic) char *refSeq;

- (IBAction)pxlOffsetSliderValChanged:(id)sender;

- (void)firstSetUp;
- (void)setUpWithNumOfRows:(int)rows andCols:(int)cols andGraphBoxHeight:(double)gbHeight;
- (void)setUpGridViewForPixelOffset:(double)offSet;
- (void)resetScrollViewContentSize;
- (void)drawGridLinesForOffset:(double)offset;
- (void)drawDefaultBoxColors;

- (void)drawTickMarksForStartingPos:(int)pos;
- (void)resetTickMarkInterval;

- (void)initialMutationFind;

- (int)firstPtToDrawForOffset:(double)offset;
- (double)offsetOfPt:(double)point;
- (double)firstPtToDrawOffset:(double)offset;

- (void)drawText:(NSString*)txt atPoint:(CGPoint)point withRGB:(double[3])rgb;
- (void)drawRectangle:(CGRect)rect withRGB:(double[3])rgb;

- (void)scrollToPos:(double)p;
- (void)updateScrollView:(UISlider*)s;
@end
