//
//  DKSearchResultsViewControllerTests.m
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

#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "DKSearchResultsViewController.h"
#import "DKArticlesSearchViewModel.h"

#import "DKTestUtils.h"
#import "UIAlertController+Additions.h"

@interface DKSearchResultsViewController ()

@property (nonatomic) DKArticlesSearchViewModel *viewModel;

- (BOOL)hasSearchTerm;
- (BOOL)shouldShowNoSearchResultsMessage;
- (void)setSearchTerm:(NSString *)searchTerm topic:(DSAPITopic *)topic;

@end

@interface DKSearchResultsViewControllerTests : XCTestCase

@property (nonatomic) DKSearchResultsViewController *viewController;
@property (nonatomic, strong) id viewControllerMock;
@property (nonatomic, strong) id searchViewModelMock;

@end

@implementation DKSearchResultsViewControllerTests

- (void)setUp {
    [super setUp];
    self.viewController = [DKTestUtils searchResultsViewController];
    [self.viewController view];
    self.viewControllerMock = OCMPartialMock(self.viewController);
    self.searchViewModelMock = OCMPartialMock(self.viewController.viewModel);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSetSearchTermSetsViewModel
{
    NSString *searchTerm = @"foo";
    [self.viewController resetSearchWithSearchTerm:searchTerm topic:nil];
    XCTAssertEqual(self.viewController.viewModel.searchTerm, searchTerm);
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
    self.viewController.viewModel.searchTerm = @"foo";
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
    OCMStub([self.viewControllerMock hasSearchTerm]).andReturn(YES);
    
    XCTAssertTrue([self.viewController shouldShowNoSearchResultsMessage]);
}

- (void)testShouldNotShowNoSearchResultsMessage
{
    OCMStub([self.viewControllerMock hasSearchTerm]).andReturn(NO);
    
    XCTAssertFalse([self.viewController shouldShowNoSearchResultsMessage]);
}

- (void)testUserEnteredSearchTerms
{
    self.viewController.viewModel.searchTerm = @"foo";
    
    XCTAssertTrue([self.viewController hasSearchTerm]);
}

- (void)testUserDidNotEnterSearchTerms
{
    self.viewController.viewModel.searchTerm = nil;
    
    XCTAssertFalse([self.viewController hasSearchTerm]);
}

- (void)testResetSearchWithSearchTerm
{
    OCMExpect([self.searchViewModelMock reset]);
    OCMExpect([self.viewControllerMock setSearchTerm:@"foo" topic:nil]);
    OCMExpect([self.viewControllerMock beginLoadingData]);
    
    [self.viewController resetSearchWithSearchTerm:@"foo" topic:nil];
    
    OCMVerifyAll(self.searchViewModelMock);
    OCMVerifyAll(self.viewControllerMock);
}

@end
