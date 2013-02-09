//
//  SearchQueryResultsPopover.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 2/4/13.
//
//

#import <UIKit/UIKit.h>

@protocol SearchQueryResultsDelegate <NSObject>
- (void)queryResultPosPicked:(int)pos;
@end
@interface SearchQueryResultsPopover : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *tbView;
    id delegate;
    
    NSArray *foundResults;
}
@property (nonatomic) id <SearchQueryResultsDelegate> delegate;
- (void)loadWithResults:(NSArray*)arr;
@end
