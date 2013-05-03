//
//  BWT_Matcher_Approxi.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 4/20/13.
//
//

#import <Foundation/Foundation.h>
#import "BWT_MatcherSC.h"
#import "BWT_Matcher.h"
#import "MatchedReadData.h"

@interface BWT_Matcher_Approxi : BWT_MatcherSC
- (NSArray*)approxiMatchForQuery:(char*)query withLastCol:(char*)lastCol andFirstCol:(char*)firstCol andNumOfSubs:(int)amtOfSubs andIsReverse:(BOOL)isRev;
@end
