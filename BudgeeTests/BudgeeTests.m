//
//  BudgeeTests.m
//  BudgeeTests
//
//  Created by Wes Gibbs on 10/17/13.
//  Copyright (c) 2013 Wes Gibbs. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <RestKit/RestKit.h>
#import <RestKit/Testing.h>

@interface BudgeeTests : XCTestCase

@end

@implementation BudgeeTests

- (void)setUp
{
  [super setUp];

  NSBundle *testTargetBundle = [NSBundle bundleWithIdentifier:@"com.majoritythird.BudgeeTests"];
  [RKTestFixture setFixtureBundle:testTargetBundle];
}

- (void)tearDown
{
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
}

- (RKObjectMapping *)userMapping
{
  RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[User class]];
  [userMapping addAttributeMappingsFromArray:@[@"email", @"id"]];

  return userMapping;
}

- (void)testMappingOfUser
{
	RKManagedObjectStore *managedObjectStore = [RKTestFactory managedObjectStore];
  NSDictionary *parsedJSON = (NSDictionary *)[RKTestFixture parsedObjectWithContentsOfFixture:@"user.json"];
  RKEntityMapping *entityMapping = [User mappingInManagedObjectStore:managedObjectStore];
  RKMappingTest *mappingTest = [RKMappingTest testForMapping:entityMapping sourceObject:parsedJSON[@"user"] destinationObject:nil];
  mappingTest.managedObjectContext = managedObjectStore.persistentStoreManagedObjectContext;

  NSManagedObject *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
	[user setValue:@("foo@foo.bar") forKey:@"email"];

	// Let the test perform the mapping
	[mappingTest performMapping];

	XCTAssertEqualObjects(user, mappingTest.destinationObject, @"Expected to match the Article, but did not");


//  RKMappingTest *test = [RKMappingTest testForMapping:[self userMapping] sourceObject:parsedJSON destinationObject:nil];
//	[test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"user.email" destinationKeyPath:@"email"]];
//	XCTAssertTrue([test evaluate], @"The email has not been set up!");
}

@end
