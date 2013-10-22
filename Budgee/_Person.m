// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Person.m instead.

#import "_Person.h"

const struct PersonAttributes PersonAttributes = {
	.balance = @"balance",
	.id = @"id",
	.name = @"name",
};

const struct PersonRelationships PersonRelationships = {
	.user = @"user",
};

const struct PersonFetchedProperties PersonFetchedProperties = {
};

@implementation PersonID
@end

@implementation _Person

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Person";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Person" inManagedObjectContext:moc_];
}

- (PersonID*)objectID {
	return (PersonID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"balanceValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"balance"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic balance;



- (int32_t)balanceValue {
	NSNumber *result = [self balance];
	return [result intValue];
}

- (void)setBalanceValue:(int32_t)value_ {
	[self setBalance:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveBalanceValue {
	NSNumber *result = [self primitiveBalance];
	return [result intValue];
}

- (void)setPrimitiveBalanceValue:(int32_t)value_ {
	[self setPrimitiveBalance:[NSNumber numberWithInt:value_]];
}





@dynamic id;






@dynamic name;






@dynamic user;

	






@end
