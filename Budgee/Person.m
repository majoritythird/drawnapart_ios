//
//  Person.m
//  Budgee
//
//  Created by Wes Gibbs on 10/18/13.
//  Copyright (c) 2013 Wes Gibbs. All rights reserved.
//

#import "Person.h"

@interface Person ()

@end

@implementation Person

#pragma mark - Class methods

+ (RKEntityMapping *)mappingInManagedObjectStore:(RKManagedObjectStore *)managedObjectStore
{
  //  RKEntityMapping *personMapping = [Person mappingInManagedObjectStore:managedObjectStore];
  RKEntityMapping *personMapping = [RKEntityMapping mappingForEntityForName:@"Person" inManagedObjectStore:managedObjectStore];
  [personMapping addAttributeMappingsFromArray:@[@"id", @"name"]];
  //  [userMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"person" toKeyPath:@"person" withMapping:personMapping]];
  personMapping.identificationAttributes = @[@"id"];

  return personMapping;
}

@end
