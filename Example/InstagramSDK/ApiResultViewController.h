//
//  ApiResultViewController.h
//  InstagramSDK
//
//  Created by pisces on 5/3/16.
//  Copyright © 2016 pisces. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApiResultViewController : UIViewController
@property (nonatomic, strong) NSString *path;
- (id)initWithPath:(NSString *)path;
@end
