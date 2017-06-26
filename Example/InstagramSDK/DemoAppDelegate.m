//
//  DemoAppDelegate.m
//  InstagramSDK
//
//  Created by pisces on 04/29/2016.
//  Copyright (c) 2016 pisces. All rights reserved.
//

#import "DemoAppDelegate.h"

NSString *const clientId = @"44f7da449746424a87add98948d85bba";
NSString *const clientSecret = @"786fe9d225c248bc970aa251c6fd4771";
NSString *const redirectURL = @"redirectURL";
NSString *const appScheme = @"yourScheme";

@implementation DemoAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[InstagramAppCenter defaultCenter] setUpWithClientId:clientId
                                             clientSecret:clientSecret
                                              redirectURL:redirectURL
                                                appScheme:appScheme];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[InstagramAppCenter defaultCenter] matchedURL:url])
        return [[InstagramAppCenter defaultCenter] application:application
                                                               openURL:url
                                                     sourceApplication:sourceApplication
                                                            annotation:annotation];
    return YES;
}

@end
