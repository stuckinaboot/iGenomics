//
//  APFile.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 8/4/15.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    APFileTypeDropbox,
    APFileTypeLocal,
    APFileTypeDefault
} APFileType;

@interface APFile : NSObject {

}
@property (nonatomic) NSString *name, *contents, *ext;
@property (nonatomic) APFileType fileType;
- (id)initWithName:(NSString*)n contents:(NSString*)c fileType:(APFileType)ft;
+ (NSString*)fileNameWithoutExtForFile:(APFile*)file;
@end
