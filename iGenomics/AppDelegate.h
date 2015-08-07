//
//  AppDelegate.h
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <dropbox/dropbox.h>
#import <DBChooser/DBChooser.h>
#import <sys/utsname.h>

#define kDropboxKey @"z7srp09ctjcw53l"
#define kDropboxSecret @"959puepnqbppevh"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@end
