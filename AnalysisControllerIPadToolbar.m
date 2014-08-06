//
//  AnalysisControllerIPadToolbar.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 8/4/14.
//
//

#import "AnalysisControllerIPadToolbar.h"

@implementation AnalysisControllerIPadToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setUp {
    pages = [NSArray arrayWithObjects:infoView, utilitiesView,nil];
    
    scrollView.contentSize = CGSizeMake(self.bounds.size.width*[pages count], scrollView.bounds.size.height);
    
    float x = 0;
    CGSize size = scrollView.frame.size;
    for (UIView *view in pages) {
        [view setFrame:CGRectMake(x, 0, size.width, view.frame.size.height)];
        [scrollView addSubview:view];
        x += scrollView.frame.size.width;
    }
    
    [pageControl setNumberOfPages:[pages count]];
    [pageControl setCurrentPage:0];
    [self bringSubviewToFront:pageControl];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.bounds.size.width;
    int page = floorf((scrollView.contentOffset.x - pageWidth/2.0f) / pageWidth) + 1;
    pageControl.currentPage = page;
}

- (IBAction)pageChanged:(id)sender {
    CGRect rect = self.frame;
    [scrollView scrollRectToVisible:CGRectMake((pageControl.currentPage-1)*rect.size.width, 0, rect.size.width, rect.size.height) animated:YES];
}

@end
