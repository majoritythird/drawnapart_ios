//
//  ApiClient.m
//  Budgee
//
//  Created by Wes Gibbs on 10/18/13.
//  Copyright (c) 2013 Wes Gibbs. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "ApiClient.h"
#import "AppDelegate.h"
#import "CredentialManager.h"

static ApiClient *_sharedApiClient = nil;

@interface ApiClient()

@property(nonatomic,strong) AppDelegate *appDelegate;
@property(nonatomic,strong) NSManagedObjectContext *context;
@property(nonatomic,strong) RKManagedObjectStore *managedObjectStore;

@end

@implementation ApiClient

#pragma mark - Class methods

+ (ApiClient *)sharedApiClient
{
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
    _sharedApiClient = [[ApiClient alloc] init];
  });

  return _sharedApiClient;
}

#pragma mark - Lifecycle

- (id)init {

  self = [super init];


  if (self) {
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _context = [_appDelegate managedObjectContext];
    _managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:[_appDelegate managedObjectModel]];
  }

  return self;
}

#pragma mark - Methods

- (NSString *)authenticationTokenFromOperation:(RKObjectRequestOperation *)operation
{
  NSString *jsonString = operation.HTTPRequestOperation.responseString;
  NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];

  return jsonDict[@"user"][@"authentication_token"];
}

- (void)setCurrentPerson:(Person *)person withAuthenticationTokenFromOperation:(RKObjectRequestOperation *)operation
{
  NSString *authToken = [self authenticationTokenFromOperation:operation];
  [CredentialManager setCurrentPerson:person withAuthenticationToken:authToken];
}

- (void)signUp:(SignUp *)signUp
{
  NSURLRequest *request = [self signUpRequest:signUp];
  RKResponseDescriptor *personResponseDescriptor = [self signUpResponseDescriptorForPerson];
  RKResponseDescriptor *userResponseDescriptor = [self signUpResponseDescriptorForUser];
  RKManagedObjectRequestOperation *operation = [[RKManagedObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[userResponseDescriptor, personResponseDescriptor]];
  operation.managedObjectContext = self.context;
  operation.managedObjectCache = self.managedObjectStore.managedObjectCache;
  operation.savesToPersistentStore = NO;
  [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
    NSDictionary *resultDict = [result dictionary];
    User *user = resultDict[@"user"];
    Person *person = resultDict[@"person"];
    user.person = person;
    [self.context save:nil];

    [self setCurrentPerson:person withAuthenticationTokenFromOperation:operation];

    NSLog(@"Mapped the user: %@", user);
    NSLog(@"Mapped the person: %@", person);

    [self.appDelegate switchRootViewController:@"HomeViewController"];
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    NSLog(@"Failed with error: %@", [error localizedDescription]);
  }];
  NSOperationQueue *operationQueue = [NSOperationQueue new];
  [operationQueue addOperation:operation];
}

- (NSURLRequest *)signUpRequest:(SignUp *)signUp
{
  NSURL *url = [NSURL URLWithString:@"http://localhost:3000/api/sign_up"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];

  NSString *signUpJSON = [signUp toJSON];
  NSData *requestData = [NSData dataWithBytes:[signUpJSON UTF8String] length:[signUpJSON length]];

  [request setHTTPMethod:@"POST"];
  [request setValue:@"application/vnd.budgee.v1+json" forHTTPHeaderField:@"Accept"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
  [request setHTTPBody: requestData];

  return request;
}

- (RKResponseDescriptor *)signUpResponseDescriptorForPerson
{
  RKEntityMapping *responseMapping = [Person mappingInManagedObjectStore:self.managedObjectStore];
  NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);

  return [RKResponseDescriptor responseDescriptorWithMapping:responseMapping method:RKRequestMethodAny pathPattern:@"/api/sign_up" keyPath:@"person" statusCodes:statusCodes];
}

- (RKResponseDescriptor *)signUpResponseDescriptorForUser
{
  RKEntityMapping *responseMapping = [User mappingInManagedObjectStore:self.managedObjectStore];
  NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);

  return [RKResponseDescriptor responseDescriptorWithMapping:responseMapping method:RKRequestMethodAny pathPattern:@"/api/sign_up" keyPath:@"user" statusCodes:statusCodes];
}

@end

//TODO get base url dynamically based on dev or appstore or whatever
//TODO think about what context should be used for updating inserting objects as a result of processing api response

//  RKObjectMapping *requestMapping = [SignUp mapping];
//  RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[SignUp class] rootKeyPath:@"user" method:RKRequestMethodAny];



//  RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
//  manager.managedObjectStore = self.managedObjectStore;
//  manager.requestSerializationMIMEType = RKMIMETypeJSON;
//  [manager setAcceptHeaderWithMIMEType:@"application/vnd.budgee.v1+json"];
//  [manager addRequestDescriptor:requestDescriptor];
//  [manager addResponseDescriptor:responseDescriptor];
//
//  [manager postObject:signUp path:@"/api/sign_up" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//    NSLog(@"Success:");
//  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//    NSLog(@"Failure:");
//  }];
