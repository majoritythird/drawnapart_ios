//
//  CredentialManager.h
//  Budgee
//
//  Created by Wes Gibbs on 10/17/13.
//  Copyright (c) 2013 Majority Third. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

@interface CredentialManager : NSObject

+ (Person *)currentPersonUsingContext:(NSManagedObjectContext *)context;

@property(nonatomic,readonly) NSString *authToken;
@property(nonatomic,readonly) NSString *email;
@property(nonatomic,readonly) BOOL isValid;
@property(nonatomic,readonly) NSString *personId;

@end
