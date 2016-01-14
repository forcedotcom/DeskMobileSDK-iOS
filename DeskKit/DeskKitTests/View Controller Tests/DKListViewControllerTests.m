//
//  DKListViewControllerTests.m
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DKTestUtils.h"
#import "UIAlertController+Additions.h"

@interface DKListViewController ()

@property (nonatomic) UISearchController *searchController;

@end

@interface DKListViewControllerTests : XCTestCase

@property (nonatomic, strong) DKListViewController *viewController;
@property (nonatomic, strong) id mock;
@property (nonatomic, strong) id viewModelMock;

@end

@implementation DKListViewControllerTests

- (void)setUp
{
    [super setUp];
    self.viewController = [DKTestUtils topicsViewController];
    self.mock = OCMPartialMock(self.viewController);
    self.viewModelMock = OCMPartialMock(self.viewController.viewModel);
}

- (void)testBeginLoadingData
{
    [self.viewController beginLoadingData];
    
    OCMVerify([self.viewModelMock fetchItemsInSection:0]);
}

- (void)testNumberOfSectionsInTableViewCallsViewModel
{
    OCMExpect([self.viewModelMock totalPages]);
    
    [self.viewController numberOfSectionsInTableView:nil];
    
    OCMVerifyAll(self.viewModelMock);
}

- (void)testNumberOfItemsInTableViewCallsViewModel
{
    OCMExpect([self.viewModelMock numberOfItemsInSection:0]);
    
    [self.viewController tableView:nil numberOfRowsInSection:0];
    
    OCMVerifyAll(self.viewModelMock);
}

- (void)testWillDisplayCellDoesntFetchPageOnFirstRow
{
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [[self.viewModelMock reject] fetchItemsInSection:0];
    
    [self.viewController tableView:nil willDisplayCell:nil forRowAtIndexPath:firstIndexPath];
    
    OCMVerifyAll(self.viewModelMock);
}

- (void)testWillDisplayCellFetchesNextPageOnMiddleRow
{
    NSIndexPath *middleIndexPath = [NSIndexPath indexPathForRow:50 inSection:0];
    // Need this ugly workaround due to a limitation in how OCMock handles 32 vs. 64-bit integers
    OCMStub([self.viewModelMock numberOfItemsInSection:0]).andReturn([@(100) integerValue]);
    
    [[self.viewModelMock expect] fetchItemsInSection:1];
    
    [self.viewController tableView:nil willDisplayCell:nil forRowAtIndexPath:middleIndexPath];
    
    OCMVerifyAll(self.viewModelMock);
}

- (void)testDidFetchPageReloadsTableView
{
    [self.viewController view];
    id tableViewMock = OCMPartialMock(self.viewController.tableView);
    
    OCMExpect([tableViewMock reloadData]);
    
    [self.viewController viewModel:nil didFetchPage:nil];
    
    OCMVerifyAll(tableViewMock);
}

- (void)testFetchFailedShowsAlert
{
    id AlertControllerClassMock = OCMClassMock([UIAlertController class]);
    OCMExpect([AlertControllerClassMock alertWithTitle:OCMOCK_ANY text:OCMOCK_ANY]);
    OCMExpect([self.mock presentViewController:OCMOCK_ANY animated:YES completion:nil]);
    
    [self.viewController viewModel:nil fetchDidFailOnPageNumber:@1];
    
    OCMVerifyAll(AlertControllerClassMock);
    OCMVerifyAll(self.mock);
}

- (void)testSetupSearchBar
{
    [self.viewController view];
    [self.viewController setSearchBarPlaceholder:@"Foo"];
    XCTAssertNotNil(self.viewController.searchController);
    XCTAssertTrue([self.viewController.searchController.searchBar.delegate isEqual:self.viewController]);
    XCTAssertTrue([self.viewController.searchController.searchBar.placeholder isEqualToString:@"Foo"]);
    XCTAssertEqual(self.viewController.tableView.tableHeaderView, self.viewController.searchController.searchBar);
}

@end
