//
//  SignInViewController.m
//  Budgee
//
//  Created by Wes Gibbs on 10/21/13.
//  Copyright (c) 2013 Wes Gibbs. All rights reserved.
//

#import "SignInViewController.h"
#import "AppDelegate.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Methods

- (IBAction)showSignUp:(id)sender {
  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  [appDelegate switchRootViewController:@"SignUpViewController"];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

@end
