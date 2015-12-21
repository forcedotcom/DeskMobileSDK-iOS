//
//  DKWebViewController.m
//  DeskKit
//
//  Created by Desk.com on 1/19/15.
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

#import "DKWebViewController.h"
#import <DeskAPIClient/DSAPINetworkIndicatorController.h>

static NSString *const DKWebViewCanGoBack = @"canGoBack";
static NSString *const DKWebViewCanGoForward = @"canGoForward";

#define DSBackButtonLabel NSLocalizedString(@"Back", @"Back button label");
#define DSForwardButtonLabel NSLocalizedString(@"Forward", @"Forward button label");
#define DSActionButtonLabel NSLocalizedString(@"Action", @"Action button label");
#define DSRefreshButtonLabel NSLocalizedString(@"Refresh", @"Refresh button label");

@interface DKWebViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic) UIBarButtonItem *backButton;
@property (nonatomic) UIBarButtonItem *forwardButton;
@property (nonatomic) UIBarButtonItem *refreshButton;
@property (nonatomic) UIBarButtonItem *actionButton;

@property (strong, nonatomic) WKWebView *webView;
@property (nonatomic, assign) BOOL needsLoad;

- (void)addWebViewToContainerView;
- (void)addConstraintsFromWebViewToContainerView;
- (NSArray *)constraintsForWebView;
- (void)setBackButtonEnabledByWebView;
- (void)setForwardButtonEnabledByWebView;
- (void)setupButtonAccessibilityLabels;
- (void)setBackButtonAccessibilityLabel;
- (void)setForwardButtonAccessibilityLabel;
- (void)setRefreshButtonAccessibilityLabel;
- (void)setActionButtonAccessibilityLabel;

- (void)webViewStartedLoading;
- (void)webViewFinishedLoading;
- (void)setToolbarButtonsEnabled:(BOOL)enabled;
- (IBAction)backButtonTapped:(id)sender;
- (IBAction)forwardButtonTapped:(id)sender;
- (IBAction)refreshButtonTapped:(id)sender;
- (IBAction)actionButtonTapped:(id)sender;

- (void)registerKvo;
- (void)removeKvo;

@end

@implementation DKWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupToolbar];
    [self addWebViewToContainerView];
    [self registerKvo];
    [self setupButtonAccessibilityLabels];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.needsLoad) {
        [self refresh];
    }
}

- (void)dealloc
{
    [self removeKvo];
    self.webView = nil;
}

- (void)setupToolbar
{
    NSInteger fixedSpaceWidth = 21;
    self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"DKBack"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    UIBarButtonItem *space1 = [self newSpacerBarButtonItemFlexible:NO];
    space1.width = fixedSpaceWidth;
    self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"DKForward"] style:UIBarButtonItemStylePlain target:self action:@selector(forwardButtonTapped:)];
    UIBarButtonItem *space2 = [self newSpacerBarButtonItemFlexible:YES];
    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonTapped:)];
    UIBarButtonItem *space3 = [self newSpacerBarButtonItemFlexible:NO];
    space3.width = fixedSpaceWidth;
    self.actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonTapped:)];
    self.toolbarItems = @[self.backButton, space1, self.forwardButton, space2, self.refreshButton, space3, self.actionButton];
}

- (UIBarButtonItem *)newSpacerBarButtonItemFlexible:(BOOL)flexible
{
    UIBarButtonSystemItem item = flexible ? UIBarButtonSystemItemFlexibleSpace : UIBarButtonSystemItemFixedSpace;
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:item target:nil action:nil];
}

- (void)addWebViewToContainerView
{
    if (self.webView == nil) {
        self.webView = [WKWebView new];
    }
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.webView];
    [self addConstraintsFromWebViewToContainerView];
    self.webView.navigationDelegate = self;
}

- (void)addConstraintsFromWebViewToContainerView
{
    [self.containerView addConstraints:self.constraintsForWebView];
}

- (NSArray *)constraintsForWebView
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_webView);
    
    NSArray *hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_webView]|" options:NSLayoutFormatAlignAllTop metrics:nil views:views];
    NSArray *vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_webView]|" options:NSLayoutFormatAlignAllLeft metrics:nil views:views];
    
    return [hConstraints arrayByAddingObjectsFromArray:vConstraints];
}

- (void)setNeedsLoad
{
    if (self.isViewLoaded && self.view.window) {
        // viewController is visible
        [self refresh];
    } else {
        _needsLoad = YES;
    }
}

#pragma mark - Web view navigation

- (void)setBackButtonEnabledByWebView
{
    self.backButton.enabled = self.webView.canGoBack;
}

- (void)setForwardButtonEnabledByWebView
{
    self.forwardButton.enabled = self.webView.canGoForward;
}

- (void)setupButtonAccessibilityLabels
{
    [self setBackButtonAccessibilityLabel];
    [self setForwardButtonAccessibilityLabel];
    [self setRefreshButtonAccessibilityLabel];
    [self setActionButtonAccessibilityLabel];
}

- (void)setBackButtonAccessibilityLabel
{
    self.backButton.accessibilityLabel = DSBackButtonLabel;
}

- (void)setForwardButtonAccessibilityLabel
{
    self.forwardButton.accessibilityLabel = DSForwardButtonLabel;
}

- (void)setRefreshButtonAccessibilityLabel
{
    self.refreshButton.accessibilityLabel = DSRefreshButtonLabel;
}

- (void)setActionButtonAccessibilityLabel
{
    self.actionButton.accessibilityLabel = DSActionButtonLabel;
}

#pragma mark - WebView Navigation

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    [self webViewStartedLoading];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error
{
    [self webViewFinishedLoading];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self webViewFinishedLoading];
}

- (void)webViewStartedLoading
{
    [[DSAPINetworkIndicatorController sharedController] networkActivityDidStart];
    [self setToolbarButtonsEnabled:NO];
}

- (void)webViewFinishedLoading
{
    [[DSAPINetworkIndicatorController sharedController] networkActivityDidEnd];
    [self setToolbarButtonsEnabled:YES];
    self.needsLoad = NO;
}

- (void)setToolbarButtonsEnabled:(BOOL)enabled
{
    self.refreshButton.enabled = enabled;
    self.actionButton.enabled = enabled;
    
    if (enabled) {
        [self setBackButtonEnabledByWebView];
        [self setForwardButtonEnabledByWebView];
    } else {
        self.backButton.enabled = enabled;
        self.forwardButton.enabled = enabled;
    }
}

- (IBAction)backButtonTapped:(id)sender
{
    [self.webView goBack];
}

- (IBAction)forwardButtonTapped:(id)sender
{
    [self.webView goForward];
}

- (IBAction)refreshButtonTapped:(id)sender
{
    [self refresh];
}

- (void)refresh
{
    // override in subclass
}

- (IBAction)actionButtonTapped:(id)sender
{
    [self executeAction];
}

- (void)executeAction
{
    // override in subclass
}

#pragma mark - KVO

- (void)registerKvo
{
    
    [self.webView addObserver:self
                   forKeyPath:DKWebViewCanGoBack
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    
    [self.webView addObserver:self
                   forKeyPath:DKWebViewCanGoForward
                      options:NSKeyValueObservingOptionNew
                      context:nil];
}

- (void)removeKvo
{
    [self.webView removeObserver:self forKeyPath:DKWebViewCanGoBack];
    [self.webView removeObserver:self forKeyPath:DKWebViewCanGoForward];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:DKWebViewCanGoBack]) {
        [self setBackButtonEnabledByWebView];
    }
    if ([keyPath isEqualToString:DKWebViewCanGoForward]) {
        [self setForwardButtonEnabledByWebView];
    }
}

@end
