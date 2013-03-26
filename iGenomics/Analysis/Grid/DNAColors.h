//
//  DNAColors.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 3/17/13.
//
//

#import <Foundation/Foundation.h>
#import "RGB.h"

@interface DNAColors : NSObject {
    
}
@property (nonatomic) RGB *defaultBackground,
                        *defaultLbl,
                        *refLbl,
                        *foundLbl,
                        *aLbl,
                        *cLbl,
                        *gLbl,
                        *tLbl,
                        *delLbl,
                        *insLbl,
                        *mutHighlight;
- (void)setUp;
@end