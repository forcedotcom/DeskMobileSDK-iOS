//
//  DKAPIManagerTests.m
//  DeskKit
//
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
#import "DKAPIManager.h"
#import "DKTestUtils.h"
#import <DeskCommon/DeskCommon.h>

@interface DKAPIManagerTests : XCTestCase

@property (nonatomic, strong) DKAPIManager *manager;
@property (nonatomic) NSOperationQueue *APICallbackQueue;

@end

@implementation DKAPIManagerTests

- (void)setUp
{
    [super setUp];
    self.manager = [DKTestUtils authorizedAPIManager];
    self.APICallbackQueue = [NSOperationQueue new];
}

- (void)testCanAuthorizeAPI {
    XCTestExpectation *apiSuccessExpectation = [self expectationWithDescription:@"Makes an api call"];
    
    [DSAPIArticle listArticlesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [apiSuccessExpectation fulfill];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        XCTFail(@"Received error: %@ on response %@", error, response);
        [apiSuccessExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:DKDefaultTestTimeout handler:nil];
}

- (void)testHasClient
{
    XCTAssertTrue(self.manager.hasClient);
}

- (void)testContactUsURL
{
    NSURL *url = [self.manager contactUsWebFormURL];
    DSAPIClient *client = [self.manager performSelector:@selector(client)];
    XCTAssertTrue([url.absoluteString hasPrefix:client.baseURL.absoluteString]);
    XCTAssertTrue([url.absoluteString hasSuffix:@"/customer/portal/emails/new"]);
}

@end
