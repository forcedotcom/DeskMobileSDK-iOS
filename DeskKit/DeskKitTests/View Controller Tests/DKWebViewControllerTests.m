//
//  DKWebViewControllerTests.m
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DKWebViewController.h"
#import "DKTestUtils.h"

@interface DKWebViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionButton;

- (void)setupDisplayModeButtonItem;
- (UISplitViewController *)parentSplitViewController;
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

@interface DKWebViewControllerTests : XCTestCase

@property (nonatomic, strong) DKWebViewController *viewController;
@property (nonatomic, strong) id mock;

@end

@implementation DKWebViewControllerTests

- (void)setUp
{
    [super setUp];
    self.viewController = [DKTestUtils articleDetailViewController];
    self.mock = OCMPartialMock(self.viewController);
}

- (void)testViewDidLoadAddsWebView
{
    OCMExpect([self.mock addWebViewToContainerView]);
    [self.viewController view];
    OCMVerifyAll(self.mock);
}

- (void)testViewDidLoadSetsAutomaticallyAdjustsScrollViewInsetsToNo
{
    [self.viewController view];
    XCTAssertFalse(self.viewController.automaticallyAdjustsScrollViewInsets);
}

- (void)testViewDidLoadRegistersKvo
{
    OCMExpect([self.mock registerKvo]);
    [self.viewController view];
    OCMVerifyAll(self.mock);
}

- (void)testViewDidLoadSetsUpAccessibilityLabels
{
    OCMExpect([self.mock setupButtonAccessibilityLabels]);
    [self.viewController view];
    OCMVerifyAll(self.mock);
}

- (void)testSetUpAccessibilityLabels
{
    OCMExpect([self.mock setBackButtonAccessibilityLabel]);
    OCMExpect([self.mock setForwardButtonAccessibilityLabel]);
    OCMExpect([self.mock setRefreshButtonAccessibilityLabel]);
    OCMExpect([self.mock setActionButtonAccessibilityLabel]);
    
    [self.viewController setupButtonAccessibilityLabels];
    
    OCMVerifyAll(self.mock);
}

- (void)testAddWebView
{
    [self.viewController view];
    OCMExpect([self.mock addConstraintsFromWebViewToContainerView]);
    
    [self.viewController addWebViewToContainerView];
    
    OCMVerifyAll(self.mock);
    XCTAssertNotNil(self.viewController.webView);
    XCTAssertTrue([self.viewController.containerView.subviews containsObject:self.viewController.webView]);
}

- (void)testRegisterKvoCallsAddObserver
{
    [self.viewController view];
    
    id webViewMock = OCMPartialMock(self.viewController.webView);
    OCMExpect([webViewMock addObserver:self.viewController forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:nil]);
    OCMExpect([webViewMock addObserver:self.viewController forKeyPath:@"canGoForward" options:NSKeyValueObservingOptionNew context:nil]);
    
    [self.viewController registerKvo];
    
    OCMVerifyAll(webViewMock);
}

- (void)testRemoveKvoRemovesObserver
{
    [self.viewController view];
    [self.viewController registerKvo];
    
    id webViewMock = OCMPartialMock(self.viewController.webView);
    OCMExpect([webViewMock removeObserver:self.viewController forKeyPath:@"canGoBack"]);
    OCMExpect([webViewMock removeObserver:self.viewController forKeyPath:@"canGoForward"]);
    
    [self.viewController removeKvo];
    
    OCMVerifyAll(webViewMock);
}

- (void)testBackButtonTappedGoesBack
{
    [self.viewController view];
    
    id webViewMock = OCMPartialMock(self.viewController.webView);
    
    OCMExpect([(WKWebView *)webViewMock goBack]);
    
    [self.viewController backButtonTapped:nil];
    
    OCMVerifyAll(webViewMock);
}

- (void)testForwardButtonTapped
{
    [self.viewController view];
    
    id webViewMock = OCMPartialMock(self.viewController.webView);
    
    OCMExpect([(WKWebView *)webViewMock goForward]);
    
    [self.viewController forwardButtonTapped:nil];
    
    OCMVerifyAll(webViewMock);
}

- (void)testRefreshButtonTapped
{
    OCMExpect([self.mock refresh]);
    
    [self.viewController refreshButtonTapped:nil];
    
    OCMVerifyAll(self.mock);
}

- (void)testWebViewStartedLoadingDisablesToolbarButtons
{
    OCMExpect([self.mock setToolbarButtonsEnabled:NO]);
    [self.viewController webViewStartedLoading];
    OCMVerifyAll(self.mock);
}

- (void)testWebViewFinishedLoadingEnablesToolbarButtons
{
    OCMExpect([self.mock setToolbarButtonsEnabled:YES]);
    [self.viewController webViewStartedLoading];
    [self.viewController webViewFinishedLoading];
    OCMVerifyAll(self.mock);
}

- (void)testSetToolbarButtonsEnabled
{
    [self.viewController view];
    
    [[self.mock reject] setBackButtonEnabledByWebView];
    [[self.mock reject] setForwardButtonEnabledByWebView];
    
    [self.viewController setToolbarButtonsEnabled:NO];
    
    XCTAssertFalse(self.viewController.backButton.enabled);
    XCTAssertFalse(self.viewController.forwardButton.enabled);
    XCTAssertFalse(self.viewController.refreshButton.enabled);
    XCTAssertFalse(self.viewController.actionButton.enabled);
    
    OCMVerifyAll(self.mock);
}

- (void)testSetToolbarButtonsDisabled
{
    [self.viewController view];
    
    [[self.mock expect] setBackButtonEnabledByWebView];
    [[self.mock expect] setForwardButtonEnabledByWebView];
    
    [self.viewController setToolbarButtonsEnabled:YES];
    
    XCTAssertTrue(self.viewController.refreshButton.enabled);
    XCTAssertTrue(self.viewController.actionButton.enabled);
    
    OCMVerifyAll(self.mock);
}

@end