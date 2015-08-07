//
//  APFile.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 8/4/15.
//
//

#import "APFile.h"

@implementation APFile

@synthesize name, contents, ext, fileType;


- (id)initWithName:(NSString*)n contents:(NSString*)c fileType:(APFileType)ft {
    self = [super init];
    if (self) {
        name = n;
        contents = c;
        ext = [name substringFromIndex:[name rangeOfString:@"." options:NSBackwardsSearch].location+1];
        fileType = ft;
    }
    return self;
}

+ (NSString*)fileNameWithoutExtForFile:(APFile*)file {
    return [file.name substringToIndex:[file.name rangeOfString:@"." options:NSBackwardsSearch].location];
}

@end
