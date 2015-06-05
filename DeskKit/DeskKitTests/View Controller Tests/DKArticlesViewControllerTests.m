//
//  DKArticlesViewControllerTests.m
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
#import "DKTestUtils.h"
#import "DKArticlesTopicViewModel.h"
#import "DKArticlesSearchViewModel.h"
#import "UIAlertController+Additions.h"

@interface DKArticlesViewController ()

@property (nonatomic, weak) DKArticlesViewModel *viewModel;
@property (nonatomic, strong) DKArticlesTopicViewModel *topicViewModel;
@property (nonatomic, strong) DKArticlesSearchViewModel *searchViewModel;

- (void)setupSearchBar;
- (NSString *)searchBarPlaceholderText;
- (void)sendDelegateChangeSearchTerm:(NSString *)searchTerm;
- (void)resetSearchWithSearchTerm:(NSString *)searchTerm;
- (void)cancelSearchForArticlesInTopic;
- (BOOL)shouldShowNoSearchResultsMessage;
- (BOOL)userEnteredSearchTerms;
- (BOOL)hasTopic;

@end

@interface DKArticlesViewControllerTests : XCTestCase

@property (nonatomic, strong) DKArticlesViewController *viewController;
@property (nonatomic, strong) id viewControllerMock;
@property (nonatomic, strong) id topicViewModelMock;
@property (nonatomic, strong) id searchViewModelMock;

@end

@implementation DKArticlesViewControllerTests

- (void)setUp
{
    [super setUp];
    self.viewController = [DKTestUtils articlesViewController];
    [self.viewController view];
    self.topicViewModelMock = OCMPartialMock(self.viewController.viewModel);
    self.searchViewModelMock = OCMPartialMock(self.viewController.searchViewModel);
    self.viewControllerMock = OCMPartialMock(self.viewController);
}

- (void)testViewDidLoadSetsUpSearchBar
{
    OCMExpect([self.viewControllerMock setupSearchBar]);
    
    [self.viewController viewDidLoad];
    
    OCMVerifyAll(self.viewControllerMock);
}

- (void)testCellHasTopicName
{
    [self.viewController view];
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    DSAPIArticle *anyArticle = [DKFixtures articlesPage].entries.firstObject;
    
    OCMStub([self.topicViewModelMock itemAtIndexPath:firstIndexPath]).andReturn(anyArticle);
    
    UITableViewCell *cell = [self.viewController tableView:self.viewController.tableView cellForRowAtIndexPath:firstIndexPath];
    
    XCTAssertEqual(cell.textLabel.text, anyArticle[@"subject"]);
}

- (void)testSetTopicSetsViewModel
{
    DSAPITopic *topic = [DSAPITopic new];
    id mock = OCMPartialMock(topic);
    OCMStub([mock valueForKey:DKTopicNameKey]).andReturn(@"foo");
    [self.viewController setViewModel:self.viewController.topicViewModel topic:topic];
    XCTAssertEqual(self.viewController.topicViewModel.topic, topic);
    XCTAssertEqual(self.viewController.viewModel, self.viewController.topicViewModel);
    XCTAssertNotEqual(self.viewController.viewModel, self.viewController.searchViewModel);
    XCTAssertEqual(self.viewController.searchViewModel.topic, topic);
}

- (void)testSetSearchTermSetsViewModel
{
    NSString *searchTerm = @"foo";
    [self.viewController setSearchTerm:searchTerm];
    XCTAssertEqual(self.viewController.searchViewModel.searchTerm, searchTerm);
    XCTAssertEqual(self.viewController.viewModel, self.viewController.searchViewModel);
    XCTAssertNotEqual(self.viewController.viewModel, self.viewController.topicViewModel);
}

- (void)testDidChangeSearchTerm
{
    id delegate = OCMProtocolMock(@protocol(DKArticlesViewControllerDelegate));
    self.viewController.delegate = delegate;
    NSString *searchTerm = @"foo";
    
    OCMExpect([delegate articlesViewController:self.viewController didChangeSearchTerm:searchTerm]);
    
    UISearchBar *searchBar = [UISearchBar new];
    searchBar.text = searchTerm;
    
    [self.viewController searchBarSearchButtonClicked:searchBar];
    
    OCMVerifyAll(delegate);
}

- (void)testDidSelectArticle
{
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    DSAPITopic *topic = [DKFixtures topicsPage].entries.firstObject;
    DSAPIArticle *article = [DKFixtures article];
    id viewModelMock = OCMClassMock([DKArticlesTopicViewModel class]);
    OCMStub([viewModelMock itemAtIndexPath:firstIndexPath]).andReturn(article);

    [self.viewController setViewModel:viewModelMock topic:topic];
    
    id delegate = OCMProtocolMock(@protocol(DKArticlesViewControllerDelegate));
    self.viewController.delegate = delegate;
    OCMExpect([delegate articlesViewController:self.viewController didSelectArticle:article]);
    
    [self.viewController.tableView.delegate tableView:self.viewController.tableView didSelectRowAtIndexPath:firstIndexPath];
    
    OCMVerifyAll(delegate);
}

- (void)testDoesntShowAlertWhenNoResultsAndNoSearchTerm
{
    id AlertControllerClassMock = OCMClassMock([UIAlertController class]);
    [[AlertControllerClassMock reject] alertWithTitle:OCMOCK_ANY text:OCMOCK_ANY handler:OCMOCK_ANY];
    [[self.viewControllerMock reject] presentViewController:OCMOCK_ANY animated:YES completion:nil];
    
    [self.viewController viewModelDidFetchNoResults:nil];
    
    OCMVerifyAll(AlertControllerClassMock);
    OCMVerifyAll(self.viewControllerMock);
}

- (void)testShowsAlertWhenNoResultsAndSearchTerm
{
    self.viewController.searchViewModel.searchTerm = @"foo";
    id tableViewMock = OCMPartialMock(self.viewController.tableView);
    OCMExpect([tableViewMock reloadData]);
    
    id AlertControllerClassMock = OCMClassMock([UIAlertController class]);
    OCMExpect([AlertControllerClassMock alertWithTitle:OCMOCK_ANY text:OCMOCK_ANY handler:OCMOCK_ANY]);
    OCMExpect([self.viewControllerMock presentViewController:OCMOCK_ANY animated:YES completion:nil]);
    
    [self.viewController viewModelDidFetchNoResults:nil];
    
    OCMVerifyAll(tableViewMock);
    OCMVerifyAll(AlertControllerClassMock);
    OCMVerifyAll(self.viewControllerMock);
}

- (void)testShouldShowNoSearchResultsMessage
{
    OCMStub([self.viewControllerMock userEnteredSearchTerms]).andReturn(YES);
    
    XCTAssertTrue([self.viewController shouldShowNoSearchResultsMessage]);
}

- (void)testShouldNotShowNoSearchResultsMessage
{
    OCMStub([self.viewControllerMock userEnteredSearchTerms]).andReturn(NO);
    
    XCTAssertFalse([self.viewController shouldShowNoSearchResultsMessage]);
}

- (void)testUserEnteredSearchTerms
{
    self.viewController.searchViewModel.searchTerm = @"foo";
    
    XCTAssertTrue([self.viewController userEnteredSearchTerms]);
}

- (void)testUserDidNotEnterSearchTerms
{
    self.viewController.searchViewModel.searchTerm = nil;
    
    XCTAssertFalse([self.viewController userEnteredSearchTerms]);
}

- (void)testResetSearchWithSearchTerm
{
    OCMExpect([self.searchViewModelMock reset]);
    OCMExpect([self.viewControllerMock setSearchTerm:@"foo"]);
    OCMExpect([self.viewControllerMock beginLoadingData]);
    
    [self.viewController resetSearchWithSearchTerm:@"foo"];
    
    OCMVerifyAll(self.searchViewModelMock);
    OCMVerifyAll(self.viewControllerMock);
}

- (void)testCancelSearchBar
{
    id mock = OCMPartialMock(self.viewController.tableView);
    [self.viewController cancelSearchForArticlesInTopic];
    
    OCMVerify([mock reloadData]);
    OCMVerify([self.viewControllerMock setViewModel:OCMOCK_ANY topic:OCMOCK_ANY]);
}

- (void)testHasTopic
{
    DKArticlesTopicViewModel *viewModel = [DKArticlesTopicViewModel new];
    viewModel.topic = nil;
    
    OCMStub([self.viewControllerMock topicViewModel]).andReturn(viewModel);
    
    XCTAssertFalse(self.viewController.hasTopic);
    
    viewModel.topic = [DSAPITopic new];
    XCTAssertTrue(self.viewController.hasTopic);
}

- (void)testSearchBarPlaceholderText
{
    self.viewController.topicViewModel.topic = nil;
    XCTAssertTrue([self.viewController.searchBarPlaceholderText isEqualToString:DKSearchAllArticles]);
    
    self.viewController.topicViewModel.topic = [DSAPITopic new];
    XCTAssertTrue([self.viewController.searchBarPlaceholderText isEqualToString:DKSearchArticlesInTopic]);
}

@end
