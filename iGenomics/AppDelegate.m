//
//  AppDelegate.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [DBClientsManager setupWithAppKey:kDropboxKey];
//    DBAccountManager* accountMgr = [[DBAccountManager alloc] initWithAppKey:kDropboxKey secret:kDropboxSecret];
//    [DBAccountManager setSharedManager:accountMgr];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
    } else {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
    }
    
    
    isOutdatedDevice = NO;
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *specificDeviceType = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    for (int i = 0; i < kOutdatedDevicesArrayCount; i++) {
        if ([specificDeviceType isEqualToString:kOutdatedDevicesArray[i]]) {
            isOutdatedDevice = YES;
            break;
        }
    }
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

//For dropbox
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
  sourceApplication:(NSString *)source annotation:(id)annotation {
    if (url != nil && [url isFileURL]) {
        NSString *ext = [url pathExtension];
        
        NSString *name = [[url absoluteString] lastPathComponent];
        
        if ([ext isEqualToString:kFa] || [ext isEqualToString:kFasta] || [ext isEqualToString:kFq] || [ext isEqualToString:kFastq] || [ext isEqualToString:kImptMutsFileExt]) {
            NSString *contents = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
            
            APFile *file = [[APFile alloc] initWithName:name contents:contents fileType:APFileTypeLocal];
            NSDictionary *dict = @{kFilePickerControllerNotificationExternalFileLoadedDictAPFileKey : file};

            [[NSNotificationCenter defaultCenter] postNotificationName:kFilePickerControllerNotificationExternalFileLoadedKey object:nil userInfo:dict];

            return YES;
        }
        return NO;
    }
    else if ([[DBChooser defaultChooser] handleOpenURL:url]) {
        // This was a Chooser response and handleOpenURL automatically ran the
        // completion block
        return YES;
    }
    else {
        DBOAuthResult *authResult = [DBClientsManager handleRedirectURL:url];
        if (authResult != nil) {
            if ([authResult isSuccess]) {
                NSLog(@"Success! User is logged into Dropbox.");
                [GlobalVars displayiGenomicsAlertWithMsg:kDropboxLinkedSuccessfullyAlertMsg];
            } else if ([authResult isCancel]) {
                NSLog(@"Authorization flow was manually canceled by user!");
            } else if ([authResult isError]) {
                NSLog(@"Error: %@", authResult);
            }
        }
        return YES;
//        DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
//        if (account) {
//            DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
//            [DBFilesystem setSharedFilesystem:filesystem];
//            [GlobalVars displayiGenomicsAlertWithMsg:kDropboxLinkedSuccessfullyAlertMsg];
//            return YES;
//        }
//        return NO;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
