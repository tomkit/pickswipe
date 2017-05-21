//
//  AppDelegate.m
//  helloworld
//
//  Created by Thomas Chen on 2/17/13.
//  Copyright (c) 2013 Thomas Chen. All rights reserved.
//

#import "AppDelegate.h"
#import "ShareViewController.h"
#import "ViewController.h"
#import "Constants.h"


NSString *const SessionStateChangedNotification =
@"com.tomkit.pickswipe:SessionStateChangedNotification";

NSString *const OwnUserStateChangeNotification =
@"com.tomkit.pickswipe:OwnUserStateChangeNotification";

NSString *const OpenSessionNotification =
@"com.tomkit.pickswipe:OpenSessionNotification";

NSString *const TryGetSessionNotification =
@"com.tomkit.pickswipe:TryGetSessionNotification";

@implementation AppDelegate
UINavigationController *navController;
NSDictionary<FBGraphUser> *ownUser;
//NSString *ownId;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [FBProfilePictureView class];
    
    
    
    // Override point for customization after application launch.
    navController = (UINavigationController *)self.window.rootViewController;
    ViewController *viewController = [navController.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    ShareViewController *shareViewController = [navController.storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
    
//    [FBSession openActiveSessionWithReadPermissions:nil
//                                       allowLoginUI:YES
//                                  completionHandler:
//     ^(FBSession *session,
//       FBSessionState state, NSError *error) {
//
//     }];
    
//    [shareViewController initWithNibName:nil bundle:nil];
    
//    navController.viewControllers = [NSArray arrayWithObjects:shareViewController, viewController, nil];
    
//    [FBSession.activeSession closeAndClearTokenInformation];
    
//    [[NSNotificationCenter defaultCenter]
//     postNotificationName:OpenSessionNotification
//     object:nil];
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    return YES;
}

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

-(UINavigationController *)getNavController {
    return navController;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"handled FB callback");
    return [FBSession.activeSession handleOpenURL:url];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    int appIconBadge = application.applicationIconBadgeNumber;
    if(appIconBadge > 0) {
        application.applicationIconBadgeNumber = 0;
    }
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // We need to properly handle activation of the application with regards to Facebook Login
    // (e.g., returning from iOS 6.0 Login Dialog or from fast app switching).
    [FBSession.activeSession handleDidBecomeActive];
    
        ViewController *viewController = [navController.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    [viewController tryGetSession];
    [viewController keepSwiping];
//    [viewController getNext];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)setOwnUser:(NSDictionary<FBGraphUser>*)oUser {
    ownUser = oUser;
}

-(NSDictionary<FBGraphUser>*)getOwnUser {
    return ownUser;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
    
    if(ownUser) {
        // Convert to string
        NSString *deviceTokenString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSMutableString *postURL = [[NSMutableString alloc] init];
        [postURL appendString:@"http://"];
        [postURL appendString:SITE_DOMAIN];
        [postURL appendString:@"/ritelike/funny/regnotif"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:postURL] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
        NSDictionary *initialLogAsJSON = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:ownUser.id, deviceTokenString, nil] forKeys:[NSArray arrayWithObjects:@"u_id", @"device_id", nil]];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:initialLogAsJSON options:NSJSONWritingPrettyPrinted error:&error];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%d", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody: jsonData];
        
        // Asynchronous
        [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if(error) {
                                   } else {
                                       NSLog(@"post deviceid success");
                                   }
                               }];
    }
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

@end
