//
//  DemoViewController.m
//  InstagramSDK
//
//  Created by pisces on 04/29/2016.
//  Copyright (c) 2016 pisces. All rights reserved.
//

#import "DemoViewController.h"
#import "ApiResultViewController.h"
#import <Instagram-iOS-SDK/InstagramSDK.h>

@interface DemoViewController ()
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *button;
@end

@implementation DemoViewController
{
    NSArray<NSString *> *cellTexts;
}

// ================================================================================================
//  Overridden: UIViewController
// ================================================================================================

#pragma mark - Overridden: UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Instagram API Examples";
    cellTexts = [InstagramAppCenter defaultCenter].apiPaths;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setVisibilityForSubviews];
}

// ================================================================================================
//  Protocol Implementation
// ================================================================================================

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return cellTexts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *const cellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    cell.textLabel.text = cellTexts[indexPath.row];
    
    return cell;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ApiResultViewController *controller = [[ApiResultViewController alloc] initWithPath:cellTexts[indexPath.row]];
    
    [self.navigationController pushViewController:controller animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// ================================================================================================
//  Private
// ================================================================================================

#pragma mark - Private methods

- (void)setVisibilityForSubviews {
    _tableView.hidden = ![InstagramAppCenter defaultCenter].hasSession;
    _button.hidden = [InstagramAppCenter defaultCenter].hasSession;
    
    if ([InstagramAppCenter defaultCenter].hasSession) {
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout)]];
    } else {
        [self.navigationItem  setRightBarButtonItem:nil];
    }
}

#pragma mark - UIButton selector

- (IBAction)buttonClicked:(id)sender {
    [[InstagramAppCenter defaultCenter] loginWithCompletion:^(id result, NSError *error) {
        [self setVisibilityForSubviews];
    }];
}

#pragma mark - UIBarButtonItem selector

- (void)logout {
    [[InstagramAppCenter defaultCenter] logout];
    [self setVisibilityForSubviews];
}

@end
