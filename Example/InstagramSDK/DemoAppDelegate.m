//
//  DemoAppDelegate.m
//  InstagramSDK
//
//  Created by pisces on 04/29/2016.
//  Copyright (c) 2016 pisces. All rights reserved.
//

#import "DemoAppDelegate.h"

NSString *const clientId = @"Your client id";
NSString *const clientSecret = @"Your client secret";
NSString *const redirectURL = @"Your redirect url";

@implementation DemoAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[InstagramAppCenter defaultCenter] setUpWithClientId:clientId
                                                     clientSecret:clientSecret
                                                      redirectURL:redirectURL];
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
