//
//  Build.m
//  DrawnApart
//
//  Created by Wes Gibbs on 4/18/14.
//
//

#import "Build.h"

#if APPSTORE
NSString *const kMTDrawnApartMixpanelToken = @"3bf7b3141e0c24a7cec33f4d186d9fa1";
#else
NSString *const kMTDrawnApartMixpanelToken = @"f3eacf5dce5f78f12cbe684d02078b43";
#endif

BOOL isAppStoreBuild()
{
#if APPSTORE
  return YES;
#else
  return NO;
#endif
}