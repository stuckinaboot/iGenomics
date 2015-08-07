//
//  FileManager.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 7/21/14.
//
//

#import <Foundation/Foundation.h>
#import <Dropbox/Dropbox.h>
#import "APFile.h"
#import "GlobalVars.h"

#define kDefaultRefFilesNamesFile @"NamesOfDefaultReferenceFiles"
#define kDefaultReadsFilesNamesFile @"NamesOfDefaultReadsFiles"
#define kDefaultImptMutsFilesNamesFile @"NamesOfDefaultImptMutsFiles"

#define kLocalRefFilesNamesFileName @"NamesOfLocalReferenceFiles.txt"
#define kLocalReadsFilesNamesFileName @"NamesOfLocalReadsFiles.txt"
#define kLocalImptMutsFilesNamesFileName @"NamesOfLocalImptMutsFiles.txt"

static NSMutableDictionary *defaultFiles;

typedef enum {
    FileTypeSelectionOptionRef,
    FileTypeSelectionOptionReads,
    FileTypeSelectionOptionImptMuts,
    FileTypeSelectionOptionDNATypeUndetermined
} FileTypeSelectionOption;

@interface FileManager : NSObject {
    NSString *lastOpenedFileName;
    NSString *lastOpenedFileContents;
    
    int maxFileSize;
}
@property (nonatomic) NSMutableArray *defaultFileNames;
@property (nonatomic) NSMutableArray *dropboxFileNames;
@property (nonatomic, readonly) DBFilesystem *dbFileSys;

+ (void)intilializeDefaultFilesDict;//Only needs to be called once total (static Dict) --Initializes the dict with the file names, no contents are loaded so that memory can be saved and contents will only be loaded individually and when they need to be
+ (NSArray*)defaultFilesForFileNameFile:(NSString *)fileName ofType:(NSString*)ext;
+ (APFile*)defaultFileForFileWithOnlyName:(APFile*)file;
+ (NSArray*)defaultFilesForKey:(NSString*)key;

+ (void)addLocalFile:(APFile*)file forLocalFileNamesFileName:(NSString*)fileName;
+ (void)deleteLocalFile:(APFile*)file forLocalFileNamesFileName:(NSString*)fileName;
+ (void)renameLocalFile:(APFile*)file forNewFileName:(NSString*)newName forLocalFileNamesFileName:(NSString*)fileName;
+ (void)writeLocalFileToDocuments:(APFile*)file;
+ (void)writeLocalFileNamesArrayToFile:(NSArray*)fileNames fileNameToWriteTo:(NSString*)fileNameToWriteTo;
+ (NSArray*)getLocalFileNamesArrayFromFileName:(NSString*)fileName;
+ (APFile*)localFileForFileWithOnlyName:(APFile*)file;

- (void)setUpWithDefaultFileNamesPath:(NSString*)path ofType:(NSString*)type;
- (void)setUpForDropbox;
- (void)setMaxFileSize:(int)maxFS;

- (NSString*)fileContentsForPath:(DBPath*)path;
- (NSString*)fileContentsForNameWithExt:(NSString*)name;

+ (NSArray*)getFileNameAndExtForFullName:(NSString*)fileName;//returns array with two NSStrings, fileName and fileExt
+ (NSMutableArray*)fileArrayByKeepingOnlyFilesOfTypes:(NSArray*)fileTypes fromDropboxFileArray:(NSMutableArray*)array;

+ (NSData*)dataDownloadedFromURL:(NSURL*)url;
+ (BOOL)filePassesValidation:(APFile*)file againstExts:(NSArray*)exts;

+ (FileTypeSelectionOption)getFileTypeSelectionOptionOfFile:(APFile*)file;
@end
