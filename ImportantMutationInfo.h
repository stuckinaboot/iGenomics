//
//  ImportantMutationInfo.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 7/22/14.
//
//

#import "MutationInfo.h"

@interface ImportantMutationInfo : MutationInfo {

}
@property (nonatomic) NSString *details; //Optional, only used for important mutations file mutations
@property (nonatomic) char matchType;
@end
