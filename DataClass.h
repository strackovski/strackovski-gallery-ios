//
//  DataClass.h
//  Provides common methods for view controllers
//  StrackovskiGallery
//
//  Created by Vladimir Stračkovski on 30/03/15.
//  Copyright (c) 2015 Vladimir Stračkovski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataClass : NSObject {
    NSString *str;
}

@property(nonatomic,retain)NSString *str;

+(DataClass*)getInstance;
-(NSString*)checkConnection;

@end
