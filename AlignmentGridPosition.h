//
//  AlignmentGridPosition.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 7/11/14.
//
//

#import <Foundation/Foundation.h>

//At every position in the alignment grid, there is an AlignmentGridPosition object

#define kAlignmentGridViewReadStartIndexNone -1

#define kAlignmentGridViewCharColumnNoChar ' '//An arbitrary # to avoid confusion with any base-pair

#define kReadInfoReadMiddle 0
#define kReadInfoReadStart 1
#define kReadInfoReadEnd 2
#define kReadInfoReadPosAfterStart 3
#define kReadInfoReadPosBeforeEnd 4

@interface AlignmentGridPosition : NSObject {
    
}
@property (nonatomic) int startIndexInreadAlignmentsArr, readLen;
@property (nonatomic) int positionRelativeToReadStart;//0 if is start of the read
@property (nonatomic) NSMutableString *str;
@property (nonatomic) NSMutableString *readInfoStr;
@end
