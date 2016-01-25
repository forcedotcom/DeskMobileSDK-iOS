//
//  DKSplitViewController.m
//  DeskKit
//
//  Created by Desk.com on 9/15/14.
//  Copyright (c) 2015, Salesforce.com, Inc.
//  All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided
//  that the following conditions are met:
//  
//     Redistributions of source code must retain the above copyright notice, this list of conditions and the
//     following disclaimer.
//  
//     Redistributions in binary form must reproduce the above copyright notice, this list of conditions and
//     the following disclaimer in the documentation and/or other materials provided with the distribution.
//  
//     Neither the name of Salesforce.com, Inc. nor the names of its contributors may be used to endorse or
//     promote products derived from this software without specific prior written permission.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
//  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
//  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//

#import "SplitViewController.h"
#import "DKArticlesViewController.h"
#import "DKArticleDetailViewController.h"
#import "DKSession.h"
#import "NSDate+DSC.h"

static NSString *const DKEmptyViewControllerId = @"DKEmptyViewController";

@interface SplitViewController () <DKTopicsViewControllerDelegte, DKArticlesViewControllerDelegate, DKContactUsViewControllerDelegate>

@property (nonatomic) DKTopicsViewController *topicsViewController;
@property (nonatomic) DKArticleDetailViewController *articleDetailViewController;
@property (nonatomic, assign) NSInteger contactUsButtonIndex;
@property (nonatomic, assign) DSAPIArticle *selectedArticle;

- (void)showMasterViewControllerIfNeeded;
- (UINavigationController *)masterNavigationController;
- (UINavigationController *)detailNavigationController;
- (BOOL)isViewControllerNavigationController:(UIViewController *)viewController;
- (BOOL)isViewControllerArticleDetailViewController:(UIViewController *)viewController;
- (BOOL)articleDetailViewControllerHasArticle:(DKArticleDetailViewController *)viewController;

@end

@implementation SplitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    [self setupAppearances];

    self.topicsViewController = [self newTopicsViewController];
    [self.masterNavigationController setViewControllers:@[self.topicsViewController]];
    self.masterNavigationController.toolbarHidden = NO;
    self.detailNavigationController.toolbarHidden = NO;

    [self showMasterViewControllerIfNeeded];
}

- (void)showMasterViewControllerIfNeeded
{
    self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
}

- (void)invalidateCache
{
    [self.topicsViewController invalidateArticleCache];
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    self.topicsViewController.title = title;
}

- (UINavigationController *)masterNavigationController
{
    return self.viewControllers.firstObject;
}

- (UINavigationController *)detailNavigationController
{
    return self.viewControllers.lastObject;
}

- (void)setupAppearances
{
    UIColor *tintColor = [UIColor colorWithRed:16.0/255.0 green:122.0/255.0 blue:135.0/255.0 alpha:1.0];
    UIColor *barTintColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
    
    NSDictionary *topNavTitleTextAttributes = @{
                                                NSForegroundColorAttributeName : tintColor,
                                                };
    
    [[UINavigationBar appearance] setTitleTextAttributes:topNavTitleTextAttributes];
    
    [[UINavigationBar appearance] setBarTintColor:barTintColor];
    [[UINavigationBar appearance] setTintColor:tintColor];
    
    [[UIToolbar appearance] setBarTintColor:barTintColor];
    [[UIToolbar appearance] setTintColor:tintColor];
}

#pragma mark - Split View Controller Delegate

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
collapseSecondaryViewController:(UIViewController *)secondaryViewController
  ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    if (self.selectedArticle) {
        if ([self isViewControllerNavigationController:secondaryViewController]) {
            UIViewController *topVC = [(UINavigationController *)secondaryViewController topViewController];
            if ([self isViewControllerArticleDetailViewController:topVC]) {
                DKArticleDetailViewController *detailVC = (DKArticleDetailViewController *)topVC;
                if ([self isViewControllerNavigationController:primaryViewController]) {
                    detailVC.navigationItem.leftBarButtonItem = nil;
                    [(UINavigationController *)primaryViewController pushViewController:detailVC animated:NO];
                    // YES: Tells UIKit not to do anything, we handled hierarchy.
                    return YES;
                } else {
                    // YES: Tells UIKit not to do anything, ignoring detail view.
                    return YES;
                }
            } else {
                // YES: Tells UIKit not to do anything, ignoring empty view.
                return YES;
            }
        } else {
            // NO: Tells UIKit performs default behavior which is collapsing secondary onto primary.
            return NO;
        }
    } else {
        // YES: Tells UIKit not to do anything, ignoring empty view.
        return YES;
    }
}

- (UIViewController *)splitViewController:(UISplitViewController *)splitViewController
separateSecondaryViewControllerFromPrimaryViewController:(UIViewController *)primaryViewController
{
    if (self.selectedArticle) {
        if ([self isViewControllerNavigationController:primaryViewController]) {
            UINavigationController *primaryNavVC = (UINavigationController *)primaryViewController;
            DKArticleDetailViewController *detailVC;
            if ([self isViewControllerArticleDetailViewController:primaryNavVC.topViewController]) {
                detailVC = (DKArticleDetailViewController *)primaryNavVC.topViewController;
                [primaryNavVC popViewControllerAnimated:NO];
            }
            else {
                detailVC = self.articleDetailViewController;
                detailVC.article = self.selectedArticle;
            }
            detailVC.navigationItem.leftBarButtonItem = self.displayModeButtonItem;
            UINavigationController *secondaryNavVC = [[UINavigationController alloc] initWithRootViewController:detailVC];
            return secondaryNavVC;

        } else {
            return nil;
        }
    } else {
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:[[self class] emptyViewController]];
        return nvc;
    }
}

- (BOOL)isViewControllerNavigationController:(UIViewController *)viewController
{
    return [viewController isKindOfClass:[UINavigationController class]];
}

- (BOOL)isViewControllerArticleDetailViewController:(UIViewController *)viewController
{
    return [viewController isKindOfClass:[DKArticleDetailViewController class]];
}

- (BOOL)articleDetailViewControllerHasArticle:(DKArticleDetailViewController *)viewController
{
    return [viewController article] != nil;
}

#pragma mark - DKContactUsViewControllerDelegate

- (void)contactUsViewControllerDidSendMessage:(DKContactUsViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)contactUsViewControllerDidCancel:(DKContactUsViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - DKTopicsViewControllerDelegate

- (void)topicsViewController:(DKTopicsViewController *)topicsViewController didSelectTopic:(DSAPITopic *)topic articlesTopicViewModel:(DKArticlesTopicViewModel *)articlesTopicViewModel
{
    DKArticlesViewController *controller = [self newArticlesViewController];
    controller.delegate = self;
    [controller setViewModel:articlesTopicViewModel topic:topic];
    [self.masterNavigationController pushViewController:controller animated:YES];
}

- (void)topicsViewController:(DKTopicsViewController *)topicsViewController didSelectSearchedArticle:(DSAPIArticle *)article
{
    [self showArticle:article];
}

#pragma mark - DKArticlesViewControllerDelegate

- (void)articlesViewController:(DKArticlesViewController *)articlesViewController didSelectSearchedArticle:(DSAPIArticle *)article
{
    [self showArticle:article];
}

- (void)articlesViewController:(DKArticlesViewController *)articlesViewController didSelectArticle:(DSAPIArticle *)article
{
    [self showArticle:article];
}

- (void)showArticle:(DSAPIArticle *)article
{
    self.selectedArticle = article;
    if (!self.articleDetailViewController) {
        self.articleDetailViewController = [self newArticleDetailViewController];
    }
    self.articleDetailViewController.article = article;
    if (self.viewControllers.count == 2) {
        self.articleDetailViewController.navigationItem.leftBarButtonItem = self.displayModeButtonItem;
        [self.detailNavigationController setViewControllers:@[self.articleDetailViewController]];
    } else {
        [self.detailNavigationController pushViewController:self.articleDetailViewController animated:YES];
    }
}

#pragma mark - Action Sheet

- (void)openActionSheet
{
    UIAlertController *contactUsSheet = [DKSession newContactUsAlertControllerWithCallHandler:^(UIAlertAction * __nonnull callAction) {
        [[UIApplication sharedApplication] openURL:[[DKSession sharedInstance] contactUsPhoneNumberURL]];
    } emailHandler:^(UIAlertAction * __nonnull emailAction) {
        [self alertControllerDidTapEmailUs];
    }];
    
    UIBarButtonItem *contactUsButton = self.masterNavigationController.topViewController.toolbarItems[self.contactUsButtonIndex];
    contactUsSheet.popoverPresentationController.barButtonItem = contactUsButton;
    
    [self presentViewController:contactUsSheet animated:YES completion:nil];
}

- (void)contactUsButtonTapped:(id)sender
{
    [self openActionSheet];
}

- (void)alertControllerDidTapEmailUs
{
    DKContactUsViewController *contactUsVC = [[DKSession sharedInstance] newContactUsViewController];
    contactUsVC.delegate = self;

/*
    // Example of adding custom fields
    // 1. Grab initial custom fields populated from DeskKitSettings.plist
    NSMutableDictionary *customFields = [contactUsVC.customFields mutableCopy];
    // 2. Add your own dynamic custom fields.
    [customFields addEntriesFromDictionary:[self dynamicCustomFields]];
    // 3. Assign back to property.
    contactUsVC.customFields = customFields;
*/

    // Configure additional properties of DKContactUsViewController here

    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:contactUsVC];
    nvc.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)doneButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Custom Fields Example

- (NSDictionary *)dynamicCustomFields
{
    // The keys and value types must match the custom fields defined in your Desk admin site.
    return @{@"my_case_boolean_custom_field" : @YES,
             @"my_case_date_custom_field" : [[NSDate date] stringWithISO8601Format],
             @"my_case_list_custom_field" : @"C",
             @"my_case_number_custom_field" : @45, // Integer
             @"my_case_text_custom_field" : @"value1"
             };
}

#pragma mark - View Controllers from Storyboard

+ (UIViewController *)emptyViewController
{
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:DKEmptyViewControllerId];
}

- (DKTopicsViewController *)newTopicsViewController
{
    DKTopicsViewController *controller = [DKSession newTopicsViewController];
    controller.delegate = self;
    [controller setTitle:NSLocalizedString(@"Topics", comment: @"Topics")];
    
    controller.toolbarItems = [self contactUsToolbarItems];
    
    return controller;
}

- (NSArray *)contactUsToolbarItems
{
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *spacer2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *contactUsButton = [[UIBarButtonItem alloc] initWithTitle:DKContactUs style:UIBarButtonItemStylePlain target:self action:@selector(contactUsButtonTapped:)];
    self.contactUsButtonIndex = 1;
    return @[spacer1, contactUsButton, spacer2];
}

- (DKArticlesViewController *)newArticlesViewController
{
    DKArticlesViewController *controller = [DKSession newArticlesViewController];
    controller.toolbarItems = [self contactUsToolbarItems];
    return controller;
}

- (DKArticleDetailViewController *)newArticleDetailViewController
{
    DKArticleDetailViewController *controller = [DKSession newArticleDetailViewController];
    return controller;
}

@end
