//
//  DKArticlesSearchViewModelTests.m
//  DeskKit
//
//  Created by Desk.com on 10/2/14.
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
#import "DKArticlesSearchViewModel.h"

@interface DKArticlesSearchViewModel ()

@end

@interface DKArticlesSearchViewModelTests : XCTestCase

@property (nonatomic, strong) DKArticlesSearchViewModel *viewModel;
@property (nonatomic, strong) id mock;
@property (nonatomic) NSOperationQueue *APICallbackQueue;

@end

@implementation DKArticlesSearchViewModelTests

- (void)setUp
{
    [super setUp];
    self.viewModel = [DKArticlesSearchViewModel new];
    self.viewModel.searchTerm = @"foo";
    self.mock = OCMPartialMock(self.viewModel);
    self.APICallbackQueue = [NSOperationQueue new];
}

- (void)testParameters
{
    NSDictionary *parameters = @{ kPageKey : @1,
                                  kPerPageKey : @100,
                                  @"text" : self.viewModel.searchTerm,
                                  DKFieldsKey : [self fields],
                                  DKArticlePrivateSearchKey : @NO };

    XCTAssertTrue([parameters isEqual:[self.viewModel parametersForPageNumber:@1 perPage:@100]]);
}

- (void)testParametersWithTopic
{
    self.viewModel.topic = [DKFixtures topicsPage].entries.firstObject;

    NSDictionary *parameters = @{ kPageKey : @1,
                                  kPerPageKey : @100,
                                  @"text" : self.viewModel.searchTerm,
                                  DKTopicIdsKey : [self.viewModel.topic valueForKey:DKTopicIdKey],
                                  DKFieldsKey : [self fields],
                                  DKArticlePrivateSearchKey : @NO };

    XCTAssertTrue([parameters isEqual:[self.viewModel parametersForPageNumber:@1 perPage:@100]]);
}

- (void)testParametersWithBrandIdAdded
{
    DSAPIBrand *brand = (DSAPIBrand *)[DSAPIResource resourceWithId:@"1234"
                                                          className:@"brand"];

    OCMStub([self.mock shouldAddBrandContext]).andReturn(YES);
    OCMStub([self.mock brand]).andReturn(brand);

    NSDictionary *parameters = [self.viewModel parametersForPageNumber:@1 perPage:@(DKItemsPerPage)];
    NSString *brandIds = [parameters objectForKey:DKBrandIdsKey];
    XCTAssertTrue([brandIds isEqual:@"1234"]);
}

- (void)testFetchItemsAtIndexPath
{
    id ArticleClassMock = OCMClassMock([DSAPIArticle class]);

    NSDictionary *params = [self.viewModel parametersForPageNumber:@1 perPage:@100];
    OCMExpect([ArticleClassMock searchArticlesWithParameters:params queue:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY]);

    [self.viewModel fetchItemsOnPageNumber:@1 perPage:@100 queue:self.APICallbackQueue success:nil failure:nil];

    OCMVerifyAll(ArticleClassMock);
}

- (void)testTextForDisplay
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    DSAPIArticle *article = [DKFixtures articlesPage].entries.firstObject;

    OCMStub([self.mock itemAtIndexPath:indexPath]).andReturn(article);

    XCTAssertEqual([self.mock textForDisplayAtIndexPath:indexPath], [article valueForKey:DKArticleSubjectKey]);
}

- (NSString *)fields
{
    return [NSString stringWithFormat:@"%@,%@", DKArticleSubjectKey, DKArticlePublicURLKey];
}

@end
