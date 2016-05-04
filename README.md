# InstagramSDK

[![CI Status](http://img.shields.io/travis/pisces/InstagramSDK.svg?style=flat)](https://travis-ci.org/pisces/InstagramSDK)
[![Version](https://img.shields.io/cocoapods/v/InstagramSDK.svg?style=flat)](http://cocoapods.org/pods/InstagramSDK)
[![License](https://img.shields.io/cocoapods/l/InstagramSDK.svg?style=flat)](http://cocoapods.org/pods/InstagramSDK)
[![Platform](https://img.shields.io/cocoapods/p/InstagramSDK.svg?style=flat)](http://cocoapods.org/pods/InstagramSDK)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

<img src="ScreenShot/sh_001.png" width="320"/>
<img src="ScreenShot/sh_002.png" width="320"/>

#### AppDelegate
```Objective-c
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
```
#### Example for API Call
```Objective-c
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([InstagramAppCenter defaultCenter].hasSession) {
        [self loadUserProfile];
    } else {
        [[InstagramAppCenter defaultCenter] loginWithCompletion:^(id result, NSError *error) {
            if (!error) {
                [self loadUserProfile];
            }
        }];
    }
}

- (void)loadUserProfile {
    [[InstagramAppCenter defaultCenter] apiCallWithPath:IGApiPathUsersSelf param:nil completion:^(id result, NSError *error) {
        NSLog(@"result, error -> %@, %@", result, error);
    }];
}
```

#### API Paths
```Objective-c
IGApiPathUsersSelf
IGApiPathUsersUserId
IGApiPathUsersSelfMediaRecent
IGApiPathUsersUserIdMediaRecent
IGApiPathUsersSelfMediaLiked
IGApiPathUsersSearch
IGApiPathUsersSelfFollows
IGApiPathUsersSelfFollowedBy
IGApiPathUsersSelfRequestedBy
IGApiPathUsersUserIdRelationship
IGApiPathUsersUserIdRelationshipPost
IGApiPathMediaMediaId
IGApiPathMediaShortcodeShortcode
IGApiPathMediaSearch
IGApiPathMediaMediaIdComments
IGApiPathMediaMediaIdCommentsPost
IGApiPathMediaMediaIdCommentsCommentId
IGApiPathMediaMediaIdLikes
IGApiPathMediaMediaIdLikesPost
IGApiPathMediaMediaIdLikesDel
IGApiPathTagsTagname
IGApiPathTagsTagnameMediaRecent
IGApiPathTagsSearch
IGApiPathLocationsLocationId
IGApiPathLocationsLocationIdMediaRecent
IGApiPathLocationsSearch
```

#### Parameter example for Path
You don't need include oauth2 property as parameter, it will add automatically in sdk.

```Objective-c
// Path contains 'user-id'
@{@"user-id": @(1574083)}

// Path contains 'media-id'
@{@"media-id": @(3)}

// Path contains 'shortcode'
@{@"shortcode": @(3)}

// Path contains 'tag-name'
@{@"tag-name": @"tagname"}

// Path contains 'location-id'
@{@"location-id": @(3)}

// Path IGApiPathUsersSearch or IGApiPathTagsSearch
@{@"q": @"query"}

// Path IGApiPathMediaSearch or IGApiPathLocationsSearch
@{@"lat": @(48.858844), @"lng": @(2.294351)};

```

## Requirements
iOS Deployment Target 7.0 higher

## Installation

InstagramSDK is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "InstagramSDK"
```

## Author

pisces, hh963103@gmail.com

## License

InstagramSDK is available under the MIT license. See the LICENSE file for more info.
