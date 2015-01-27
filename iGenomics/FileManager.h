//
//  FileManager.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 7/21/14.
//
//

#import <Foundation/Foundation.h>
#import <Dropbox/Dropbox.h>
#import "GlobalVars.h"

#define kDefaultRefFilesNamesFile @"NamesOfDefaultReferenceFiles"
#define kDefaultReadsFilesNamesFile @"NamesOfDefaultReadsFiles"
#define kDefaultImptMutsFilesNamesFile @"NamesOfDefaultImptMutsFiles"

@interface FileManager : NSObject {
    NSString *lastOpenedFileName;
    NSString *lastOpenedFileContents;
    
    int maxFileSize;
}
@property (nonatomic) NSMutableArray *defaultFileNames;
@property (nonatomic) NSMutableArray *dropboxFileNames;
@property (nonatomic, readonly) DBFilesystem *dbFileSys;
- (void)setUpWithDefaultFileNamesPath:(NSString*)path ofType:(NSString*)type;
- (void)setUpForDropbox;
- (void)setMaxFileSize:(int)maxFS;

- (NSMutableArray*)fileNamesArrayWithNamesContainingTxt:(NSString*)txt inArr:(NSArray*)arr;
- (NSMutableArray*)fileNamesForPath:(DBPath*)path;

- (NSString*)fileContentsForPath:(DBPath*)path;
- (NSString*)fileContentsForNameWithExt:(NSString*)name;

+ (NSArray*)getFileNameAndExtForFullName:(NSString*)fileName;//returns array with two NSStrings, fileName and fileExt
+ (NSMutableArray*)fileArrayByKeepingOnlyFilesOfTypes:(NSArray*)fileTypes fromDropboxFileArray:(NSMutableArray*)array;
@end
