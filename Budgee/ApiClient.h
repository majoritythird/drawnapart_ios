//
//  ApiClient.h
//  Budgee
//
//  Created by Wes Gibbs on 10/18/13.
//  Copyright (c) 2013 Wes Gibbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignUp.h"

@interface ApiClient : NSObject

+ (ApiClient *)sharedApiClient;

- (id)init;
- (void)signUp:(SignUp *)signUp;

@end
