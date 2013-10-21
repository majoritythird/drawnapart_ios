//
//  CredentialFormValueObject.m
//  Budgee
//
//  Created by Wes Gibbs on 10/18/13.
//  Copyright (c) 2013 Wes Gibbs. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "CredentialFormValueObject.h"

@implementation CredentialFormValueObject

#pragma mark - Lifecycle

- (id)initWithEmail:(NSString *)email password:(NSString *)password
{
  self = [super init];

  if (self) {
    _email = email;
    _password = password;
  }

  return self;
}

- (id)initWithEmail:(NSString *)email name:(NSString *)name password:(NSString *)password
{
  self = [super init];

  if (self) {
    _email = email;
    _name = name;
    _password = password;
  }

  return self;
}

- (NSString *)toJSON
{
  NSMutableDictionary *nestedDict = [NSMutableDictionary dictionaryWithObjectsAndKeys: self.email, @"email", self.password, @"password", nil];
  if (self.name) {
    NSDictionary *nameDict = @{@"name" : self.name};
    [nestedDict setObject:nameDict forKey:@"person_attributes"];
  }
  NSDictionary *jsonDict = [NSDictionary dictionaryWithObject:nestedDict forKey:@"user"];
  NSData *data = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:nil];
  return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end

//#pragma mark - Methods
//
//+ (RKObjectMapping *)mapping
//{
//  RKObjectMapping *signUpMapping = [RKObjectMapping requestMapping];
//  [signUpMapping addAttributeMappingsFromArray:@[@"email", @"password"]];
//  [signUpMapping addAttributeMappingsFromDictionary:@{
//    @"name":   @"person_attributes.name"
//  }];
//
//  return signUpMapping;
//}
//
