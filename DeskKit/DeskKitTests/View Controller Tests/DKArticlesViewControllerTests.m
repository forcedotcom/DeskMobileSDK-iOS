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

@property (nonatomic) DKArticlesTopicViewModel *viewModel;
@property (nonatomic) UISearchController *searchController;

- (void)setupSearch;
- (NSString *)searchBarPlaceholderText;
- (void)sendDelegateChangeSearchTerm:(NSString *)searchTerm;
- (void)resetSearchWithSearchTerm:(NSString *)searchTerm;
- (void)cancelSearchForArticlesInTopic;
- (BOOL)shouldShowNoSearchResultsMessage;
- (BOOL)hasTopic;

@end

@interface DKArticlesViewControllerTests : XCTestCase

@property (nonatomic, strong) DKArticlesViewController *viewController;
@property (nonatomic, strong) id viewControllerMock;
@property (nonatomic, strong) id topicViewModelMock;

@end

@implementation DKArticlesViewControllerTests

- (void)setUp
{
    [super setUp];
    self.viewController = [DKTestUtils articlesViewController];
    [self.viewController view];
    self.topicViewModelMock = OCMPartialMock(self.viewController.viewModel);
    self.viewControllerMock = OCMPartialMock(self.viewController);
}

- (void)testViewDidLoadSetsUpSearchBar
{
    OCMExpect([self.viewControllerMock setupSearch]);
    
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
    [self.viewController setViewModel:self.viewController.viewModel topic:topic];
    XCTAssertEqual(self.viewController.viewModel.topic, topic);
}

- (void)testDidChangeSearchTerm
{
    id delegate = OCMProtocolMock(@protocol(DKArticlesViewControllerDelegate));
    self.viewController.delegate = delegate;
    NSString *searchTerm = @"foo";
    
    OCMExpect([delegate articlesViewController:self.viewController didSearchTerm:searchTerm]);
    
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

- (void)testHasTopic
{
    DKArticlesTopicViewModel *viewModel = [DKArticlesTopicViewModel new];
    viewModel.topic = nil;
    
    OCMStub([self.viewControllerMock viewModel]).andReturn(viewModel);
    
    XCTAssertFalse(self.viewController.hasTopic);
    
    viewModel.topic = [DSAPITopic new];
    XCTAssertTrue(self.viewController.hasTopic);
}

- (void)testSearchBarPlaceholderText
{
    [self.viewController setupSearch];
    XCTAssertTrue([self.viewController.searchController.searchBar.placeholder isEqualToString:DKSearchArticlesInTopic]);
}

@end
