//
//  DKSession.m
//  DeskKit
//
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

#import "DKSession.h"
#import "DKAPIManager.h"
#import "DKSettings.h"

static NSString *const DKStoryboardName = @"DKStoryboard";
static NSString *const DKTelpromptProtocol = @"telprompt://";
static NSString *const DKTelProtocol = @"tel://";
static NSString *const DKMailboxEmailKey = @"email";
static NSString *const DKEnabledPredicate = @"enabled = YES";

static NSInteger const DSMailboxesPerPage = 100;

@interface DKSession ()

@property (nonatomic, strong) NSString *contactUsToEmailAddress;
@property (nonatomic) NSOperationQueue *APICallbackQueue;
@property (nonatomic) NSURLSessionDataTask *listMailboxesTask;

@end

@implementation DKSession

+ (void)startWithHostname:(NSString *)hostname
                 APIToken:(NSString *)APIToken
{
    [DKSession sharedInstance];
    [[DKAPIManager sharedInstance] APIClientWithHostname:hostname
                                                APIToken:APIToken];
    
    [[DKSession sharedInstance] setupContactUsEmail];
    
    [DKSession setupAppearances];
}

+ (instancetype)sharedInstance
{
    static DKSession *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[DKSession alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _APICallbackQueue = [NSOperationQueue new];
    }
    return self;
}

+ (BOOL)isSessionStarted
{
    return [DKAPIManager sharedInstance].hasClient;
}

+ (UIStoryboard *)storyboard
{
    return [UIStoryboard storyboardWithName:DKStoryboardName bundle:[NSBundle bundleForClass:[self class]]];
}

+ (void)setupAppearances
{
    NSDictionary *topNavTitleTextAttributes = @{
                                                NSForegroundColorAttributeName : [[DKSettings sharedInstance] topNavTintColor],
                                                };
    
    [[UINavigationBar appearance] setTitleTextAttributes:topNavTitleTextAttributes];
    
    [[UINavigationBar appearance] setBarTintColor:[[DKSettings sharedInstance] topNavBarTintColor]];
    [[UINavigationBar appearance] setTintColor:[[DKSettings sharedInstance] topNavTintColor]];
    
    [[UIToolbar appearance] setBarTintColor:[[DKSettings sharedInstance] topNavBarTintColor]];
    [[UIToolbar appearance] setTintColor:[[DKSettings sharedInstance] topNavTintColor]];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], [UIToolbar class], nil] setTintColor:[[DKSettings sharedInstance] topNavTintColor]];
}

+ (DKTopicsViewController *)newTopicsViewController
{
    return [[[self class] storyboard] instantiateViewControllerWithIdentifier:DKTopicsViewControllerId];
}

+ (DKArticlesViewController *)newArticlesViewController
{
    return [[[self class] storyboard] instantiateViewControllerWithIdentifier:DKArticlesViewControllerId];
}

#pragma mark - Contact US

+ (UIAlertController *)newContactUsAlertControllerWithCallHandler:(void (^)(UIAlertAction *action))callHandler
                                                     emailHandler:(void (^)(UIAlertAction *action))emailHandler;
{
    UIAlertController *contactUsSheet = [UIAlertController alertControllerWithTitle:DKContactUs
                                                                            message:nil
                                                                     preferredStyle:UIAlertControllerStyleActionSheet];
    [[self class] addCancelButtonWithAlertController:contactUsSheet];
    [[self class] addCallUsButtonWithAlertController:contactUsSheet handler:callHandler];
    [[self class] addEmailUsButtonWithAlertController:contactUsSheet handler:emailHandler];
    return contactUsSheet;
}

+ (void)addCancelButtonWithAlertController:(UIAlertController *)controller
{
    [controller addAction:[UIAlertAction actionWithTitle:DKCancel
                                                   style:UIAlertActionStyleCancel
                                                 handler:nil]];
}

+ (void)addCallUsButtonWithAlertController:(UIAlertController *)controller handler:(void (^)(UIAlertAction *action))handler
{
    if ([DKSession sharedInstance].contactUsPhoneNumberURL) {
        [[self class] addCallUsActionWithAlertController:controller handler:handler];
    }
}

+ (UIAlertAction *)addCallUsActionWithAlertController:(UIAlertController *)controller handler:(void (^)(UIAlertAction *action))handler;
{
    UIAlertAction *callUsAction = [UIAlertAction actionWithTitle:DKCallUs
                                                           style:UIAlertActionStyleDefault
                                                         handler:handler];
    [controller addAction:callUsAction];
    return callUsAction;
}

+ (void)addEmailUsButtonWithAlertController:(UIAlertController *)controller handler:(void (^)(UIAlertAction *action))handler
{
    UIAlertAction *emailUsAction = [[self class] addEmailUsActionWithAlertController:controller handler:handler];
    emailUsAction.enabled = NO;
    [[DKSession sharedInstance] hasContactUsToEmailAddressWithCompletionHandler:^(BOOL hasContactUsToEmailAddress) {
        emailUsAction.enabled = hasContactUsToEmailAddress;
    }];
}

+ (UIAlertAction *)addEmailUsActionWithAlertController:(UIAlertController *)controller handler:(void (^)(UIAlertAction *action))handler
{
    UIAlertAction *emailUsAction = [UIAlertAction actionWithTitle:DKEmailUs
                                                            style:UIAlertActionStyleDefault
                                                          handler:handler];
    [controller addAction:emailUsAction];
    return emailUsAction;
}

- (DKContactUsViewController *)newContactUsViewController
{
    DKSettings *settings = [DKSettings sharedInstance];
    DKContactUsViewController *vc = [[[self class] storyboard] instantiateViewControllerWithIdentifier:DKContactUsViewControllerId];
    vc.toEmailAddress = self.contactUsToEmailAddress;
    
    if (settings.hasContactUsSubject) {
        vc.subject = settings.contactUsSubject;
    }
    vc.showSubjectItem = settings.contactUsShowSubjectItem;
    vc.showAllOptionalItems = settings.contactUsShowAllOptionalItems;
    vc.showYourNameItem = settings.contactUsShowYourNameItem;
    vc.showYourEmailItem = settings.contactUsShowYourEmailItem;
    
    if (settings.hasContactUsStaticCustomFields) {
        vc.customFields = settings.contactUsStaticCustomFields;
    }

    return vc;
}

+ (DKArticleDetailViewController *)newArticleDetailViewController
{
    return [[[self class] storyboard] instantiateViewControllerWithIdentifier:DKArticleDetailViewControllerId];
}

#pragma mark - Phone

- (NSURL *)contactUsPhoneNumberURL
{
    if (![[self class] hasContactUsPhoneNumber]) {
        return nil;
    } else {
        NSURL *URL = [NSURL URLWithString:[DKTelpromptProtocol stringByAppendingString:[DKSettings sharedInstance].contactUsPhoneNumber]];
        // Add a check to ensure that the telprompt url can be opened. See this link for more info:
        // http://stackoverflow.com/questions/20072123/telprompt-vs-tel-and-app-approval
        BOOL canOpenURL = [[UIApplication sharedApplication] canOpenURL:URL];
        if (canOpenURL) {
            return URL;
        }
        URL = [NSURL URLWithString:[DKTelProtocol stringByAppendingString:[DKSettings sharedInstance].contactUsPhoneNumber]];
        canOpenURL = [[UIApplication sharedApplication] canOpenURL:URL];
        if (canOpenURL) {
            return URL;
        }
        return nil;
    }
}

+ (BOOL)hasContactUsPhoneNumber
{
    return [DKSettings sharedInstance].hasContactUsPhoneNumber;
}

#pragma mark - Email

- (void)setupContactUsEmail
{
    if ([DKSettings sharedInstance].hasContactUsToEmailAddress) {
        self.contactUsToEmailAddress = [DKSettings sharedInstance].contactUsToEmailAddress;
    } else {
        [[DKSession sharedInstance] fetchInboundMailboxesWithCompletionHandler:nil];
    }
}

- (void)fetchInboundMailboxesWithCompletionHandler:(void (^)(void))completionHandler
{
    [self.listMailboxesTask cancel];
    self.listMailboxesTask = [DSAPIMailbox listMailboxesOfType:DSAPIMailboxTypeInbound
                                                    parameters:@{ kPageKey : @1,
                                                                  kPerPageKey : @(DSMailboxesPerPage) }
                                                         queue:self.APICallbackQueue
                                                       success:^(DSAPIPage *page) {
                                                           if ([page.totalEntries integerValue]) {
                                                               self.contactUsToEmailAddress = [self firstEnabledInboundEmailAddressFromPage:page];
                                                           }
                                                           if (completionHandler) {
                                                               dispatch_sync(dispatch_get_main_queue(), ^{
                                                                   completionHandler();
                                                               });
                                                           }
                                                       }
                                                       failure:^(NSHTTPURLResponse *response, NSError *error) {
                                                           if (completionHandler) {
                                                               dispatch_sync(dispatch_get_main_queue(), ^{
                                                                   completionHandler();
                                                               });
                                                           }
                                                       }];
}

- (void)hasContactUsToEmailAddressWithCompletionHandler:(void (^ __nonnull)(BOOL hasContactUsToEmailAddress))completionHandler
{
    if (self.contactUsToEmailAddress.length > 0) {
        completionHandler(YES);
    } else {
        [self fetchInboundMailboxesWithCompletionHandler:^{
            self.contactUsToEmailAddress.length > 0 ? completionHandler(YES) : completionHandler(NO);
        }];
    }
}

- (DSAPIMailbox *)firstEnabledInboundMailboxFromPage:(DSAPIPage *)page
{
    NSPredicate *enabledPredicate = [NSPredicate predicateWithFormat:DKEnabledPredicate];
    NSArray *enabledMailboxes = [page.entries filteredArrayUsingPredicate:enabledPredicate];
    return enabledMailboxes.firstObject;
}

- (NSString *)firstEnabledInboundEmailAddressFromPage:(DSAPIPage *)page
{
    return [[self firstEnabledInboundMailboxFromPage:page] valueForKey:DKMailboxEmailKey];
}

@end
