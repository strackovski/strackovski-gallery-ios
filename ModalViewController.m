//
//  ModalViewController.m
//  Modal views
//  StrackovskiGallery
//
//  Created by Vladimir Stračkovski on 03/09/14.
//  Copyright (c) 2014 Vladimir Stračkovski. All rights reserved.
//

#import "ModalViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Reachability.h"
#import "DataClass.h"

@interface ModalViewController () {
    DataClass *obj;
}

@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIButton *pageLink;
@property (strong, nonatomic) IBOutlet UILabel *emailLabel;
@property (strong, nonatomic) IBOutlet UIButton *removeEmailButton;

@end

@implementation ModalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        obj = [DataClass getInstance];
    }
    return self;
}

-(id)init
{
    self = [super initWithNibName:@"ModalViewController" bundle:nil];
    if (self != nil) {
        // Further initialization if needed
    }
    return self;
}

- (void)viewDidLoad
{
    self.removeEmailButton.alpha = 0;
    [super viewDidLoad];
    self.pageLink.layer.borderColor = [UIColor whiteColor].CGColor;
    self.pageLink.layer.borderWidth = 1.0f;
    self.textField.delegate = self;
    //self.view.autoresizingMask = UIViewAutoresizingNone;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    if([[NSUserDefaults standardUserDefaults]valueForKey:@"userEmail"]){
        NSString *userEmail = [[NSUserDefaults standardUserDefaults]valueForKey:@"userEmail"];
        
        /*
         BOOL wifiIsOn = [[NSUserDefaults standardUserDefaults]boolForKey:@"wifiValue"];
         BOOL mobileNetworkIsOn = [[NSUserDefaults standardUserDefaults]boolForKey:@"mobileNetworkValue"];
         NetworkStatus status = [self checkConnection];
         */
        
        NSString *status = [obj checkConnection];
        if (![status isEqualToString:@"none"]) {
            [self checkExistingEmail];
        } else {
            self.emailLabel.text = [NSString stringWithFormat:@"Subscribed with %@", userEmail];
            self.removeEmailButton.alpha = 1;
        }
        
        /*
        if (wifiIsOn && (status == ReachableViaWiFi)) {
            [self checkExistingEmail];
        } else if (mobileNetworkIsOn && (status == ReachableViaWWAN)) {
            [self checkExistingEmail];
        } else {
            self.emailLabel.text = [NSString stringWithFormat:@"Subscribed with %@", userEmail];
            self.removeEmailButton.alpha = 1;
        }
         */
    }
}

- (IBAction)removeEmail:(id)sender
{
    /*
    BOOL wifiIsOn = [[NSUserDefaults standardUserDefaults]boolForKey:@"wifiValue"];
    BOOL mobileNetworkIsOn = [[NSUserDefaults standardUserDefaults]boolForKey:@"mobileNetworkValue"];
    NetworkStatus status = [self checkConnection];
    
    if (wifiIsOn && (status == ReachableViaWiFi)) {
        [self subscribeUser:YES];
    } else if (mobileNetworkIsOn && (status == ReachableViaWWAN)) {
        [self subscribeUser:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No internet connection"
                                                        message:@"Could not unsubscribe. Please try again."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    */
    
    NSString *status = [obj checkConnection];
    if (![status isEqualToString:@"none"]) {
        [self subscribeUser:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                            initWithTitle:@"No internet connection"
                            message:@"Could not unsubscribe. Please try again."
                            delegate:nil
                            cancelButtonTitle:@"OK"
                            otherButtonTitles:nil];
        [alert show];
    }
    
}

-(void)checkExistingEmail
{
    NSString *userEmail = [[NSUserDefaults standardUserDefaults]valueForKey:@"userEmail"];
    NSString *emailPath = [NSString stringWithFormat:@"http://nejoapps.eu/ssios/check_email.php?email=%@", userEmail];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:emailPath]];
    NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@" wifi email check, data: %@", newStr);
    
    if([newStr isEqualToString:@"1"]) {
        self.emailLabel.text = [NSString stringWithFormat:@"Subscribed with %@", userEmail];
        self.removeEmailButton.alpha = 1;
    } else {
        NSLog(@"the email doesnt exist");
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"userEmail"];
    }
   
}

-(void)dismissKeyboard
{
    [self.textField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)dismissIt:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    BOOL isValid = [self NSStringIsValidEmail:textField.text];
    
    if(isValid) {
        NSString *status = [obj checkConnection];
        if (![status isEqualToString:@"none"]) {
            [self subscribeUser:NO];
        } else {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"No internet connection"
                                  message:@"Could not subscribe. Please try again."
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }

        
        /*
        BOOL wifiIsOn = [[NSUserDefaults standardUserDefaults]boolForKey:@"wifiValue"];
        BOOL mobileNetworkIsOn = [[NSUserDefaults standardUserDefaults]boolForKey:@"mobileNetworkValue"];
        NetworkStatus status = [self checkConnection];

        if (wifiIsOn && (status == ReachableViaWiFi)) {
            NSLog(@"Email subscription via Wifi");
            [self subscribeUser:NO];
        } else if (mobileNetworkIsOn && (status == ReachableViaWWAN)) {
            [self subscribeUser:NO];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No internet connection"
                                                            message:@"Email could not be sent. No internet connection or your Settings do not allow the app to send data to the server. Please make sure Wifi or 3g is enabled and the app has access to it."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
         */
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                            initWithTitle:@"Invalid email address."
                            message:@"The value you entered is not a valid email address. Please ty again."
                            delegate:nil
                            cancelButtonTitle:@"OK"
                            otherButtonTitles:nil];
        [alert show];
    }
    return YES;
}

- (IBAction)goToPage:(id)sender
{
     [[UIApplication sharedApplication]
      openURL:[NSURL URLWithString:@"http://www.strackovski.com"]];
}

-(void)subscribeUser:(BOOL)remove
{
    if(remove == NO) {
        if([[NSUserDefaults standardUserDefaults]valueForKey:@"userEmail"]) {
            UIAlertView *alert = [[UIAlertView alloc]
                                initWithTitle:@"Already subscribed"
                                message:@"Please remove old email before subscribing with a new one."
                                delegate:nil
                                cancelButtonTitle:@"OK"
                                otherButtonTitles:nil];
            [alert show];
            
            return;
        }
    }
   
        
    NSString *textContent = self.textField.text;
    NSString *noteDataString = [NSString stringWithFormat:@"email=%@", textContent];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURL *url;
    
    if (remove == YES) {
        url = [NSURL URLWithString:@"http://www.strackovski.com/en/api/subscription?q=remove"];
    } else {
        url = [NSURL URLWithString:@"http://www.strackovski.com/en/api/subscription?q=add"];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPBody = [noteDataString dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(response == NULL || response == nil) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            } else {
                if(remove == NO) {
                    self.emailLabel.text = [NSString stringWithFormat:@"Subscribed with %@", self.textField.text];
                    [[NSUserDefaults standardUserDefaults]setValue:self.textField.text forKey:@"userEmail"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    self.textField.text = @"";
                    self.textField.placeholder = @"Enter email";
                    self.removeEmailButton.alpha = 1;
                    UIAlertView *alert = [[UIAlertView alloc]
                                        initWithTitle:@"Thank you!"
                                        message:@"You are now subscribed to my newsletter."
                                        delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
                    [alert show];
                } else {
                    self.emailLabel.text = [NSString stringWithFormat:@""];
                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"userEmail"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    self.textField.text = @"";
                    self.textField.placeholder = @"Enter email";
                    self.removeEmailButton.alpha = 0;
                    UIAlertView *alert = [[UIAlertView alloc]
                                        initWithTitle:@"You are unsubscribed!"
                                        message:@"You have successfully unsubscribed from this list."
                                        delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
                    [alert show];
                }
            }
        });
        
        NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"DATA: %@", newStr);
    }];
    [postDataTask resume];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.placeholder = nil;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

/*
-(NetworkStatus)checkConnection
{
    NetworkStatus wifiStatus = [[Reachability reachabilityForLocalWiFi] currentReachabilityStatus];
    NetworkStatus internetStatus = [[Reachability reachabilityForInternetConnection]currentReachabilityStatus];
    
    if(wifiStatus == ReachableViaWiFi) {
        return ReachableViaWiFi;
    } else if (wifiStatus != ReachableViaWiFi && internetStatus == ReachableViaWWAN) {
        return ReachableViaWWAN;
    } else {
        return NotReachable;
    }
}
*/

@end
