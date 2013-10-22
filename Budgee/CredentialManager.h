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

@property(nonatomic,readonly) NSString *authToken;
@property(nonatomic,strong) Person *currentPerson;
@property(nonatomic,readonly) NSString *email;
@property(nonatomic,readonly) BOOL isValid;
@property(nonatomic,readonly) NSString *personId;

+ (CredentialManager *)sharedInstance;

- (Person *)currentPersonUsingContext:(NSManagedObjectContext *)context;
- (void)removeCurrentPerson;
- (BOOL)setCurrentPerson:(Person *)person withAuthenticationToken:(NSString *)authenticationToken;

@end
