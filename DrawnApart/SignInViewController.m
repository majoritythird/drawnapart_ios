//
//  SignInViewController.m
//  DrawnApart
//
//  Created by Wes Gibbs on 10/21/13.
//  Copyright (c) 2013 Wes Gibbs. All rights reserved.
//

#import "SignInViewController.h"
#import "ApiClient.h"
#import "CredentialFormValueObject.h"

@interface SignInViewController ()
<UITextFieldDelegate>

@property(nonatomic,weak) IBOutlet UITextField *emailTextField;
@property(nonatomic,weak) IBOutlet UITextField *passwordTextField;

@end

@implementation SignInViewController

#pragma mark - Methods

- (IBAction)showSignUp:(id)sender {
  self.switchToSignUp();
}

- (IBAction)signIn:(id)sender {
  NSString *email = self.emailTextField.text;
  NSString *password = self.passwordTextField.text;

  CredentialFormValueObject *signInValueObject = [[CredentialFormValueObject alloc] initWithEmail:email password:password];

  [[ApiClient sharedApiClient] signInOrUp:@"sign_in" credentialValueObject:signInValueObject];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  if (textField == self.emailTextField) {
    [self.passwordTextField becomeFirstResponder];
  }
  else {
    [self.passwordTextField resignFirstResponder];
    [self signIn:nil];
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
