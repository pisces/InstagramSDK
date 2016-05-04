//
//  InstagramLoginViewController.h
//  InstagramSDK
//
//  Created by pisces on 2015. 5. 2..
//  Copyright (c) 2015년 orcllercorp. All rights reserved.
//

#import <w3action/w3action.h>
#import "OAuth2Model.h"

@protocol InstagramLoginViewControllerDelegate;

@interface InstagramLoginViewController : UIViewController <UIWebViewDelegate>
@property (nonatomic, strong) OAuth2Model *model;
@property (nonatomic, weak) id<InstagramLoginViewControllerDelegate> delegate;
- (instancetype)initWithModel:(OAuth2Model *)model;
- (void)dismiss;
- (void)present;
@end

@protocol InstagramLoginViewControllerDelegate <NSObject>
- (void)didDismissViewController;
@end