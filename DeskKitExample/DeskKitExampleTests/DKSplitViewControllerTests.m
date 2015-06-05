//
//  DKSplitViewControllerTests.m
//  DeskKit
//
//  Created by Desk.com on 9/17/14.
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

/*
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DKTestUtils.h"
#import "DKEmptyViewController.h"
#import "DKArticleDetailViewModel.h"

@interface DKSplitViewController ()

- (void)showMasterViewControllerIfNeeded;
- (UINavigationController *)masterNavigationController;
- (DKTopicsViewController *)topicsViewController;
- (UIViewController *)secondaryViewControllerForExpandingPrimaryViewController:(UIViewController *)viewController;
- (BOOL)viewControllerStackHasArticle:(UIViewController *)viewController;
- (BOOL)isViewControllerNavigationController:(UIViewController *)viewController;
- (BOOL)isViewControllerArticleDetailViewController:(UIViewController *)viewController;
- (BOOL)articleDetailViewControllerHasArticle:(DKArticleDetailViewController *)viewController;

@end

@interface DKSplitViewControllerTests : XCTestCase

@property (nonatomic, strong) DKSplitViewController *viewController;

@end

@implementation DKSplitViewControllerTests

- (void)setUp
{
    [super setUp];
    self.viewController = [DKSession rootViewControllerWithTitle:@"Foo"];
}

- (void)testViewDidLoadSetsSelfAsDelegate
{
    [self.viewController viewDidLoad];
    XCTAssertEqual(self.viewController.delegate, self.viewController);
}

- (void)testViewDidLoadCallsShowMasterViewControllerIfNeeded
{
    id mock = OCMPartialMock(self.viewController);
    OCMExpect([mock showMasterViewControllerIfNeeded]);
    
    [self.viewController viewDidLoad];
    
    OCMVerifyAll(mock);
}

- (void)testShowMasterViewControllerIfNeeded
{
    id mock = OCMPartialMock(self.viewController);
    OCMStub([mock traitCollection]).andReturn([UITraitCollection traitCollectionWithUserInterfaceIdiom:UIUserInterfaceIdiomPad]);
    
    [self.viewController showMasterViewControllerIfNeeded];
    XCTAssertEqual(self.viewController.preferredDisplayMode, UISplitViewControllerDisplayModeAllVisible);
}

- (void)testShowMasterViewControllerIfNeededForPhone
{
    id mock = OCMPartialMock(self.viewController);
    OCMStub([mock traitCollection]).andReturn([UITraitCollection traitCollectionWithUserInterfaceIdiom:UIUserInterfaceIdiomPhone]);
    
    [self.viewController showMasterViewControllerIfNeeded];
    XCTAssertEqual(self.viewController.preferredDisplayMode, UISplitViewControllerDisplayModeAutomatic);
}

- (void)testSetTitleSetsTopicsViewControllersTitle
{
    XCTAssertEqual(self.viewController.topicsViewController.title, @"Foo");
    self.viewController.title = @"bar";
    XCTAssertEqual(self.viewController.topicsViewController.title, @"bar");
}

- (void)testInvalidateCacheInvalidatesArticleCache
{
    id topicsVcMock = OCMPartialMock(self.viewController.topicsViewController);
    
    OCMExpect([topicsVcMock invalidateArticleCache]);
    
    [self.viewController invalidateCache];
    
    OCMVerifyAll(topicsVcMock);
}

- (void)testCollapseSecondaryViewControllerChecksForArticleOnSecondaryViewController
{
    UIViewController *testVc = [UIViewController new];
    
    id mock = OCMPartialMock(self.viewController);
    OCMExpect([mock viewControllerStackHasArticle:testVc]);
    
    [self.viewController splitViewController:nil collapseSecondaryViewController:testVc ontoPrimaryViewController:nil];
    
    OCMVerifyAll(mock);
}

- (void)testSecondaryViewControllerCollapsesWhenNoArticle
{
    UINavigationController *testVc = [UINavigationController new];
    
    BOOL collapse = [self.viewController splitViewController:nil collapseSecondaryViewController:testVc ontoPrimaryViewController:nil];
    
    XCTAssertTrue(collapse);
}

- (void)testSecondaryViewControllerDoesntCollapseWhenArticleExists
{
    UINavigationController *navVc = [UINavigationController new];
    DKArticleDetailViewController *articleVc = [DKTestUtils articleDetailViewController];
    [articleVc setArticle:[DSAPIArticle new]];
    [navVc addChildViewController:articleVc];
    
    BOOL collapse = [self.viewController splitViewController:nil collapseSecondaryViewController:navVc ontoPrimaryViewController:nil];
    
    XCTAssertFalse(collapse);
}

- (void)testSeparateSecondaryViewControllerCallsSecondaryViewControllerForExpandingPrimaryViewController
{
    id mock = OCMPartialMock(self.viewController);
    OCMExpect([mock secondaryViewControllerForExpandingPrimaryViewController:nil]);
    
    [self.viewController splitViewController:nil separateSecondaryViewControllerFromPrimaryViewController:nil];
    
    OCMVerifyAll(mock);
}

- (void)testViewControllerStackHasArticleIsFalseForGenericViewControllers
{
    UIViewController *testVc = [UIViewController new];
    
    XCTAssertFalse([self.viewController viewControllerStackHasArticle:testVc]);
}

- (void)testViewControllerStackHasArticleIsFalseForViewControllerStackWithoutArticleDetailViewController
{
    UINavigationController *navVc = [UINavigationController new];
    UIViewController *testVc = [UIViewController new];
    [navVc addChildViewController:testVc];
    
    XCTAssertFalse([self.viewController viewControllerStackHasArticle:navVc]);
}

- (void)testArticleDetailViewControllerHasArticle
{
    DKArticleDetailViewController *articleVc = [DKArticleDetailViewController new];
    id mock = OCMPartialMock(articleVc);
    DSAPIArticle *article = [DSAPIArticle new];
    OCMStub([mock article]).andReturn(article);
    
    XCTAssertTrue([self.viewController articleDetailViewControllerHasArticle:articleVc]);
}

- (void)testArticleDetailViewControllerDoesntHaveArticle
{
    DKArticleDetailViewController *articleVc = [DKTestUtils articleDetailViewController];
    
    XCTAssertFalse([self.viewController articleDetailViewControllerHasArticle:articleVc]);
}

- (void)testViewControllerStackHasArticleCallsHelperMethodWhenArticleDetailViewControllerExists
{
    DKArticleDetailViewController *articleVc = [DKTestUtils articleDetailViewController];
    UINavigationController *navVc = [UINavigationController new];
    
    id navVcMock = OCMPartialMock(navVc);
    NSArray *viewControllers = @[articleVc];
    OCMExpect([navVcMock viewControllers]).andReturn(viewControllers);
    
    id mock = OCMPartialMock(self.viewController);
    
    [self.viewController viewControllerStackHasArticle:navVc];
    
    OCMVerify([mock articleDetailViewControllerHasArticle:articleVc]);
}

- (void)testViewControllerStackHasArticleCallsHelperMethodWhenArticleDetailViewControllerExistsInNestedNavVc
{
    DKArticleDetailViewController *articleVc = [DKTestUtils articleDetailViewController];
    UINavigationController *navVc = [UINavigationController new];
    UINavigationController *nestedNavVc = [UINavigationController new];
    
    id navVcMock = OCMPartialMock(navVc);
    NSArray *viewControllers = @[nestedNavVc];
    OCMExpect([navVcMock viewControllers]).andReturn(viewControllers);
    
    id nestedNavVcMock = OCMPartialMock(nestedNavVc);
    NSArray *nestedViewControllers = @[articleVc];
    OCMExpect([nestedNavVcMock viewControllers]).andReturn(nestedViewControllers);
    OCMExpect([nestedNavVcMock topViewController]).andReturn(articleVc);
    
    id mock = OCMPartialMock(self.viewController);
    
    [self.viewController viewControllerStackHasArticle:navVc];
    
    OCMVerify([mock articleDetailViewControllerHasArticle:articleVc]);
}

- (void)testSecondaryViewControllerIsEmptyViewControllerWhenNoArticle
{
    UIViewController *testVc = [UIViewController new];
    
    UIViewController *emptyVc = [self.viewController secondaryViewControllerForExpandingPrimaryViewController:testVc];
    
    XCTAssertTrue([emptyVc isKindOfClass:[DKEmptyViewController class]]);
}

- (void)testSecondaryViewControllerIsNilWhenArticleExists
{
    id mock = OCMPartialMock(self.viewController);
    OCMStub([mock viewControllerStackHasArticle:OCMOCK_ANY]).andReturn(YES);
    
    XCTAssertNil([self.viewController secondaryViewControllerForExpandingPrimaryViewController:nil]);
}

@end
*/