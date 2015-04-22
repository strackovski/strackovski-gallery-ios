//
//  MainViewController.h
//  StrackovskiGallery
//
//  Created by Vladimir Stračkovski on 03/09/14.
//  Copyright (c) 2014 Vladimir Stračkovski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UIPageViewControllerDataSource> {

}

@property BOOL wifiValue;
@property BOOL mobileNetworkValue;

-(void)firstDownload;
-(void)regularUpdate;

@end
