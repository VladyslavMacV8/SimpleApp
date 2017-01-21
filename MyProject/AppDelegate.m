//
//  AppDelegate.m
//  MyProject
//
//  Created by Vladyslav Kudelia on 11.10.16.
//  Copyright © 2016 Vladyslav Kudelia. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebaseCore/FirebaseCore.h>
#import <FirebaseDatabase/FirebaseDatabase.h>

@interface AppDelegate ()

@property (strong, nonatomic) NSString *deviceID;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [FIRApp configure];
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    _deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    FIRUser *user = [[FIRAuth auth] currentUser];
    FIRDatabaseReference *myConnectionReference = [[FIRDatabase database] referenceWithPath:[NSString stringWithFormat:@"user_profile/%@/connections/%@", user.uid, _deviceID]];
    [[myConnectionReference child:@"online"] setValue:@false];
    [[myConnectionReference child:@"last_online"] setValue:[NSNumber numberWithDouble:[NSDate date].timeIntervalSince1970]];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
    [self manageConnections:[[FIRAuth auth] currentUser].uid];
}

- (void)applicationWillTerminate:(UIApplication *)application {}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:app openURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey] annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    return handled;
}

- (void)manageConnections:(NSString *)userID {
    FIRDatabaseReference *myConnectionReference = [[FIRDatabase database] referenceWithPath:[NSString stringWithFormat:@"user_profile/%@/connections/%@", userID, _deviceID]];
    [[myConnectionReference child:@"online"] setValue:@true];
    [[myConnectionReference child:@"last_online"] setValue:[NSNumber numberWithDouble:[NSDate date].timeIntervalSince1970]];
    
    [myConnectionReference observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        BOOL connected = snapshot.value;
        if (connected) {return;}
    }];
}

@end
