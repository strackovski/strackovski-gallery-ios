//
//  MainViewController.m
//  StrackovskiGallery
//
//  Created by Vladimir Stračkovski on 03/09/14.
//  Copyright (c) 2014 Vladimir Stračkovski. All rights reserved.
//

#import "MainViewController.h"
#import "PhotoViewController.h"
#import "ModalViewController.h"
#import "SSFTModalViewController.h"
//#import "Reachability.h"
#import "SSImageGetter.h"
#import "StartChildViewController.h"
#import "DataClass.h"

@interface MainViewController () {
    UIPageViewController *pageViewController;
    PhotoViewController *pageZero;
    UIPageViewController *tutorialPageViewController;
    UIPageControl *tutorialPageControl;
    DataClass *obj;
    int pageFlag;
}

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.view.backgroundColor = [UIColor whiteColor];
    obj = [DataClass getInstance];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:)
                                                 name:@"refreshView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPlaceholder:)
                                                 name:@"setPlaceholder" object:nil];

    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenTutorial"]) {
        NSLog(@"First time.");
        pageFlag = 1;
        self.wifiValue = YES;
        self.mobileNetworkValue = NO;
        
        // Set up Tutorial Screen
        tutorialPageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        
        tutorialPageViewController.dataSource = self;
        
        // Dots
        tutorialPageControl = [UIPageControl appearance];
        tutorialPageControl.pageIndicatorTintColor = [UIColor grayColor];
        tutorialPageControl.currentPageIndicatorTintColor = [UIColor blackColor];
        tutorialPageControl.backgroundColor = [UIColor whiteColor];
        
        [[tutorialPageViewController view] setFrame:[[self view] bounds]];
        StartChildViewController *initialViewController = [self viewControllerAtIndex:0];
        NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
        
        [tutorialPageViewController setViewControllers:viewControllers
                                            direction:UIPageViewControllerNavigationDirectionForward
                                            animated:NO
                                            completion:nil];
        
        [self addChildViewController:tutorialPageViewController];
        [[self view] addSubview:[tutorialPageViewController view]];
        [tutorialPageViewController didMoveToParentViewController:self];
    } else {
        pageFlag = 0;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *path = [documents stringByAppendingPathComponent:@"myList.plist"];
        if ([fileManager fileExistsAtPath:path]) {
            [self setUpPageControllerWithBlank:NO];
        } else {
            [self setUpPageControllerWithBlank:YES];
        }
    }
}

-(void)setUpPageControllerWithBlank:(BOOL)blank {
    NSLog(@"setUpPageController called");
    NSLog(@"PageFlag: %d", pageFlag);
    NSLog(@"Create pageController");
    
    if (blank) {
        NSLog(@"YES BLANK");
        pageZero = (PhotoViewController*)[[UIViewController alloc]init];
        //set a new view
        NSArray *nibContents = [[NSBundle mainBundle]
                                loadNibNamed:@"BlankView" owner:nil options:nil];
        UIView *blankView = [nibContents lastObject];
        blankView.frame = [self.view frame];
        pageZero.view = blankView;
        
        if (pageZero != nil) {
            pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:50.0f] forKey:UIPageViewControllerOptionInterPageSpacingKey]];
            
            pageViewController.dataSource = self;
            
            for (UIScrollView *view in pageViewController.view.subviews) {
                if ([view isKindOfClass:[UIScrollView class]]) {
                    view.scrollEnabled = NO;
                }
            }
            
            [pageViewController.view setBackgroundColor:[UIColor whiteColor]];
            [pageViewController setViewControllers:@[pageZero]
                                         direction:UIPageViewControllerNavigationDirectionForward
                                          animated:NO
                                        completion:NULL];
            [self.view addSubview:pageViewController.view];
            [self addButtons];
        }
    }
    else {
        NSLog(@"NOT BLANK");
        pageZero = [PhotoViewController photoViewControllerForPageIndex:0];
        if (pageZero != nil) {
            // Set up UIPageViewController (page scrolling)
            pageViewController = nil;
            pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:50.0f] forKey:UIPageViewControllerOptionInterPageSpacingKey]];
            pageViewController.dataSource = nil;
            pageViewController.dataSource = self;
            
            [pageViewController.view setBackgroundColor:[UIColor whiteColor]];
            [pageViewController setViewControllers:@[pageZero]
                                         direction:UIPageViewControllerNavigationDirectionForward
                                          animated:NO
                                        completion:NULL];
            pageViewController.dataSource = nil;
            pageViewController.dataSource = self;
            [self.view addSubview:pageViewController.view];
            [self addButtons];
        }
    }
}

-(void)addButtons {
    UIButton *subscribeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [subscribeButton setTitle:@"Subscribe" forState:UIControlStateNormal];
    [subscribeButton.titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:12]];
    subscribeButton.backgroundColor = [UIColor colorWithRed:55.0/255.0 green:55.0/255.0 blue:55.0/255.0 alpha:1.0];
    [subscribeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    subscribeButton.frame = CGRectMake(0, 518, 160, 50);
    [subscribeButton addTarget:self action:@selector(seeMore:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // Settings button
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [settingsButton setTitle:@"Settings" forState:UIControlStateNormal];
    settingsButton.backgroundColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
    settingsButton.frame = CGRectMake(160, 518, 160, 50);
    [settingsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [settingsButton.titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:12]];
    [settingsButton addTarget:self action:@selector(settingsMethod:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:subscribeButton];
    [self.view addSubview:settingsButton];
}

-(void)settingsMethod:(id)sender
{
    SSFTModalViewController *modal = [[SSFTModalViewController alloc]init];
    modal.delegate = self;
    [self presentViewController:modal animated:NO completion:nil];
    CGPoint modalCenter = modal.view.center;
    modalCenter.y += self.view.frame.size.height;
    modal.view.center = modalCenter;
    [UIView animateWithDuration:animationDuration animations:^{
        modal.view.center = self.view.center;
    } completion:^(BOOL finished) {
    }];
}

-(void)firstDownload
{
    pageFlag = 0;
    NSLog(@"First Download in progress");
    NSString *status = [obj checkConnection];

    if ([status isEqualToString:@"none"]) {
        [self setUpPageControllerWithBlank:YES];
    } else if ([status isEqualToString:@"wifi"]) {
        [[SSImageGetter sharedInstance]getImages];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Download via Mobile Network"
                              message:@"Images will be updated via Mobile Network. You wanna?"
                              delegate:self
                              cancelButtonTitle:@"Let's do this"
                              otherButtonTitles:@"Cancel", nil];
        [alert show];
    }
 }

-(void)regularUpdate
{
    NSString *status = [obj checkConnection];
    
    if (![status isEqualToString:@"none"]) {
        [[SSImageGetter sharedInstance]getImages];
    }
    
    for (UIScrollView *view in pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            view.scrollEnabled = YES;
        }
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [[SSImageGetter sharedInstance]getImages];
    } else {
        //if not first time, show gallery
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenTutorial"]) {
            NSLog(@"Some images are already present, so do nothing.");
        } else {
            NSLog(@"No images yet. Show placeholder image.");
            // else placeholder image (strackovski logo) with msg saying,
            // you can force dl of images in settings
            if(![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenTutorial"]) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenTutorial"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            [self setUpPageControllerWithBlank:YES];
        }
    }
}

-(void)refreshView:(id)sender
{
    pageZero = [PhotoViewController photoViewControllerForPageIndex:0];
    NSLog(@"refresh view");

    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenTutorial"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenTutorial"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"Refresh view, hasseentutorial???");
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *path = [documents stringByAppendingPathComponent:@"myList.plist"];
        if ([fileManager fileExistsAtPath:path]) {
            [self setUpPageControllerWithBlank:NO];
        } else {
            [self setUpPageControllerWithBlank:YES];
        }
    } else {
        NSLog(@"refresh view, hasnt seen?");
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *path = [documents stringByAppendingPathComponent:@"myList.plist"];

        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.strackovski.com/en/api/images?q=all"]];

        if ([fileManager fileExistsAtPath:path]) {
            [pageViewController setViewControllers:[NSArray arrayWithObject:[PhotoViewController photoViewControllerForPageIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
        } else {
            if (!data) {
                [self setUpPageControllerWithBlank:YES];
            } else {
                [self regularUpdate];
            }
        }
        [self.view setNeedsDisplay];
    }
}

-(void)setPlaceholder:(id)sender
{
    [self setUpPageControllerWithBlank:YES];
}

static CGFloat animationDuration = 0.25f;

-(void)seeMore:(id)sender
{
    ModalViewController *modal = [[ModalViewController alloc]init];
    [self presentViewController:modal animated:NO completion:nil];
    CGPoint modalCenter = modal.view.center;
    modalCenter.y += self.view.frame.size.height;
    modal.view.center = modalCenter;
    
    [UIView animateWithDuration:animationDuration animations:^{
        modal.view.center = self.view.center;
        //
    } completion:^(BOOL finished) {
        //
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark PageViewController methods

// Swipe left
- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerBeforeViewController:(PhotoViewController *)vc
{
    if(pageFlag == 1) {
        NSUInteger index = [(StartChildViewController *)vc index];
        if (index == 0) {
            return nil;
        }
        index--;
        return [self viewControllerAtIndex:index];
    }
    else {
        NSUInteger index = vc.pageIndex;
        return [PhotoViewController photoViewControllerForPageIndex:(index - 1)];
    }
}

// Swipe right
- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerAfterViewController:(UIViewController *)vc
{
    if (pageFlag == 1) {
        NSUInteger index = [(StartChildViewController *)vc index];
        index++;
        
        if (index == 2) {
            return nil;
        }
        
        return [self viewControllerAtIndex:index];

    } else {
        NSUInteger index = ((PhotoViewController*)vc).pageIndex;
        return [PhotoViewController photoViewControllerForPageIndex:(index + 1)];
    }
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    // The number of items reflected in the page indicator.
    return 2;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    // The selected item reflected in the page indicator.
    return 0;
}

- (StartChildViewController *)viewControllerAtIndex:(NSUInteger)index
{
    StartChildViewController *childViewController = [[StartChildViewController alloc]
                                                     initWithNibName:@"StartChildViewController" bundle:nil];
    childViewController.index = index;
    childViewController.wifiValue = self.wifiValue;
    childViewController.mobileNetworkValue = self.mobileNetworkValue;
    
    return childViewController;
}

@end
