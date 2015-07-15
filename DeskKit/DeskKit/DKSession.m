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

@property (nonatomic, strong) NSURL *contactUsPhoneNumberUrl;
@property (nonatomic, strong) NSString *contactUsEmailAddress;

+ (void)setupAppearances;
- (void)setupContactUsEmail;
- (void)fetchInboundMailboxes;
- (DSAPIMailbox *)firstEnabledInboundMailboxFromPage:(DSAPIPage *)page;
- (NSString *)firstEnabledInboundEmailAddressFromPage:(DSAPIPage *)page;

@end

@implementation DKSession

+ (void)start:(NSString *)hostname
     apiToken:(NSString *)apiToken
{
    [DKSession sharedInstance];
    [[DKAPIManager sharedInstance] apiClientWithHostname:hostname
                                                apiToken:apiToken];

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

+ (BOOL)isSessionStarted
{
    return [DKAPIManager sharedInstance].hasClient;
}

+ (UIStoryboard *)storyboard
{
    return [UIStoryboard storyboardWithName:DKStoryboardName bundle:[NSBundle bundleForClass:[self class]]];
}

+ (DKTopicsViewController *)newTopicsViewController
{
    return [[[self class] storyboard] instantiateViewControllerWithIdentifier:DKTopicsViewControllerId];
}

+ (DKArticlesViewController *)newArticlesViewController
{
    return [[[self class] storyboard] instantiateViewControllerWithIdentifier:DKArticlesViewControllerId];
}

+ (DKContactUsWebViewController *)newContactUsWebViewController
{
    return [[[self class] storyboard] instantiateViewControllerWithIdentifier:DKContactUsWebViewControllerId];
}

+ (DKArticleDetailViewController *)newArticleDetailViewController
{
    return [[[self class] storyboard] instantiateViewControllerWithIdentifier:DKArticleDetailViewControllerId];
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

- (BOOL)shouldShowContactUsButton
{
    return [self hasContactUsEmailAddress] || [self hasContactUsPhoneNumber];
}

- (NSURL *)contactUsPhoneNumberUrl
{
    if (!self.hasContactUsPhoneNumber) {
        return nil;
    } else {
        NSURL *url = [NSURL URLWithString:[DKTelpromptProtocol stringByAppendingString:[DKSettings sharedInstance].contactUsPhoneNumber]];
        // Add a check to ensure that the telprompt url can be opened. See this link for more info:
        // http://stackoverflow.com/questions/20072123/telprompt-vs-tel-and-app-approval
        return [[UIApplication sharedApplication] canOpenURL:url] ? url : [NSURL URLWithString:[DKTelProtocol stringByAppendingString:[DKSettings sharedInstance].contactUsPhoneNumber]];
    }
}

- (BOOL)hasContactUsPhoneNumber
{
    return [DKSettings sharedInstance].hasContactUsPhoneNumber;
}

- (void)setupContactUsEmail
{
    if ([DKSettings sharedInstance].hasContactUsEmailAddress) {
        self.contactUsEmailAddress = [DKSettings sharedInstance].contactUsEmailAddress;
    } else {
        [[DKSession sharedInstance] fetchInboundMailboxes];
    }
}

- (void)fetchInboundMailboxes
{
    [DSAPIMailbox listMailboxesOfType:DSAPIMailboxTypeInbound
                           parameters:@{ kPageKey : @1,
                                         kPerPageKey : @(DSMailboxesPerPage) }
                              success:^(DSAPIPage *page) {
                                  if ([page.totalEntries integerValue]) {
                                      self.contactUsEmailAddress = [self firstEnabledInboundEmailAddressFromPage:page];
                                  }
                              }
                              failure:nil];
}

- (BOOL)hasContactUsEmailAddress
{
    return self.contactUsEmailAddress.length > 0;
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
