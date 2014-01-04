//
//  Reads.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 12/11/13.
//
//

#import <Foundation/Foundation.h>

@interface Read : NSObject {
    char *sequence;
    char *name;
}
@property (nonatomic) char *sequence, *name;
- (id)initWithSeq:(char*)s andName:(char*)n;
@end
