//
//  FileManager.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 7/21/14.
//
//

#import <Foundation/Foundation.h>
//#import <Dropbox/Dropbox.h>
//#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>
#import "APFile.h"
#import "GlobalVars.h"

#define kDefaultRefFilesNamesFile @"NamesOfDefaultReferenceFiles"
#define kDefaultReadsFilesNamesFile @"NamesOfDefaultReadsFiles"
#define kDefaultImptMutsFilesNamesFile @"NamesOfDefaultImptMutsFiles"

#define kLocalRefFilesDirectoryName @"NamesOfLocalReferenceFiles"
#define kLocalReadsFilesDirectoryName @"NamesOfLocalReadsFiles"
#define kLocalImptMutsFilesDirectoryName @"NamesOfLocalImptMutsFiles"

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
//@property (nonatomic, readonly) DBFilesystem *dbFileSys;

+ (void)initializeFileSystems;
+ (void)intilializeDefaultFilesDict;//Only needs to be called once total (static Dict) --Initializes the dict with the file names, no contents are loaded so that memory can be saved and contents will only be loaded individually and when they need to be
+ (void)initializeLocalFilesDirectories;
+ (NSArray*)defaultFilesForFileNameFile:(NSString *)fileName ofType:(NSString*)ext;
+ (APFile*)defaultFileForFileWithOnlyName:(APFile*)file;
+ (NSArray*)defaultFilesForKey:(NSString*)key;

+ (void)addLocalFile:(APFile*)file inDirectory:(NSString*)directory;
+ (void)deleteLocalFile:(APFile*)file inDirectory:(NSString*)directory;
+ (void)renameLocalFile:(APFile*)file forNewFileName:(NSString*)newName inDirectory:(NSString*)directory;

+ (NSArray*)getLocalFileWithoutContentsArrayFromDirectory:(NSString*)fileName;
+ (APFile*)localFileForFileWithOnlyName:(APFile*)file inDirectory:(NSString*)directory;

- (void)setUpWithDefaultFileNamesPath:(NSString*)path ofType:(NSString*)type;
//- (void)setUpForDropbox;
- (void)setMaxFileSize:(int)maxFS;

//- (NSString*)fileContentsForPath:(DBPath*)path;
- (NSString*)fileContentsForNameWithExt:(NSString*)name;

+ (NSArray*)getFileNameAndExtForFullName:(NSString*)fileName;//returns array with two NSStrings, fileName and fileExt
+ (NSMutableArray*)fileArrayByKeepingOnlyFilesOfTypes:(NSArray*)fileTypes fromDropboxFileArray:(NSMutableArray*)array;

+ (NSData*)dataDownloadedFromURL:(NSURL*)url;
+ (BOOL)filePassesValidation:(APFile*)file againstExts:(NSArray*)exts;

+ (FileTypeSelectionOption)getFileTypeSelectionOptionOfFile:(APFile*)file;
@end
