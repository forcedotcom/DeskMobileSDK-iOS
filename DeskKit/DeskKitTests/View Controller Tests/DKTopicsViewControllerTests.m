//
//  DKTopicsViewControllerTests.m
//  DeskKit
//
//  Created by Desk.com on 9/19/14.
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
#import <MessageUI/MessageUI.h>
#import "DKTestUtils.h"
#import "DKArticlesTopicViewModel.h"

@interface MFMailComposeViewControllerTest : UIViewController

- (void)setMailComposeDelegate:(id<MFMailComposeViewControllerDelegate>)delegate;
- (void)setToRecipients:(NSArray *)toRecipients;

@end

@implementation MFMailComposeViewControllerTest

- (void)setMailComposeDelegate:(id<MFMailComposeViewControllerDelegate>)delegate
{
    // noop
}

- (void)setToRecipients:(NSArray *)toRecipients
{
    // noop
}

@end

@interface DKTopicsViewController ()

@property (nonatomic, strong) NSMutableDictionary *cachedArticlesViewModels;
@property (nonatomic, weak) IBOutlet UIButton *contactUsButton;
@property (nonatomic, weak) IBOutlet UIView *contactUsContainerView;
@property (nonatomic, strong) UISearchController *searchController;

- (void)setupAppearances;
- (void)setupSearch;
- (void)setupContactUsSheet;
- (void)setTopicOnArticlesViewController:(DKArticlesViewController *)viewController
                                    cell:(UITableViewCell *)cell;
- (void)setArticlesViewModelOnArticlesViewController:(DKArticlesViewController *)viewController
                                           topicName:(id)topicName;
- (DKArticlesTopicViewModel *)cachedArticlesViewModelFromTopicName:(id)topicName;
- (void)setCachedArticlesViewModel:(DKArticlesTopicViewModel *)articleViewModel topicName:(id)topicName;
- (void)openActionSheet;
- (IBAction)doneButtonTapped:(id)sender;
- (IBAction)contactUsButtonTapped:(id)sender;
- (void)openMailComposeViewController;
- (void)showMailAlertWithResult:(MFMailComposeResult)result error:(NSError *)error;

@end

@interface DKTopicsViewControllerTests : XCTestCase

@property (nonatomic, strong) DKTopicsViewController *viewController;
@property (nonatomic, strong) id mock;
@property (nonatomic, strong) id viewModelMock;
@property (nonatomic, strong) DKSession *testSession;

@end

@implementation DKTopicsViewControllerTests

- (void)setUp
{
    [super setUp];
    self.viewController = [DKTestUtils topicsViewController];
    [self.viewController view];
    self.viewModelMock = OCMPartialMock(self.viewController.viewModel);
    self.mock = OCMPartialMock(self.viewController);
    self.testSession = [[DKSession alloc] init];
}

- (void)testCellHasTopicName
{
    [self.viewController view];
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    DSAPITopic *anyTopic = [DKFixtures topicsPage].entries.firstObject;

    OCMStub([self.viewModelMock itemAtIndexPath:firstIndexPath]).andReturn(anyTopic);

    UITableViewCell *cell = [self.viewController tableView:self.viewController.tableView cellForRowAtIndexPath:firstIndexPath];

    XCTAssertEqual(cell.textLabel.text, anyTopic[@"name"]);
}

- (void)testDidSelectTopic
{
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    DSAPITopic *topic = [DKFixtures topicsPage].entries.firstObject;
    OCMStub([self.viewModelMock itemAtIndexPath:firstIndexPath]).andReturn(topic);
    DKArticlesTopicViewModel *articlesViewModel = [DKArticlesTopicViewModel new];
    articlesViewModel.topic = topic;

    id delegate = OCMProtocolMock(@protocol(DKTopicsViewControllerDelegte));
    self.viewController.delegate = delegate;
    OCMExpect([delegate topicsViewController:self.viewController
                              didSelectTopic:topic
                      articlesTopicViewModel:[OCMArg isNotNil]]);
    
    [self.viewController.tableView.delegate tableView:self.viewController.tableView didSelectRowAtIndexPath:firstIndexPath];
  
    OCMVerifyAll(delegate);
}

- (void)testCacheMiss
{
    DSAPITopic *topic = [DKFixtures topicsPage].entries.firstObject;
    id topicName = [topic valueForKey:DKTopicNameKey];
    XCTAssertNil([self.viewController cachedArticlesViewModelFromTopicName:topicName]);
}

- (void)testCacheHit
{
    DKArticlesTopicViewModel *viewModel = [DKArticlesTopicViewModel new];
    viewModel.topic = [DKFixtures topicsPage].entries.firstObject;
    id topicName = [viewModel.topic valueForKey:DKTopicNameKey];
    XCTAssertNil([self.viewController cachedArticlesViewModelFromTopicName:topicName]);

    [self.viewController setCachedArticlesViewModel:viewModel topicName:topicName];
    XCTAssertNotNil([self.viewController cachedArticlesViewModelFromTopicName:topicName]);
}

- (void)testViewDidLoadInvalidatesArticleCache
{
    OCMExpect([self.mock invalidateArticleCache]);

    [self.viewController viewDidLoad];

    OCMVerifyAll(self.mock);
}

- (void)testViewDidLoadCallsSetupAppearances
{
    OCMExpect([self.mock setupAppearances]);

    [self.viewController viewDidLoad];

    OCMVerifyAll(self.mock);
}

- (void)testViewDidLoadSetsUpSearchBar
{
    OCMExpect([self.mock setupSearch]);

    [self.viewController viewDidLoad];

    OCMVerifyAll(self.mock);
}

- (void)testSearchButtonClicked
{
    id tableViewMock = OCMPartialMock(self.viewController.tableView);
    id articleSearchControllerMock = OCMPartialMock(self.viewController.searchController);
    id delegate = OCMProtocolMock(@protocol(DKTopicsViewControllerDelegte));
    self.viewController.delegate = delegate;
    NSString *searchTerm = @"foo";
    
    OCMExpect([tableViewMock deselectRowAtIndexPath:OCMOCK_ANY animated:YES]);
    OCMExpect([delegate topicsViewController:self.viewController didSearchTerm:searchTerm]);
    
    UISearchBar *searchBar = [UISearchBar new];
    searchBar.text = searchTerm;
    
    [self.viewController searchBarSearchButtonClicked:searchBar];
    
    OCMVerifyAll(tableViewMock);
    OCMVerifyAll(articleSearchControllerMock);
    OCMVerifyAll(delegate);
}

@end
