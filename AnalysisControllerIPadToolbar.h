//
//  AnalysisControllerIPadToolbar.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 8/4/14.
//
//

#import <UIKit/UIKit.h>

@interface AnalysisControllerIPadToolbar : UIView <UIScrollViewDelegate> {
    IBOutlet UIPageControl *pageControl;
    IBOutlet UIScrollView *scrollView;
    
    NSArray *pages;
    IBOutlet UIView *utilitiesView;
    IBOutlet UIView *infoView;
}
- (void)setUp;
@end
