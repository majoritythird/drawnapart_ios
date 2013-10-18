//
//  Person.h
//  Budgee
//
//  Created by Wes Gibbs on 10/18/13.
//  Copyright (c) 2013 Wes Gibbs. All rights reserved.
//

#import "_Person.h"
#import <RestKit/RestKit.h>

@interface Person : _Person

+ (RKEntityMapping *)mappingInManagedObjectStore:(RKManagedObjectStore *)managedObjectStore;

@end
