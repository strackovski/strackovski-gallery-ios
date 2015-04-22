//
//  AppDelegate.m
//  Manages which view controller is added to the window at launch
//  StrackovskiGallery
//
//  Created by Vladimir Stračkovski on 03/09/14.
//  Copyright (c) 2014 Vladimir Stračkovski. All rights reserved.
//  See http://github.com/strackovski/strackovski-gallery-ios
//

#import "AppDelegate.h"
#import "MainViewController.h"
#include <unistd.h>
#include <netdb.h>
#import "Reachability.h"
#import "SSImageGetter.h"
#import "SSFTModalViewController.h"


@implementation AppDelegate {

}

-(BOOL)isNetworkAvailable {
    struct addrinfo *res = NULL;
    int s = getaddrinfo("apple.com", NULL, NULL, &res);
    bool network_ok = (s == 0 && res != NULL);
    freeaddrinfo(res);
    if (network_ok == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    MainViewController *mainViewController = [[MainViewController alloc]init];
    self.window.rootViewController = mainViewController;
    [self.window makeKeyAndVisible];
   
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"hasSeenTutorial"]) {
        MainViewController *main = (MainViewController*)self.window.rootViewController;
        [main regularUpdate];
    }
}

@end
