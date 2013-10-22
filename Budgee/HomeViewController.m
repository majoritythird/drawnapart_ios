//
//  HomeViewController.m
//  Budgee
//
//  Created by Wes Gibbs on 10/19/13.
//  Copyright (c) 2013 Wes Gibbs. All rights reserved.
//

#import "HomeViewController.h"
#import "ApiClient.h"
#import "AppDelegate.h"
#import "CredentialManager.h"

@interface HomeViewController ()

@property(nonatomic,strong) IBOutlet UILabel *balanceLabel;

@end

@implementation HomeViewController

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

- (IBAction)refreshBalance:(id)sender {
  NSString *personId = [[CredentialManager sharedInstance] currentPerson].id;
  [[ApiClient sharedApiClient] fetchPerson:personId success:^{
    [self updateBalanceLabel];
  }];
}

- (IBAction)signOut:(id)sender {
  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  [appDelegate signOut];
}

- (void)updateBalanceLabel
{
  NSNumber *balance = [[CredentialManager sharedInstance] currentPerson].balance;
  self.balanceLabel.text = [balance stringValue];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self updateBalanceLabel];
}

@end
