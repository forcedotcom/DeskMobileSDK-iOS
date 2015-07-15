//
//  DKListViewModelTests.m
//  DeskKit
//
//  Created by Desk.com on 9/11/14.
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
#import "DKListViewModel.h"
#import "DKTestUtils.h"

@interface DKListViewModel()

@property (nonatomic) NSNumber *totalItems;
@property (nonatomic, strong) NSMutableDictionary *loadedPages;

- (BOOL)shouldFetchItemsOnPageNumber:(NSNumber *)pageNumber;
- (BOOL)alreadyLoadedItemsOnPageNumber:(NSNumber *)pageNumber;
- (BOOL)pageNumberIsFetchable:(NSNumber *)pageNumber;
- (void)handleLoadedItemsOnPage:(DSAPIPage *)page;
- (void)sendWillFetchPageNumber:(NSNumber *)pageNumber;
- (void)sendDidFetchPage:(DSAPIPage *)page;
- (void)sendNoResults;
- (DSAPIPage *)loadedPageAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)pageNumberFromSection:(NSInteger)section;
- (NSInteger)sectionFromPageNumber:(NSInteger)pageNumber;

@end

@interface DKListViewModelTests : XCTestCase

@property (nonatomic) NSOperationQueue *APICallbackQueue;

@end

@implementation DKListViewModelTests

- (void)setUp
{
    [super setUp];
    self.APICallbackQueue = [NSOperationQueue new];
}

- (void)testLoadsItemsWhenSessionIsStarted
{
    DKListViewModel *viewModel = [DKListViewModel new];
    id mock = OCMPartialMock(viewModel);
    
    id sessionMock = OCMClassMock([DKSession class]);
    OCMStub([sessionMock isSessionStarted]).andReturn(YES);
    
    OCMExpect([mock fetchItemsOnPageNumber:@1 perPage:@(DKItemsPerPage) queue:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY]);
    
    [viewModel fetchItemsInSection:0];
    
    OCMVerifyAll(mock);
}

- (void)testReset
{
    DKListViewModel *viewModel = [DKListViewModel new];
    
    [viewModel reset];
    XCTAssertTrue([viewModel.loadedPages isEqual:@{}]);
    XCTAssertEqual(viewModel.totalItems, @0);
}

- (void)testShouldFetchItemsOnPageOne
{
    DKListViewModel *viewModel = [DKListViewModel new];
    id viewModelMock = OCMPartialMock(viewModel);
    
    OCMStub([viewModelMock alreadyLoadedItemsOnPageNumber:@(1)]).andReturn(NO);
    OCMStub([viewModelMock totalPages]).andReturn([@(0) integerValue]);
    
    XCTAssertTrue([viewModel shouldFetchItemsOnPageNumber:@(1)]);
    XCTAssertFalse([viewModel shouldFetchItemsOnPageNumber:@(2)]);
}

- (void)testShouldFetchItemsOnPageTwo
{
    DKListViewModel *viewModel = [DKListViewModel new];
    id viewModelMock = OCMPartialMock(viewModel);
    
    NSInteger totalPages = 2;
    OCMStub([viewModelMock totalPages]).andReturn(totalPages);
    OCMStub([viewModelMock alreadyLoadedItemsOnPageNumber:@(1)]).andReturn(YES);
    OCMStub([viewModelMock alreadyLoadedItemsOnPageNumber:@(2)]).andReturn(NO);
    
    XCTAssertFalse([viewModel shouldFetchItemsOnPageNumber:@(1)]);
    XCTAssertTrue([viewModel shouldFetchItemsOnPageNumber:@(2)]);
    
    XCTAssertFalse([viewModel shouldFetchItemsOnPageNumber:@(totalPages + 1)]);
}

- (void)testFetchesItemsOnPageNumber
{
    DKListViewModel *viewModel = [DKListViewModel new];
    id mock = OCMPartialMock(viewModel);
    
    id SessionClassMock = OCMClassMock([DKSession class]);
    OCMStub([SessionClassMock isSessionStarted]).andReturn(YES);
    OCMStub([mock shouldFetchItemsOnPageNumber:@(1)]).andReturn(YES);
    
    OCMExpect([mock fetchItemsOnPageNumber:@(1) perPage:OCMOCK_ANY queue:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY]);
    
    [viewModel fetchItemsInSection:0];
    
    OCMVerifyAll(mock);
}

- (void)testFetchItemsInSectionNotifiesDelegate
{
    DKListViewModel *viewModel = [DKListViewModel new];
    id mock = OCMPartialMock(viewModel);
    
    id SessionClassMock = OCMClassMock([DKSession class]);
    OCMStub([SessionClassMock isSessionStarted]).andReturn(YES);
    OCMStub([mock shouldFetchItemsOnPageNumber:@(1)]).andReturn(YES);
    
    OCMExpect([mock sendWillFetchPageNumber:@(1)]);
    
    [viewModel fetchItemsInSection:0];
    
    OCMVerifyAll(mock);
}

- (void)testAlreadyLoadedItemsOnPageNumber
{
    DKListViewModel *viewModel = [DKListViewModel new];
    
    XCTAssertFalse([viewModel alreadyLoadedItemsOnPageNumber:@(1)]);
    
    [viewModel handleLoadedItemsOnPage:[DKFixtures topicsPage]];
    
    XCTAssertTrue([viewModel alreadyLoadedItemsOnPageNumber:@(1)]);
    XCTAssertFalse([viewModel alreadyLoadedItemsOnPageNumber:@(2)]);
}

- (void)testPageNumberIsFetchable
{
    DKListViewModel *viewModel = [DKListViewModel new];
    
    DSAPIPage *topicsPage = [DKFixtures topicsPage];
    [viewModel handleLoadedItemsOnPage:topicsPage];
    XCTAssertFalse([viewModel pageNumberIsFetchable:@(-1)]);
    XCTAssertFalse([viewModel pageNumberIsFetchable:@(0)]);
    XCTAssertTrue([viewModel pageNumberIsFetchable:@(1)]);
    XCTAssertTrue([viewModel pageNumberIsFetchable:@(2)]);
    XCTAssertTrue([viewModel pageNumberIsFetchable:@(3)]);
    
    NSInteger pageNumberBeyondTotalEntries = 2 + topicsPage.totalEntries.integerValue/DKItemsPerPage;
    XCTAssertFalse([viewModel pageNumberIsFetchable:@(pageNumberBeyondTotalEntries)]);
}

- (void)testDoesntLoadItemsWhenSessionIsntStarted
{
    DKListViewModel *viewModel = [DKListViewModel new];
    id mock = OCMPartialMock(viewModel);
    
    id sessionMock = OCMClassMock([DKSession class]);
    OCMStub([sessionMock isSessionStarted]).andReturn(NO);
    
    [[mock reject] fetchItemsOnPageNumber:@1 perPage:@100 queue:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    [viewModel fetchItemsInSection:0];
    
    OCMVerifyAll(mock);
}

- (void)testHandleLoadedItems
{
    DKListViewModel *viewModel = [DKListViewModel new];
    id mock = OCMPartialMock(viewModel);
    
    XCTAssertEqual(viewModel.totalItems, @0);
    OCMExpect([mock sendDidFetchPage:OCMOCK_ANY]);
    
    DSAPIPage *page = [DKFixtures topicsPage];
    [viewModel handleLoadedItemsOnPage:page];
    
    XCTAssertEqual(viewModel.totalItems, page.totalEntries);
    XCTAssertEqual([viewModel.loadedPages objectForKey:@(page.pageNumber)], page);
    
    OCMVerifyAll(mock);
}

- (void)testHandleLoadedItemsWhenNoResults
{
    DKListViewModel *viewModel = [DKListViewModel new];
    id mock = OCMPartialMock(viewModel);
    
    OCMExpect([mock sendNoResults]);
    
    [viewModel handleLoadedItemsOnPage:[DSAPIPage new]];
    
    OCMVerifyAll(mock);
}

- (void)testTotalPages
{
    DKListViewModel *viewModel = [DKListViewModel new];
    
    DSAPIPage *page = [DKFixtures topicsPage];
    [viewModel handleLoadedItemsOnPage:page];
    
    // Fixture has 201 entries, so should be 1 + (total entries / items per page)
    XCTAssertEqual([viewModel numberOfItemsInSection:0], DKItemsPerPage);
    XCTAssertEqual(viewModel.totalPages, 1 + page.totalEntries.integerValue/DKItemsPerPage);
}

- (void)testItemAtIndexPathIsNilBeforeLoading
{
    DKListViewModel *viewModel = [DKListViewModel new];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    XCTAssertNil([viewModel itemAtIndexPath:indexPath]);
}

- (void)testItemAtIndexPathIsNotNilAfterLoading
{
    DKListViewModel *viewModel = [DKListViewModel new];
    
    DSAPIPage *page = [DKFixtures topicsPage];
    [viewModel handleLoadedItemsOnPage:page];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    XCTAssertNotNil([viewModel itemAtIndexPath:indexPath]);
}

- (void)testLoadedPageAtIndexPath
{
    DKListViewModel *viewModel = [DKListViewModel new];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    XCTAssertNil([viewModel loadedPageAtIndexPath:indexPath]);
    
    DSAPIPage *page = [DKFixtures topicsPage];
    [viewModel handleLoadedItemsOnPage:page];
    
    XCTAssertEqual([viewModel loadedPageAtIndexPath:indexPath], page);
}

- (void)testPageNumberFromIndexPath
{
    DKListViewModel *viewModel = [DKListViewModel new];
    
    NSIndexPath *firstPageIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    NSInteger pageNumber = [viewModel pageNumberFromSection:firstPageIndexPath.section];
    XCTAssertEqual(pageNumber, 1);
    
    NSIndexPath *secondPageIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    pageNumber = [viewModel pageNumberFromSection:secondPageIndexPath.section];
    XCTAssertEqual(pageNumber, 2);
}

@end
