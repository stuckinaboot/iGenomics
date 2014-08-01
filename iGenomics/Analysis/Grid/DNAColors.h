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
                        *defaultLighterBackground,
                        *defaultLbl,
                        *covLbl,
                        *refLbl,
                        *foundLbl,
                        *aLbl,
                        *cLbl,
                        *gLbl,
                        *tLbl,
                        *delLbl,
                        *insLbl,
                        *mutHighlight,
                        *black,
                        *white,
                        *graph,
                        *segmentDivider,
                        *segmentDividerTxt,
                        *alignedRead,
                        *insertionIcon;

@property (nonatomic) UIColor  *importantMutationInfoHeterozygousMut,
                                *importantMutationInfoHomozygousMut,
                                *importantMutationInfoHeterozygousOther,
                                *importantMutationInfoHomozygousOther,
                                *importantMutationInfoNoMutation,
                                *importantMutationInfoNoAlignments;
- (void)setUp;
@end