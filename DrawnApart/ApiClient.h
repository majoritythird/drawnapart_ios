//
//  ApiClient.h
//  DrawnApart
//
//  Created by Wes Gibbs on 10/18/13.
//  Copyright (c) 2013 Wes Gibbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CredentialFormValueObject.h"

@interface ApiClient : NSObject

@property(nonatomic,strong) NSString *authenticationToken;

+ (ApiClient *)sharedApiClient;

- (id)init;

- (void)fetchPerson:(NSString *)personId success:(void(^)())successBlock;
- (void)signInOrUp:(NSString *)action credentialValueObject:(CredentialFormValueObject *)credentialValueObject;

@end
