//
//  FileManager.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 7/21/14.
//
//

#import "FileManager.h"

@implementation FileManager

@synthesize defaultFileNames, dropboxFileNames, dbFileSys;

- (void)setUpWithDefaultFileNamesPath:(NSString*)path ofType:(NSString*)type {
    defaultFileNames = [[NSMutableArray alloc] initWithArray:[[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:path ofType:kTxt] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:kLineBreak]];
}

- (void)setUpForDropbox {
    if ([DBAccountManager sharedManager].linkedAccount && ![DBFilesystem sharedFilesystem]) {
        dbFileSys = [[DBFilesystem alloc] initWithAccount:[DBAccountManager sharedManager].linkedAccount];
        [DBFilesystem setSharedFilesystem:dbFileSys];
    }
    else if ([DBAccountManager sharedManager].linkedAccount && [DBFilesystem sharedFilesystem]) {
        dbFileSys = [DBFilesystem sharedFilesystem];
    }
    
    dropboxFileNames = [[NSMutableArray alloc] initWithArray:[dbFileSys listFolder:[DBPath root] error:nil]];
}

- (NSMutableArray*)fileNamesArrayWithNamesContainingTxt:(NSString*)txt inArr:(NSArray*)arr {
    NSMutableArray *filteredArr = [[NSMutableArray alloc] init];
    for (NSString* s in arr) {
        NSRange nameRange = [s rangeOfString:txt options:NSCaseInsensitiveSearch];
        if (nameRange.location != NSNotFound)
            [filteredArr addObject:s];
    }
    return filteredArr;
}

- (NSMutableArray*)fileNamesForPath:(DBPath *)path {
    return (NSMutableArray*)[dbFileSys listFolder:path error:nil];
}

- (NSString*)fileContentsForPath:(DBPath*)path {
    DBFile *file = [dbFileSys openFile:path error:nil];
    return [file readString:nil];
}

- (NSString*)fileContentsForNameWithExt:(NSString*)name {
    NSArray *arr = [FileManager getFileNameAndExtForFullName:name];
    return [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[arr objectAtIndex:0] ofType:[arr objectAtIndex:1]] encoding:NSUTF8StringEncoding error:nil];
}

+ (NSArray*)getFileNameAndExtForFullName:(NSString *)fileName {
    //Search for first . starting from the end
    int index = 0;
    for (int i = fileName.length-1; i>0; i--) {
        if ([fileName characterAtIndex:i] == kExtDot) {
            index = i;
            break;
        }
    }
    return [NSArray arrayWithObjects:[fileName substringToIndex:index], [fileName substringFromIndex:index+1],nil];
}

+ (NSArray*)fileArrayByKeepingOnlyFilesOfTypes:(NSMutableArray *)fileTypes fromDropboxFileArray:(NSMutableArray *)array {
    array = [NSMutableArray arrayWithArray:array];//Duplicates it so that changes are not saved in the original array
    if ([array count] >= 1) {
        for (int i = 0; i < [array count]; i++) {
            DBFileInfo *info = [array objectAtIndex:i];
            if (!info.isFolder) {
                BOOL passesTest = NO;
                for (int j = 0; j < [fileTypes count]; j++) {
                    if ([[GlobalVars extFromFileName:[info.path name]] caseInsensitiveCompare:[fileTypes objectAtIndex:j]] == NSOrderedSame) {
                        passesTest = YES;
                        break;
                    }
                }
                if (!passesTest) {
                    [array removeObjectAtIndex:i];
                    i--;
                }
            }
        }
    }
    return array;
}

@end
