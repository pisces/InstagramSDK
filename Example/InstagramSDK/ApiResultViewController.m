//
//  ApiResultViewController.m
//  InstagramSDK
//
//  Created by pisces on 5/3/16.
//  Copyright © 2016 pisces. All rights reserved.
//

#import "ApiResultViewController.h"
#import <InstagramSDK-iOS/InstagramSDK.h>

@interface ApiResultViewController ()
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@end

@implementation ApiResultViewController
{
    BOOL pathChanged;
}

// ================================================================================================
//  Overridden: UIViewController
// ================================================================================================

#pragma mark - Overridden: UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self invalidatePathChanging];
}

// ================================================================================================
//  Public
// ================================================================================================

#pragma mark - Public getter/setter

- (void)setPath:(NSString *)path {
    if ([path isEqualToString:_path])
        return;
    
    _path = path;
    pathChanged = YES;
    
    [self invalidatePathChanging];
}

#pragma mark - Public methods

- (id)initWithPath:(NSString *)path {
    self = [super initWithNibName:@"ApiResultView" bundle:[NSBundle mainBundle]];
    
    if (self) {
        self.path = path;
    }
    
    return self;
}

// ================================================================================================
//  Private
// ================================================================================================

#pragma mark - Private methods

- (void)invalidatePathChanging {
    if (!self.isViewLoaded)
        return;
    
    if (pathChanged) {
        pathChanged = NO;
        self.title = [NSString stringWithFormat:@"path: %@", _path];
        _activityIndicatorView.hidden = NO;
        
        [_activityIndicatorView startAnimating];
        [[InstagramAppCenter defaultCenter] apiCallWithPath:_path param:self.param completion:^(id result, NSError *error) {
            [_activityIndicatorView stopAnimating];
            
            _activityIndicatorView.hidden = YES;
            _textView.text = [NSString stringWithFormat:@"%@", error ? error : result];
        }];
    }
}

- (NSDictionary *)param {
    if ([[NSRegularExpression regularExpressionWithPattern:@"user-id" options:0 error:nil] firstMatchInString:_path options:0 range:(NSRange) {0, _path.length}])
        return @{@"user-id": @(1574083)};
    if ([[NSRegularExpression regularExpressionWithPattern:@"media-id" options:0 error:nil] firstMatchInString:_path options:0 range:(NSRange) {0, _path.length}])
        return @{@"media-id": @(3)};
    if ([[NSRegularExpression regularExpressionWithPattern:@"shortcode" options:0 error:nil] firstMatchInString:_path options:0 range:(NSRange) {0, _path.length}])
        return @{@"shortcode": @(3)};
    if ([[NSRegularExpression regularExpressionWithPattern:@"tag-name" options:0 error:nil] firstMatchInString:_path options:0 range:(NSRange) {0, _path.length}])
        return @{@"tag-name": @"snow"};
    if ([[NSRegularExpression regularExpressionWithPattern:@"location-id" options:0 error:nil] firstMatchInString:_path options:0 range:(NSRange) {0, _path.length}])
        return @{@"location-id": @(1)};
    if ([_path isEqualToString:IGApiPathUsersSearch])
        return @{@"q": @"goodman"};
    if ([_path isEqualToString:IGApiPathMediaSearch] ||
        [_path isEqualToString:IGApiPathLocationsSearch])
        return @{@"lat": @(48.858844), @"lng": @(2.294351)};
    if ([_path isEqualToString:IGApiPathTagsSearch])
        return @{@"q": @"snow"};
    if ([_path isEqualToString:IGApiPathSubscriptionsDel])
        return @{@"object": @"all"};
    return nil;
}

@end
