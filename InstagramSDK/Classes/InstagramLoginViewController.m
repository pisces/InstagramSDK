//
//  InstagramLoginViewController.m
//  InstagramSDK
//
//  Created by pisces on 2016. 5. 3..
//  Copyright (c) 2016 pisces. All rights reserved.
//

#import "InstagramLoginViewController.h"
#import "InstagramSDK.h"

@interface InstagramLoginViewController ()
@property (nonatomic, readonly) NSURL *authorizeURL;
@property (nonatomic, readonly) UIViewController *topViewController;
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@end

@implementation InstagramLoginViewController
{
    BOOL modelChanged;
}

// ================================================================================================
//  Overridden: UIViewController
// ================================================================================================

#pragma mark - Overridden: UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [InstagramSDK localizedStringForKey:@"Login - Instagram" table:@"word"];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:[InstagramSDK localizedStringForKey:@"Cancel" table:@"word"] style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)]];
    [self invalidateModelChanging];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

// ================================================================================================
//  Public
// ================================================================================================

#pragma mark - Public getter/setter

- (void)setModel:(OAuth2Model *)model {
    if ([model isEqual:_model])
        return;
    
    _model = model;
    modelChanged = YES;
    
    [self invalidateModelChanging];
}

#pragma mark - Public methods

- (instancetype)initWithModel:(OAuth2Model *)model {
    self = [super initWithNibName:@"InstagramLoginView" bundle:[InstagramSDK bundle]];
    
    if (self) {
        self.model = model;
    }
    
    return self;
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:^{
        if ([_delegate respondsToSelector:@selector(didDismissViewController)])
            [_delegate didDismissViewController];
    }];
}

- (void)present {
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
    
    [self.topViewController presentViewController:navigationController animated:YES completion:nil];
}

// ================================================================================================
//  Protocol Implementation
// ================================================================================================

#pragma mark - UIWebView delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *absoluteString = request.URL.absoluteString;
    
    if ([absoluteString hasPrefix:_model.redirectURI]) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self webViewDidFinishLoad:webView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    _activityIndicatorView.hidden = YES;
    
    [_activityIndicatorView stopAnimating];
}

// ================================================================================================
//  Private
// ================================================================================================

#pragma mark - Private getter/setter

- (NSURL *)authorizeURL {
    if (!_model)
        return nil;
    
    NSDictionary *actionDict = [[HTTPActionManager sharedInstance] actionWith:@"authorize"];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", actionDict[@"url"], [_model paramWithType:InstagramParametersTypeLogin].urlString]];
    
    return URL ? URL : [NSURL URLWithString:actionDict[@"url"]];
}

- (UIViewController *)topViewController {
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (controller.presentedViewController) {
        controller = controller.presentedViewController;
    }
    
    return controller;
}

#pragma mark - Private

- (void)invalidateModelChanging {
    if (!self.isViewLoaded)
        return;
    
    if (modelChanged) {
        modelChanged = NO;
        _activityIndicatorView.hidden = NO;
        
        [_activityIndicatorView startAnimating];
        [_webView stopLoading];
        [_webView loadRequest:[NSURLRequest requestWithURL:self.authorizeURL]];
    }
}

@end
