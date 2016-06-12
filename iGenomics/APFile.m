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
        
        NSRange rangeOfDot = [name rangeOfString:@"." options:NSBackwardsSearch];
        if (rangeOfDot.length > 0)
            ext = [name substringFromIndex:rangeOfDot.location+1];
        else
            ext = @"";
        fileType = ft;
    }
    return self;
}

+ (NSString*)fileNameWithoutExtForFile:(APFile*)file {
    NSRange rangeOfDot = [file.name rangeOfString:@"." options:NSBackwardsSearch];
    if (rangeOfDot.length > 0)
        return [file.name substringToIndex:rangeOfDot.location];
    else
        return file.name;
}

@end
