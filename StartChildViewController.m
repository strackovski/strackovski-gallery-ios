//
//  StartChildViewController.m
//  StrackovskiGallery
//
//  Created by Vladimir Stračkovski on 06/09/14.
//  Copyright (c) 2014 Vladimir Stračkovski. All rights reserved.
//

#import "StartChildViewController.h"
#import "MainViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface StartChildViewController ()
@property (strong, nonatomic) IBOutlet UIView *firstView;
@property (strong, nonatomic) IBOutlet UIView *secondView;

@property (strong, nonatomic) IBOutlet UIView *cellView1;
@property (strong, nonatomic) IBOutlet UIView *cellView2;
@property (strong, nonatomic) IBOutlet UISwitch *mobileNetworkSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *wifiSwitch;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;

@end

@implementation StartChildViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)mobileNetworkValueChanged:(UISwitch *)sender
{
    self.mobileNetworkValue = sender.on;
    NSLog(@"Mobile network value changed to: %d", self.mobileNetworkValue);
}

- (IBAction)wifiValueChanged:(UISwitch *)sender
{
    self.wifiValue = sender.on;
        NSLog(@"Wifi value changed to: %d", self.wifiValue);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.doneButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.doneButton.layer.borderWidth = 1.0f;
    // Do any additional setup after loading the view from its nib.
    self.wifiSwitch.on = self.wifiValue;
    self.mobileNetworkSwitch.on = self.mobileNetworkValue;
    
    if (self.index == 0) {
        self.firstView.alpha = 1;
        self.secondView.alpha = 0;
    } else if (self.index == 1) {
        self.firstView.alpha = 0;
        self.secondView.alpha = 1;
        self.view.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0f];
    }
    
    self.cellView1.layer.borderColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0f].CGColor;
    self.cellView1.layer.borderWidth = 1.0f;
    self.cellView2.layer.borderColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0f].CGColor;
    self.cellView2.layer.borderWidth = 1.0f;
}

- (IBAction)imDone:(id)sender
{
    UIViewController *vc = [self parentViewController];
    MainViewController *main = (MainViewController*)[vc parentViewController];
    //[[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"hasSeenTutorial"];
    [[NSUserDefaults standardUserDefaults] setBool:self.wifiValue forKey:@"wifiValue"];
    [[NSUserDefaults standardUserDefaults] setBool:self.mobileNetworkValue forKey:@"mobileNetworkValue"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];

    [vc willMoveToParentViewController:nil];
    [vc.view removeFromSuperview];
    [vc removeFromParentViewController];
    [main firstDownload];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
