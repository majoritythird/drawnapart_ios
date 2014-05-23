//
//  ApiClient.m
//  DrawnApart
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

- (void)fetchPerson:(NSString *)personId success:(void(^)())successBlock
{
  NSURLRequest *request = [self personRequestForId:personId];
  NSArray *responseDescriptors = [self responseDescriptorsForPersonForPath:@"/api/people/:personId"];
  RKManagedObjectRequestOperation *operation = [[RKManagedObjectRequestOperation alloc] initWithRequest:request responseDescriptors:responseDescriptors];
  operation.managedObjectContext = self.context;
  operation.managedObjectCache = self.managedObjectStore.managedObjectCache;
  operation.savesToPersistentStore = NO;
  [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
    NSDictionary *resultDict = [result dictionary];
    User *user = resultDict[@"user"];
    Person *person = resultDict[@"person"];
    user.person = person;

    [self.context save:nil];

    NSLog(@"Mapped the user: %@", user);
    NSLog(@"Mapped the person: %@", person);

    successBlock();

  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    NSLog(@"Failed with error: %@", [error localizedDescription]);
  }];
  NSOperationQueue *operationQueue = [NSOperationQueue new];
  [operationQueue addOperation:operation];
}

- (NSURLRequest *)personRequestForId:(NSString *)personId
{
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:3000/api/people/%@", personId]];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];

  [request setHTTPMethod:@"GET"];
  [request setValue:@"application/vnd.drawnapart.v1+json" forHTTPHeaderField:@"Accept"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request setValue:[NSString stringWithFormat:@"Token token=\"%@\"", self.authenticationToken] forHTTPHeaderField:@"Authorization"];

  return request;
}

- (RKResponseDescriptor *)responseDescriptorForEntity:(NSString *)entityName forPath:(NSString *)pathPattern
{
  return [self responseDescriptorForEntity:entityName forPath:pathPattern forKey:[entityName lowercaseString]];
}

- (RKResponseDescriptor *)responseDescriptorForEntity:(NSString *)entityName forPath:(NSString *)pathPattern forKey:(NSString *)keyPath
{
  Class entityClass = NSClassFromString(entityName);
  NSAssert(entityClass, @"entityName \"%@\" must resolve to a class.", entityName);
  RKEntityMapping *responseMapping = [entityClass mappingInManagedObjectStore:self.managedObjectStore];
  NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);

  return [RKResponseDescriptor responseDescriptorWithMapping:responseMapping method:RKRequestMethodAny pathPattern:pathPattern keyPath:keyPath statusCodes:statusCodes];
}

- (NSArray *)responseDescriptorsForPersonForPath:(NSString *)pathPattern
{
  RKResponseDescriptor *personDescriptor = [self responseDescriptorForEntity:@"Person" forPath:pathPattern];
  RKResponseDescriptor *usersDescriptor = [self responseDescriptorForEntity:@"User" forPath:pathPattern forKey:@"users"];

  return @[personDescriptor, usersDescriptor];
}

- (NSArray *)responseDescriptorsForUserForPath:(NSString *)pathPattern
{
  RKResponseDescriptor *peopleDescriptor = [self responseDescriptorForEntity:@"Person" forPath:pathPattern forKey:@"people"];
  RKResponseDescriptor *userDescriptor = [self responseDescriptorForEntity:@"User" forPath:pathPattern];

  return @[userDescriptor, peopleDescriptor];
}

- (void)setCurrentPerson:(Person *)person withAuthenticationTokenFromOperation:(RKObjectRequestOperation *)operation
{
  NSString *authToken = [self authenticationTokenFromOperation:operation];
  [[CredentialManager sharedInstance] setCurrentPerson:person withAuthenticationToken:authToken];
}

- (void)signInOrUp:(NSString *)action credentialValueObject:(CredentialFormValueObject *)credentialValueObject
{
  NSURLRequest *request = [self signInOrUpRequestForURL:[NSString stringWithFormat:@"http://localhost:3000/api/%@", action] usingValues:credentialValueObject];
  NSArray *responseDescriptors = [self responseDescriptorsForUserForPath:[NSString stringWithFormat:@"/api/%@", action]];
  RKManagedObjectRequestOperation *operation = [[RKManagedObjectRequestOperation alloc] initWithRequest:request responseDescriptors:responseDescriptors];
  operation.managedObjectContext = self.context;
  operation.managedObjectCache = self.managedObjectStore.managedObjectCache;
  operation.savesToPersistentStore = NO;
  [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
    NSDictionary *resultDict = [result dictionary];
    User *user = resultDict[@"user"];
    Person *person = resultDict[@"people"][0];
    user.person = person;

    NSLog(@"Mapped the user: %@", user);
    NSLog(@"Mapped the person: %@", person);

    [self.context save:nil];

    [self setCurrentPerson:person withAuthenticationTokenFromOperation:operation];

    [self.appDelegate switchRootViewController:@"HomeViewController"];
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    NSLog(@"Failed with error: %@", [error localizedDescription]);
  }];
  NSOperationQueue *operationQueue = [NSOperationQueue new];
  [operationQueue addOperation:operation];
}

- (NSURLRequest *)signInOrUpRequestForURL:(NSString *)urlString usingValues:(CredentialFormValueObject *)valueObject
{
  NSURL *url = [NSURL URLWithString:urlString];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];

  NSString *json = [valueObject toJSON];
  NSData *requestData = [NSData dataWithBytes:[json UTF8String] length:[json length]];

  [request setHTTPMethod:@"POST"];
  [request setValue:@"application/vnd.drawnapart.v1+json" forHTTPHeaderField:@"Accept"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
  [request setHTTPBody: requestData];

  return request;
}

@end
