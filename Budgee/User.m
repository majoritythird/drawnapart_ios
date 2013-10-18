//
//  User.m
//  Budgee
//
//  Created by Wes Gibbs on 10/18/13.
//  Copyright (c) 2013 Wes Gibbs. All rights reserved.
//

#import "User.h"

@interface User ()

@end


@implementation User

#pragma mark - Class methods

+ (RKEntityMapping *)mappingInManagedObjectStore:(RKManagedObjectStore *)managedObjectStore
{
  RKEntityMapping *userMapping = [RKEntityMapping mappingForEntityForName:@"User" inManagedObjectStore:managedObjectStore];
  [userMapping addAttributeMappingsFromArray:@[@"email", @"id"]];
  userMapping.identificationAttributes = @[@"id"];

  return userMapping;
}

@end
