//
//  SSFTModalViewController.m
//  App settings modal
//  StrackovskiGallery
//
//  Created by Vladimir Stračkovski on 04/09/14.
//  Copyright (c) 2014 Vladimir Stračkovski. All rights reserved.
//

#import "SSFTModalViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SSImageGetter.h"
#import "MainViewController.h"
#import "Reachability.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SSFTModalViewController ()
@property (strong, nonatomic) IBOutlet UIView *cellView;
@property (strong, nonatomic) IBOutlet UIView *cellView1;
@property (strong, nonatomic) IBOutlet UISwitch *wifiSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *mobileNetworkSwitch;
@property (strong, nonatomic) IBOutlet UIButton *updateButton;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;

@end

@implementation SSFTModalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)init
{
    self = [super initWithNibName:@"SSFTModalViewController" bundle:nil];
    if (self != nil)
    {
        // Further initialization if needed
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.updateButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.updateButton.layer.borderWidth = 1.0f;
    self.doneButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.doneButton.layer.borderWidth = 1.0f;
    
    
    self.cellView.layer.borderColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0f].CGColor;
    self.cellView.layer.borderWidth = 1.0f;

    self.cellView1.layer.borderColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0f].CGColor;
    self.cellView1.layer.borderWidth = 1.0f;
    
    // Save network preferences
    self.wifiValue = [[NSUserDefaults standardUserDefaults]boolForKey:@"wifiValue"];
    self.mobileNetworkValue = [[NSUserDefaults standardUserDefaults]boolForKey:@"mobileNetworkValue"];
    self.wifiSwitch.on = self.wifiValue;
    self.mobileNetworkSwitch.on = self.mobileNetworkValue;
}

- (IBAction)mobileNetworkValueChanged:(id)sender
{
    self.mobileNetworkValue = self.mobileNetworkSwitch.on;
    NSLog(@"mobilenetwork value changed to : %d", self.mobileNetworkValue);
}

- (IBAction)wifiValueChanged:(id)sender
{
    self.wifiValue = self.wifiSwitch.on;
    NSLog(@"wifi value changed to : %d", self.wifiValue);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender
{
    [[NSUserDefaults standardUserDefaults]setBool:self.mobileNetworkValue forKey:@"mobileNetworkValue"];
    [[NSUserDefaults standardUserDefaults]setBool:self.wifiValue forKey:@"wifiValue"];
    
    //collect switch values
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)updateImages:(id)sender
{
    NSLog(@"Update images");
    [[NSUserDefaults standardUserDefaults]setBool:self.mobileNetworkValue forKey:@"mobileNetworkValue"];
    [[NSUserDefaults standardUserDefaults]setBool:self.wifiValue forKey:@"wifiValue"];
    [self.delegate regularUpdate];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
