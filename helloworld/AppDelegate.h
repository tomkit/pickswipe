//
//  AppDelegate.h
//  helloworld
//
//  Created by Thomas Chen on 2/17/13.
//  Copyright (c) 2013 Thomas Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

extern NSString *const SessionStateChangedNotification;
extern NSString *const OwnUserStateChangeNotification;
extern NSString *const OpenSessionNotification;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
-(UINavigationController *)getNavController;
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
@end
