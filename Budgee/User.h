//
//  User.h
//  Budgee
//
//  Created by Wes Gibbs on 10/18/13.
//  Copyright (c) 2013 Wes Gibbs. All rights reserved.
//

#import "_User.h"
#import <RestKit/RestKit.h>

@interface User : _User

+ (RKEntityMapping *)mappingInManagedObjectStore:(RKManagedObjectStore *)managedObjectStore;

@end
