//
//  SignUp.m
//  Budgee
//
//  Created by Wes Gibbs on 10/18/13.
//  Copyright (c) 2013 Wes Gibbs. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "SignUp.h"

@implementation SignUp

#pragma mark - Lifecycle

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
  NSDictionary *jsonDict = @{@"user" : @{@"email" : self.email, @"password" : self.password, @"person_attributes" : @{@"name" : self.name}}};
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
