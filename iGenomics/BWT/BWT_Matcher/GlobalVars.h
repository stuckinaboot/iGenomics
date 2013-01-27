//
//  GlobalVars.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/19/13.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    MatchTypeExactOnly,
    MatchTypeExactAndSubs,
    MatchTypeSubsAndIndels
} MatchType;

@interface GlobalVars : NSObject

@end
