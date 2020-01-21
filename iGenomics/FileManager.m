//
//  FileManager.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 7/21/14.
//
//

#import "FileManager.h"

@implementation FileManager

@synthesize defaultFileNames, dropboxFileNames;//, dbFileSys;

+ (void)initializeFileSystems {
    [FileManager initializeLocalFilesDirectories];
    [FileManager intilializeDefaultFilesDict];
}

+ (void)intilializeDefaultFilesDict {
    if (defaultFiles)
        return;
    defaultFiles = [[NSMutableDictionary alloc] init];
    
    defaultFiles[kDefaultRefFilesNamesFile] = [FileManager defaultFilesForFileNameFile:kDefaultRefFilesNamesFile ofType:kTxt];
    defaultFiles[kDefaultReadsFilesNamesFile] = [FileManager defaultFilesForFileNameFile:kDefaultReadsFilesNamesFile ofType:kTxt];
    defaultFiles[kDefaultImptMutsFilesNamesFile] = [FileManager defaultFilesForFileNameFile:kDefaultImptMutsFilesNamesFile ofType:kTxt];
}

+ (void)initializeLocalFilesDirectories {
    NSArray *localFileDirectoryNames = @[kLocalRefFilesDirectoryName, kLocalReadsFilesDirectoryName, kLocalImptMutsFilesDirectoryName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
   
    for (NSString *n in localFileDirectoryNames) {
        NSString *newDirectory = [documentsDirectory stringByAppendingPathComponent:n];
        
        if (![fileManager fileExistsAtPath:newDirectory])
            [fileManager createDirectoryAtPath:newDirectory withIntermediateDirectories:NO attributes:nil error:nil];
    }
}

+ (NSArray*)defaultFilesForFileNameFile:(NSString *)fileName ofType:(NSString*)ext {
    NSArray *names = [[NSArray alloc] initWithArray:[[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:ext] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:kLineBreak]];
    NSMutableArray *files = [[NSMutableArray alloc] init];
    for (NSString* name in names) {
        APFile *file = [[APFile alloc] initWithName:name contents:@"" fileType:APFileTypeDefault];
        [files addObject:file];
    }
    return (NSArray*)files;
}

+ (APFile*)defaultFileForFileWithOnlyName:(APFile*)file {
    NSString *name = [APFile fileNameWithoutExtForFile:file];
    file.contents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:file.ext] encoding:NSUTF8StringEncoding error:nil];
    return file;
}

+ (NSArray*)defaultFilesForKey:(NSString *)key {
    return defaultFiles[key];
}

+ (void)addLocalFile:(APFile*)file inDirectory:(NSString*)directory {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *directoryToWriteTo = [documentsDirectory stringByAppendingPathComponent:directory];
    
    [manager createFileAtPath:[directoryToWriteTo stringByAppendingPathComponent:file.name] contents:[file.contents dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}

+ (void)deleteLocalFile:(APFile*)file inDirectory:(NSString*)directory {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *specificDirectory = [documentsDirectory stringByAppendingPathComponent:directory];
    
    [manager removeItemAtPath:[specificDirectory stringByAppendingPathComponent:file.name] error:nil];
}

+ (void)renameLocalFile:(APFile*)file forNewFileName:(NSString*)newName inDirectory:(NSString*)directory {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *specificDirectory = [documentsDirectory stringByAppendingPathComponent:directory];
    
    [manager copyItemAtPath:[specificDirectory stringByAppendingPathComponent:file.name] toPath:[specificDirectory stringByAppendingPathComponent:[newName stringByAppendingPathExtension:file.ext]] error:nil];
    [FileManager deleteLocalFile:file inDirectory:directory];
}

+ (NSArray*)getLocalFileWithoutContentsArrayFromDirectory:(NSString*)directory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSArray *arr = [fileManager subpathsAtPath:[documentsDirectory stringByAppendingPathComponent:directory]];
    
    NSMutableArray *filesArr = [[NSMutableArray alloc] init];
    for (NSString *n in arr)
        [filesArr addObject:[[APFile alloc] initWithName:n contents:@"" fileType:APFileTypeLocal]];
    return (NSArray*)filesArr;
}

+ (APFile*)localFileForFileWithOnlyName:(APFile*)file inDirectory:(NSString*)directory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    file.contents = [[NSString alloc] initWithData:[fileManager contentsAtPath:[[documentsDirectory stringByAppendingPathComponent:directory] stringByAppendingPathComponent:file.name]] encoding:NSUTF8StringEncoding];
    return file;
}

- (void)setUpWithDefaultFileNamesPath:(NSString*)path ofType:(NSString*)type {
    defaultFileNames = [[NSMutableArray alloc] initWithArray:[[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:path ofType:kTxt] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:kLineBreak]];
}

//- (void)setUpForDropbox {
//    if ([DBAccountManager sharedManager].linkedAccount && ![DBFilesystem sharedFilesystem]) {
//        dbFileSys = [[DBFilesystem alloc] initWithAccount:[DBAccountManager sharedManager].linkedAccount];
//        [DBFilesystem setSharedFilesystem:dbFileSys];
//    }
//    else if ([DBAccountManager sharedManager].linkedAccount && [DBFilesystem sharedFilesystem]) {
//        dbFileSys = [DBFilesystem sharedFilesystem];
//    }
//
//    dropboxFileNames = [[NSMutableArray alloc] initWithArray:[dbFileSys listFolder:[DBPath root] error:nil]];
//}

- (void)setMaxFileSize:(int)maxFS {
    maxFileSize = maxFS;
}

//- (NSString*)fileContentsForPath:(DBPath*)path {
//    if ([path.name isEqualToString:lastOpenedFileName])
//        return lastOpenedFileContents;
//    DBFile *file = [dbFileSys openFile:path error:nil];
//    if (file.info.size > maxFileSize) {
//        [GlobalVars displayiGenomicsAlertWithMsg:[NSString stringWithFormat:kDropboxFileTooLargeAlertMsg]];
//        return @"";
//    }
//    lastOpenedFileName = path.name;
//    lastOpenedFileContents = [file readString:nil];
//    [file close];
//    return lastOpenedFileContents;
//}

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
//
//+ (NSArray*)fileArrayByKeepingOnlyFilesOfTypes:(NSMutableArray *)fileTypes fromDropboxFileArray:(NSMutableArray *)array {
//    array = [NSMutableArray arrayWithArray:array];//Duplicates it so that changes are not saved in the original array
//    if ([array count] >= 1) {
//        for (int i = 0; i < [array count]; i++) {
//            DBFileInfo *info = [array objectAtIndex:i];
//            if (!info.isFolder) {
//                BOOL passesTest = NO;
//                for (int j = 0; j < [fileTypes count]; j++) {
//                    if ([[GlobalVars extFromFileName:[info.path name]] caseInsensitiveCompare:[fileTypes objectAtIndex:j]] == NSOrderedSame) {
//                        passesTest = YES;
//                        break;
//                    }
//                }
//                if (!passesTest) {
//                    [array removeObjectAtIndex:i];
//                    i--;
//                }
//            }
//        }
//    }
//    return array;
//}

+ (NSData*)dataDownloadedFromURL:(NSURL*)url {
    return [NSData dataWithContentsOfURL:url];
}

+ (BOOL)filePassesValidation:(APFile *)file againstExts:(NSArray *)exts {
    for (NSString *ext in exts)
        if ([file.ext isEqualToString:ext])
            return YES;
    return NO;
}

+ (FileTypeSelectionOption)getFileTypeSelectionOptionOfFile:(APFile*)file {
    //This order of determining the file selection option is the fastest order for doing so
    
    BOOL isFastq = [file.ext isEqualToString:kFq] || [file.ext isEqualToString:kFastq];
    if (isFastq)
        return FileTypeSelectionOptionReads;
    
    BOOL isImptMuts = [file.ext isEqualToString:kImptMutsFileExt];
    if (isImptMuts)
        return FileTypeSelectionOptionImptMuts;
    
    BOOL isFasta = [file.ext isEqualToString:kFa] || [file.ext isEqualToString:kFasta];
    if (isFasta)
        return FileTypeSelectionOptionDNATypeUndetermined;
    
    return -1;
}

@end
