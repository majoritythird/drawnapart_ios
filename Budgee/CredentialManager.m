//
//  CredentialManager.m
//  Budgee
//
//  Created by Wes Gibbs on 10/17/13.
//  Copyright (c) 2013 Majority Third. All rights reserved.
//

#import "CredentialManager.h"
#import "SSKeychain.h"

static Person *_currentPerson = nil;
static NSString *const kBudgeeKeychainAccount = @"CurrentPerson";
static NSString *const kKeychainPasswordSeparator = @"__:BUG:__";

@implementation CredentialManager

#pragma mark - Class methods

+ (Person *)currentPersonUsingContext:(NSManagedObjectContext *)context
{
  if (_currentPerson == nil) {
    @synchronized(self)
    {
      if (_currentPerson == nil) {
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *personIdInfo = [SSKeychain passwordForService:bundleIdentifier account:kBudgeeKeychainAccount];

        if (personIdInfo) {
          NSArray *components = [personIdInfo componentsSeparatedByString:kKeychainPasswordSeparator];
          NSString *personId = components[0];
//          NSString *authToken = components[1];

          _currentPerson = [Person findFirstWhereProperty:@"id" equals:personId inContext:context error:nil];

          if (_currentPerson == nil) {
            return nil;
          }

          // set the authToken on the singleton instance of some Client object for the network requests
        }
        else {
          return nil;
        }
      }
    }
  }

  return _currentPerson;
}

@end
