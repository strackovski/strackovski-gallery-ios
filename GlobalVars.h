//
//  GlobalVars.h
//  StrackovskiGallery
//
//  Created by Vladimir Stračkovski on 04/09/14.
//  Copyright (c) 2014 Vladimir Stračkovski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalVars : NSObject {
    NSNumber *_currentIndex;
}

+(GlobalVars*)sharedInstance;

@property (strong, nonatomic, readwrite) NSNumber *currentIndex;

@end
