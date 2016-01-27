//
//  DKSessionTests.m
//  DeskKit
//
//  Created by Desk.com on 9/10/14.
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
#import "DKSession.h"
#import "DKAPIManager.h"
#import "DKTestUtils.h"
#import "DKSettings.h"

@interface DKSessionTestViewController : UIViewController

@end

@implementation DKSessionTestViewController

- (void)didPauseDeskKitSession:(DKSession *)session
{
    // noop
}

@end

@interface DKSession ()

@property (nonatomic, strong) NSURL *contactUsPhoneNumberURL;

- (void)transitionToRootViewController:(UIViewController *)rootViewController
                    transitionDuration:(NSTimeInterval)transitionDuration
                     transitionOptions:(UIViewAnimationOptions)transitionOptions;
- (void)setupContactUsEmail;
- (void)fetchInboundMailboxesWithCompletionHandler:(void (^)(void))completionHandler;
- (DSAPIMailbox *)firstEnabledInboundMailboxFromPage:(DSAPIPage *)page;
- (NSString *)firstEnabledInboundEmailAddressFromPage:(DSAPIPage *)page;

@end

@interface DKSessionTests : XCTestCase

@property (nonatomic, strong) DKSession *testSession;

@end

@implementation DKSessionTests

- (void)setUp
{
    [super setUp];
    self.testSession = [[DKSession alloc] init];
}

- (void)testSessionInstantiatesAPIClientAndStartsSession
{
    NSDictionary *authDictionary = [DKTestUtils authDictionaryFromPlist];

    [DKSession startWithHostname:authDictionary[DKHostnameKey]
                        APIToken:authDictionary[DKAPITokenKey]];

    XCTAssertTrue([DKAPIManager sharedInstance].hasClient);

    XCTAssertTrue([DKSession isSessionStarted]);

    XCTAssertNotNil(self.testSession);
}

- (void)testSetupContactUsEmailWithSettings
{
    NSString *email = @"support@desk@com";
    id settingsMock = OCMPartialMock([DKSettings sharedInstance]);
    OCMStub([settingsMock hasContactUsToEmailAddress]).andReturn(YES);
    OCMStub([settingsMock contactUsToEmailAddress]).andReturn(email);

    [self.testSession setupContactUsEmail];

    XCTAssertTrue([self.testSession.contactUsToEmailAddress isEqualToString:email]);
}

- (void)testSetupContactUsEmailWithOutSettings
{
    NSString *email = @"support@desk@com";
    id settingsMock = OCMPartialMock([DKSettings sharedInstance]);
    OCMStub([settingsMock hasContactUsToEmailAddress]).andReturn(NO);
    OCMStub([settingsMock contactUsToEmailAddress]).andReturn(email);

    id sessionMock = OCMPartialMock([DKSession sharedInstance]);
    OCMExpect([sessionMock fetchInboundMailboxesWithCompletionHandler:nil]);

    [self.testSession setupContactUsEmail];

    XCTAssertFalse([self.testSession.contactUsToEmailAddress isEqualToString:email]);
    OCMVerifyAll(sessionMock);
}

- (void)testFirstEnabledInboundMailBox
{
    DSAPIPage *mailboxesPage = [DKFixtures inboundMailboxesPage];
    XCTAssertEqual([self.testSession firstEnabledInboundMailboxFromPage:mailboxesPage], mailboxesPage.entries.lastObject);
}

- (void)testFirstEnabledEmailAddress
{
    DSAPIPage *mailboxesPage = [DKFixtures inboundMailboxesPage];
    XCTAssertTrue([[self.testSession firstEnabledInboundEmailAddressFromPage:mailboxesPage] isEqualToString:[mailboxesPage.entries.lastObject valueForKey:@"email"]]);
}

@end
