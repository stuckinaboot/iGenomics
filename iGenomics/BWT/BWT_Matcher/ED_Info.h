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
    char *readName;
    int position;
    int distance;
    BOOL insertion;
    BOOL isRev;
}
@property (nonatomic) BOOL isRev;
@property (nonatomic) char *gappedA, *gappedB, *readName;
@property (nonatomic) int position, distance;
@property (nonatomic) BOOL insertion;
- (id)initWithPos:(int)pos editDistance:(int)dist gappedAStr:(char*)gA gappedBStr:(char*)gB isIns:(BOOL)ins isReverse:(BOOL)isReverse;
@end
