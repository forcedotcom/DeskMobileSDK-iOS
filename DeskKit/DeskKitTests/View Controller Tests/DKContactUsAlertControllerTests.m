//
//  DKContactUsAlertControllerTests.m
//  DeskKit
//
//  Created by Desk.com on 9/29/14.
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
#import "DKContactUsAlertController.h"

@interface DKContactUsAlertController ()

@property (nonatomic) BOOL hasEmailUsAction;

- (void)addCancelButton;
- (void)addCallUsButton;
- (void)addCallUsAction;
- (void)addEmailUsButton;
- (void)addEmailUsAction;

@end

@interface DKContactUsAlertControllerTests : XCTestCase

@property (nonatomic, strong) DKContactUsAlertController *contactUs;
@property (nonatomic, strong) id mock;

@end

@implementation DKContactUsAlertControllerTests

- (void)setUp
{
    [super setUp];
    self.contactUs = [DKContactUsAlertController contactUsAlertController];
    self.mock = OCMPartialMock(self.contactUs);
}

- (void)testAlertControllerInstantiation
{
    id sessionMock = OCMPartialMock([DKSession sharedInstance]);
    OCMStub([sessionMock hasContactUsPhoneNumber]).andReturn(YES);
    
    self.contactUs = [DKContactUsAlertController contactUsAlertController];
    XCTAssertTrue([self.contactUs.title isEqualToString:@"Contact Us"]);
    XCTAssertEqual(self.contactUs.actions.count, 2);
}

- (void)testDoesntAddCallUsButtonIfSessionHasNoPhone
{
    id sessionMock = OCMPartialMock([DKSession sharedInstance]);
    OCMStub([sessionMock hasContactUsPhoneNumber]).andReturn(NO);
    
    [[self.mock reject] addCallUsAction];
    [self.contactUs addCallUsButton];
    
    OCMVerifyAll(self.mock);
}

- (void)testAddsCallUsButtonIfSessionHasPhone
{
    id sessionMock = OCMPartialMock([DKSession sharedInstance]);
    OCMStub([sessionMock hasContactUsPhoneNumber]).andReturn(YES);
    
    OCMExpect([self.mock addAction:OCMOCK_ANY]);
    
    [self.contactUs addCallUsButton];
    
    OCMVerifyAll(self.mock);
}

- (void)testViewWillAppearCallsAddEmailUsButton
{
    OCMExpect([self.mock addEmailUsButton]);
    
    [self.contactUs viewWillAppear:YES];
    
    OCMVerifyAll(self.mock);
}

- (void)testDoesntAddEmailUsButtonIfSessionHasNoEmail
{
    id sessionMock = OCMPartialMock([DKSession sharedInstance]);
    OCMStub([sessionMock hasContactUsEmailAddress]).andReturn(NO);
    
    [[self.mock reject] addEmailUsAction];
    [self.contactUs addEmailUsButton];
    
    OCMVerifyAll(self.mock);
}

- (void)testAddsCallUsButtonIfSessionHasEmail
{
    id sessionMock = OCMPartialMock([DKSession sharedInstance]);
    OCMStub([sessionMock hasContactUsEmailAddress]).andReturn(YES);
    
    OCMExpect([self.mock addAction:OCMOCK_ANY]);
    
    [self.contactUs addEmailUsButton];
    
    OCMVerifyAll(self.mock);
}

@end
