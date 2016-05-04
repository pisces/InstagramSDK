# w3action

w3action is library helps you can develop the application using http connection easily and fastly.

[![CI Status](http://img.shields.io/travis/pisces/w3action.svg?style=flat)](https://travis-ci.org/pisces/w3action)
[![Version](https://img.shields.io/cocoapods/v/w3action.svg?style=flat)](http://cocoapods.org/pods/w3action)
[![License](https://img.shields.io/cocoapods/l/w3action.svg?style=flat)](http://cocoapods.org/pods/w3action)
[![Platform](https://img.shields.io/cocoapods/p/w3action.svg?style=flat)](http://cocoapods.org/pods/w3action)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

#### AppDelegate
```objective-c
#import "AppDelegate.h"
#import <w3action/w3action.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Add plist file for configuration
    [[HTTPActionManager sharedInstance] addResourceWithBundle:[NSBundle mainBundle] plistName:@"action"];
    
    return YES;
}

@end
```

#### Data Type JSON
```objective-c
[[HTTPActionManager sharedInstance] doAction:@"example-datatype-json" 
	param:nil body:nil headers:nil success:^(NSDictionary *result){
	NSLog(@"JSON result -> %@", result);
} error:^(NSError *error){
	NSLog(@"error -> %@", error);
}];
```

#### Data Type XML
```objective-c
[[HTTPActionManager sharedInstance] doAction:@"example-datatype-xml" 
	param:nil body:nil headers:nil success:^(APDocument *result){
	NSLog(@"XML result -> %@", result);
} error:^(NSError *error){
	NSLog(@"error -> %@", error);
}];
```

#### Data Type Text
```objective-c
[[HTTPActionManager sharedInstance] doAction:@"example-datatype-text" 
	param:nil body:nil headers:nil success:^(NSString *result){
	NSLog(@"Text result -> %@", result);
} error:^(NSError *error){
	NSLog(@"error -> %@", error);
}];
```

#### Multipart Form Data
```objective-c
UIImage *image = [[UIImage alloc] init];
NSData *imageData = UIImagePNGRepresentation(image);
MultipartFormDataObject *object = [MultipartFormDataObject objectWithFilename:@"sample.png" data:imageData];
    
[[HTTPActionManager sharedInstance] doAction:@"example-contenttype-multipart" 
	param:nil body:object headers:nil success:^(NSString *result){
	NSLog(@"JSON result -> %@", result);
} error:^(NSError *error){
	NSLog(@"error -> %@", error);
}];
```

#### URL Path Parameters
```objective-c
NSDictionary *param = @{@"resourceFolderName": @"resources"};
    
[[HTTPActionManager sharedInstance] doAction:@"example-datatype-text" 
	param:nil body:object headers:nil success:^(NSString *result){
	NSLog(@"JSON result -> %@", result);
} error:^(NSError *error){
	NSLog(@"error -> %@", error);
}];
```

#### Use directly not use config file
```objective-c
NSDictionary *action = [NSMutableDictionary dictionary];
[action setValue:@"url" forKey:@"https://raw.github.com/pisces/w3action/master/w3action-master/resources/example.json"
[action setValue:@"method" forKey:HTTP_METHOD_POST];
[action setValue:@"contentType" forKey:ContentTypeApplicationJSON];
[action setValue:@"dataType" forKey:DataTypeJSON];
[action setValue:@"timeout" forKey:@"10"];
    
HTTPRequestObject *object = [[HTTPRequestObject alloc] init];
object.action = action;
object.param = @{@"p1": @"easy", @"p2": @"simple"};
    
[[HTTPActionManager sharedInstance] doActionWithRequestObject:object success:^(NSDictionary *result){
	NSLog(@"JSON result -> %@", result);
} error:^(NSError *error){
	NSLog(@"error -> %@", error);
}];
```

#### plist file for configuration
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Actions</key>
	<dict>
		<key>example-datatype-json</key>
		<dict>
			<key>url</key>
			<string>https://raw.github.com/pisces/w3action/master/w3action-master/resources/example.json</string>
			<key>method</key>
			<string>GET</string>
			<key>contentType</key>
			<string>application/x-www-form-urlencoded</string>
			<key>dataType</key>
			<string>json</string>
			<key>timeout</key>
			<string>10</string>
			<key>async</key>
			<false/>
		</dict>
		<key>example-datatype-xml</key>
		<dict>
			<key>url</key>
			<string>https://raw.github.com/pisces/w3action/master/w3action-master/resources/example.xml</string>
			<key>method</key>
			<string>GET</string>
			<key>contentType</key>
			<string>application/x-www-form-urlencoded</string>
			<key>dataType</key>
			<string>xml</string>
			<key>timeout</key>
			<string>10</string>
			<key>async</key>
			<false/>
		</dict>
		<key>example-datatype-text</key>
		<dict>
			<key>url</key>
			<string>https://raw.github.com/pisces/w3action/master/w3action-master/resources/example.text</string>
			<key>method</key>
			<string>GET</string>
			<key>contentType</key>
			<string>application/x-www-form-urlencoded</string>
			<key>dataType</key>
			<string>text</string>
			<key>timeout</key>
			<string>10</string>
			<key>async</key>
			<false/>
		</dict>
		<key>example-contenttype-multipart</key>
		<dict>
			<key>url</key>
			<string>https://raw.github.com/pisces/w3action/master/w3action-master/resources/example-multipart.json</string>
			<key>method</key>
			<string>GET</string>
			<key>contentType</key>
			<string>multipart/form-data</string>
			<key>dataType</key>
			<string>json</string>
			<key>timeout</key>
			<string>10</string>
			<key>async</key>
			<false/>
		</dict>
		<key>example-path-param</key>
		<dict>
			<key>url</key>
			<string>https://raw.github.com/pisces/w3action/master/w3action-master/{resourceFolderName}/example.json</string>
			<key>method</key>
			<string>GET</string>
			<key>contentType</key>
			<string>application/x-www-form-urlencoded</string>
			<key>dataType</key>
			<string>json</string>
			<key>timeout</key>
			<string>10</string>
			<key>async</key>
			<false/>
		</dict>
	</dict>
</dict>
</plist>
```

## Requirements
iOS Development Target 7.0 higher

## Installation

w3action is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "w3action"
```
Create *.plist file for configuration in your project root

## Author

pisces, hh963103@gmail.com

## License

w3action is available under the MIT license. See the LICENSE file for more info.
