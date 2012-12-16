//
//  ED_Info.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 11/11/12.
//
//

#import <Foundation/Foundation.h>

//used for info returned by the EditDist class

@interface ED_Info : NSObject {
    char *gappedA;
    char *gappedB;
    int position;
    int distance;
    BOOL insertion;
}
@property (nonatomic) char *gappedA, *gappedB;
@property (nonatomic) int position, distance;
@property (nonatomic) BOOL insertion;
@end
