//
//  ImportantMutationInfo.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 7/22/14.
//
//

#import "MutationInfo.h"

typedef enum {
    ImportantMutationMatchTypeHomozygousOther,
    ImportantMutationMatchTypeHomozygousMut,
    ImportantMutationMatchTypeHeterozygousOther,
    ImportantMutationMatchTypeHeterozygousMut,
    ImportantMutationMatchTypeNoMutation,
    ImportantMutationMatchTypeNoAlignments
} ImportantMutationMatchType;

@interface ImportantMutationInfo : MutationInfo {

}
@property (nonatomic) NSString *details; //Optional, only used for important mutations file mutations
@property (nonatomic) ImportantMutationMatchType matchType;
@end
