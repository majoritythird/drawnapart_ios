//
//  SignUp.h
//  Budgee
//
//  Created by Wes Gibbs on 10/18/13.
//  Copyright (c) 2013 Wes Gibbs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SignUp : NSObject

@property(nonatomic,strong) NSString *email;
@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *password;

- (id)initWithEmail:(NSString *)email name:(NSString *)name password:(NSString *)password;
- (NSString *)toJSON;

@end
