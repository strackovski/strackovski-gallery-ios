//
//  GlobalVars.m
//  StrackovskiGallery
//
//  Created by Vladimir Stračkovski on 04/09/14.
//  Copyright (c) 2014 Vladimir Stračkovski. All rights reserved.
//

#import "GlobalVars.h"

@implementation GlobalVars
@synthesize currentIndex = _currentIndex;

+(GlobalVars*)sharedInstance
{
    static dispatch_once_t onceToken;
    static GlobalVars *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[GlobalVars alloc] init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _currentIndex = [NSNumber numberWithInt:0];
    }
    return self;
}

@end
