//
//  Analytics.m
//  DrawnApart
//
//  Created by Wes Gibbs on 5/22/14.
//
//

#import <Mixpanel/Mixpanel.h>
#import "Analytics.h"

// Events

NSString *const kEventAppActivated   = @"App Activated";
NSString *const kEventAppLaunched    = @"App Launched";

@implementation Analytics

static Analytics * _sharedInstance = nil;

#pragma mark - Class methods

+ (Analytics *)sharedInstance
{
  if (_sharedInstance == nil) {
    @synchronized(self)
    {
      if (_sharedInstance == nil) {
        _sharedInstance = [[Analytics alloc] init];
      }
    }
  }
  return _sharedInstance;
}

#pragma mark - Lifecycle

- (id)init
{
  self = [super init];

  if (self) {
    [Mixpanel sharedInstanceWithToken:kMTDrawnApartMixpanelToken];

    [[Mixpanel sharedInstance] registerSuperProperties:@{
      @"Version" : [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"]
    }];
  }

  return self;
}

#pragma mark - Methods

- (void)trackAppActivated
{
  [[Mixpanel sharedInstance] track:kEventAppActivated];
}

- (void)trackAppLaunched
{
  [[Mixpanel sharedInstance] track:kEventAppLaunched];
}

@end
