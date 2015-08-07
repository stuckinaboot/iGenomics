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

+ (void)intilializeDefaultFilesDict {
    if (defaultFiles)
        return;
    defaultFiles = [[NSMutableDictionary alloc] init];
    
    defaultFiles[kDefaultRefFilesNamesFile] = [FileManager defaultFilesForFileNameFile:kDefaultRefFilesNamesFile ofType:kTxt];
    defaultFiles[kDefaultReadsFilesNamesFile] = [FileManager defaultFilesForFileNameFile:kDefaultReadsFilesNamesFile ofType:kTxt];
    defaultFiles[kDefaultImptMutsFilesNamesFile] = [FileManager defaultFilesForFileNameFile:kDefaultImptMutsFilesNamesFile ofType:kTxt];
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

+ (void)addLocalFile:(APFile*)file forLocalFileNamesFileName:(NSString*)fileName {
    NSMutableArray *names = [[NSMutableArray alloc] initWithArray:[FileManager getLocalFileNamesArrayFromFileName:fileName]];
    [names addObject:file];
    [FileManager writeLocalFileNamesArrayToFile:names fileNameToWriteTo:fileName];
    [FileManager writeLocalFileToDocuments:file];
}

+ (void)deleteLocalFile:(APFile*)file forLocalFileNamesFileName:(NSString*)fileName {
    
}

+ (void)renameLocalFile:(APFile*)file forNewFileName:(NSString*)newName forLocalFileNamesFileName:(NSString*)fileName {
    
}

+ (void)writeLocalFileToDocuments:(APFile *)file {
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/%@",
                          documentsDirectory,file.name];
    
    //save content to the documents directory
    [file.contents writeToFile:fileName atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
}

+ (void)writeLocalFileNamesArrayToFile:(NSArray*)fileNames fileNameToWriteTo:(NSString*)fileNameToWriteTo {
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/%@",
                          documentsDirectory,fileNameToWriteTo];
    //create content - four lines of text
    NSMutableString *content = [[NSMutableString alloc] init];
    for (int i = 0; i < [fileNames count]; i++) {
        NSString *name = ((APFile*)[fileNames objectAtIndex:i]).name;
        if (i < [fileNames count]-1)
            [content appendFormat:@"%@\n",name];
        else
            [content appendFormat:@"%@",name];
    }
    
    //save content to the documents directory
    [content writeToFile:fileName atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
}

+ (NSArray*)getLocalFileNamesArrayFromFileName:(NSString*)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fName = [NSString stringWithFormat:@"%@/%@",
                          documentsDirectory, fileName];
    NSArray *nameArr = [[[NSString alloc] initWithContentsOfFile:fName usedEncoding:nil error:nil] componentsSeparatedByString:kLineBreak];
    NSMutableArray *fileArr = [[NSMutableArray alloc] init];
    
    for (NSString* n in nameArr)
        [fileArr addObject:[[APFile alloc] initWithName:n contents:@"" fileType:APFileTypeLocal]];
    return fileArr;
}

+ (APFile*)localFileForFileWithOnlyName:(APFile*)file {
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fName = [NSString stringWithFormat:@"%@/%@",
                       documentsDirectory, file.name];
    NSString *contents = [[NSString alloc] initWithContentsOfFile:fName usedEncoding:nil error:nil];
    file.contents = contents;
    
    return file;
}

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

- (void)setMaxFileSize:(int)maxFS {
    maxFileSize = maxFS;
}

- (NSString*)fileContentsForPath:(DBPath*)path {
    if ([path.name isEqualToString:lastOpenedFileName])
        return lastOpenedFileContents;
    DBFile *file = [dbFileSys openFile:path error:nil];
    if (file.info.size > maxFileSize) {
        [GlobalVars displayiGenomicsAlertWithMsg:[NSString stringWithFormat:kDropboxFileTooLargeAlertMsg]];
        return @"";
    }
    lastOpenedFileName = path.name;
    lastOpenedFileContents = [file readString:nil];
    [file close];
    return lastOpenedFileContents;
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
