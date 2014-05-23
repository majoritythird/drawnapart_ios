//
//  CredentialManager.m
//  DrawnApart
//
//  Created by Wes Gibbs on 10/17/13.
//  Copyright (c) 2013 Majority Third. All rights reserved.
//

#import "CredentialManager.h"
#import "ApiClient.h"
#import "SSKeychain.h"

static CredentialManager *_sharedCredentialManager = nil;

static NSString *const kDrawnApartKeychainAccount = @"CurrentPerson";
static NSString *const kKeychainPasswordSeparator = @"__:BUG:__";

@implementation CredentialManager

#pragma mark - Class methods

+ (CredentialManager *)sharedInstance
{
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
    _sharedCredentialManager = [[CredentialManager alloc] init];
  });

  return _sharedCredentialManager;
}

#pragma mark - Methods

- (void)removeCurrentPerson
{
  NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
  [SSKeychain deletePasswordForService:bundleIdentifier account:kDrawnApartKeychainAccount];
  [ApiClient sharedApiClient].authenticationToken = nil;
  _currentPerson = nil;
}

- (BOOL)setCurrentPerson:(Person *)person withAuthenticationToken:(NSString *)authenticationToken
{
  NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
  NSString *personIdInfo = [@[person.id, authenticationToken] componentsJoinedByString:kKeychainPasswordSeparator];
  NSLog(@"personIdInfo: %@", personIdInfo);
  NSError *error = nil;
  [SSKeychain setPassword:personIdInfo forService:bundleIdentifier account:kDrawnApartKeychainAccount error:&error];

  if (error) {
    return NO;
  }
  else {
    _currentPerson = person;
    [ApiClient sharedApiClient].authenticationToken = authenticationToken;

    return YES;
  }
}

- (void)setCurrentPersonFromKeychainUsingContext:(NSManagedObjectContext *)context
{
  @synchronized(self) {
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *personIdInfo = [SSKeychain passwordForService:bundleIdentifier account:kDrawnApartKeychainAccount];

    if (personIdInfo) {
      NSArray *components = [personIdInfo componentsSeparatedByString:kKeychainPasswordSeparator];
      NSString *personId = components[0];
      NSString *authToken = components[1];

      _currentPerson = [Person findFirstWhereProperty:@"id" equals:personId inContext:context error:nil];

      if (_currentPerson != nil) {
        // set the authToken on the singleton instance of ApiClient
        [ApiClient sharedApiClient].authenticationToken = authToken;
      }
    }
  }
}

@end
