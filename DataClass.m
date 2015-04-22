//
//  DataClass.m
//  Provides common methods for view controllers
//  StrackovskiGallery
//
//  Created by Vladimir Stračkovski on 30/03/15.
//  Copyright (c) 2015 Vladimir Stračkovski. All rights reserved.
//

#import "DataClass.h"
#import "Reachability.h"

@implementation DataClass
@synthesize str;

static DataClass *instance = nil;

+(DataClass *)getInstance
{
    @synchronized(self) {
        if(instance==nil) {
            instance= [DataClass new];
        }
    }
    return instance;
}

-(NSString*)checkConnection {
    NetworkStatus wifiStatus = [[Reachability reachabilityForLocalWiFi] currentReachabilityStatus];
    NetworkStatus internetStatus = [[Reachability reachabilityForInternetConnection]currentReachabilityStatus];
    
    BOOL wifiIsOn = [[NSUserDefaults standardUserDefaults]boolForKey:@"wifiValue"];
    NSLog(@"wifiison: %d", wifiIsOn);
    
    BOOL mobileNetworkIsOn = [[NSUserDefaults standardUserDefaults]boolForKey:@"mobileNetworkValue"];
    NSLog(@"mobilenet: %d", mobileNetworkIsOn);
    if (wifiStatus == ReachableViaWiFi && wifiIsOn) {
        return @"wifi";
    } else if (internetStatus == ReachableViaWWAN && mobileNetworkIsOn) {
        return @"wwan";
    } else {
        return @"none";
    }
}

@end
