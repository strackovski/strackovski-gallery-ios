//
//  SSImageGetter.h
//  Retrieves artwork images from HTTP server
//  StrackovskiGallery
//
//  Created by Vladimir Stračkovski on 04/09/14.
//  Copyright (c) 2014 Vladimir Stračkovski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSImageGetter : NSObject

+(SSImageGetter*)sharedInstance;
-(void)getImages;

@end
