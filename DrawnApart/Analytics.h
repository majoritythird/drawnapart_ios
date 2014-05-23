//
//  Analytics.h
//  DrawnApart
//
//  Created by Wes Gibbs on 5/22/14.
//
//

@interface Analytics : NSObject

+ (Analytics *)sharedInstance;

- (void)trackAppActivated;
- (void)trackAppLaunched;

@end
