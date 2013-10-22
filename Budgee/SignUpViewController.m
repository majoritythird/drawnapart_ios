//
//  SignUpViewController.m
//  Budgee
//
//  Created by Wes Gibbs on 10/18/13.
//  Copyright (c) 2013 Wes Gibbs. All rights reserved.
//

#import "SignUpViewController.h"
#import "ApiClient.h"
#import "SignInViewController.h"
#import "CredentialFormValueObject.h"

@interface SignUpViewController ()
<UITextFieldDelegate>

@property(nonatomic,weak) IBOutlet UITextField *emailTextField;
@property(nonatomic,weak) IBOutlet UITextField *nameTextField;
@property(nonatomic,weak) IBOutlet UITextField *passwordTextField;

@end

@implementation SignUpViewController

#pragma mark - Methods

- (IBAction)presentSignIn:(id)sender {
  SignInViewController *presentedViewController = [[SignInViewController alloc] initWithNibName:@"SignInViewController" bundle:nil];
  __weak typeof(self) weakSelf = self;
  presentedViewController.switchToSignUp = ^{
    [weakSelf dismissViewControllerAnimated:YES completion:nil];
  };
  [self presentViewController:presentedViewController animated:YES completion:nil];
}

- (IBAction)signUp:(id)sender {
  NSString *email = self.emailTextField.text;
  NSString *name = self.nameTextField.text;
  NSString *password = self.passwordTextField.text;

  CredentialFormValueObject *signUpValueObject = [[CredentialFormValueObject alloc] initWithEmail:email name:name password:password];

  [[ApiClient sharedApiClient] signInOrUp:@"sign_up" credentialValueObject:signUpValueObject];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  if (textField == self.nameTextField) {
    [self.emailTextField becomeFirstResponder];
  }
  else if (textField == self.emailTextField) {
    [self.passwordTextField becomeFirstResponder];
  }
  else {
    [self.passwordTextField resignFirstResponder];
    [self signUp:nil];
  }

  return YES;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


@end
