//
//  DKSettingsTests.m
//  DeskKit
//
//  Created by Desk.com on 9/30/14.
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
#import "DKSettings.h"

@interface DKSettings ()

@property (nonatomic, strong) NSDictionary *settings;

- (NSDictionary *)settingsDictionaryFromPlist;

@end

@interface DKSettingsTests : XCTestCase

@property (nonatomic, strong) DKSettings *settingsTest;
@property (nonatomic, strong) id mock;

@end

@implementation DKSettingsTests

- (void)setUp
{
    [super setUp];
    self.settingsTest = [[DKSettings alloc] init];
    self.mock = OCMPartialMock(self.settingsTest);
}

- (void)testContactUsPhoneNumber
{
    NSString *phone = @"18772269212";
    NSDictionary *settings = @{ @"ContactUsPhoneNumber" : phone };
    OCMStub([self.mock settings]).andReturn(settings);
    NSString *contactUs = [self.settingsTest contactUsPhoneNumber];
    XCTAssertTrue([contactUs isEqualToString:phone]);
}

- (void)testHasContactUsPhoneNumber
{
    NSString *phone = @"18772269212";
    NSDictionary *settings = @{ @"ContactUsPhoneNumber" : phone };
    OCMStub([self.mock settings]).andReturn(settings);
    XCTAssertTrue([self.settingsTest hasContactUsPhoneNumber]);
}

- (void)testHasContactUsPhoneNumberHyphens
{
    NSString *phone = @"1-877-226-9212";
    NSDictionary *settings = @{ @"ContactUsPhoneNumber" : phone };
    OCMStub([self.mock settings]).andReturn(settings);
    XCTAssertTrue([self.settingsTest hasContactUsPhoneNumber]);
}

- (void)testHasContactUsPhoneNumberParens
{
    NSString *phone = @"1 (877) 226-9212";
    NSDictionary *settings = @{ @"ContactUsPhoneNumber" : phone };
    OCMStub([self.mock settings]).andReturn(settings);
    XCTAssertTrue([self.settingsTest hasContactUsPhoneNumber]);
}

- (void)testDoesntHaveContactUsPhoneNumberForEmptyString
{
    NSString *phone = @"";
    NSDictionary *settings = @{ @"ContactUsPhoneNumber" : phone };
    OCMStub([self.mock settings]).andReturn(settings);
    XCTAssertFalse([self.settingsTest hasContactUsPhoneNumber]);
}

- (void)testDoesntHaveContactUsPhoneNumberForBadPhoneNumber
{
    NSString *phone = @"asdf";
    NSDictionary *settings = @{ @"ContactUsPhoneNumber" : phone };
    OCMStub([self.mock settings]).andReturn(settings);
    XCTAssertFalse([self.settingsTest hasContactUsPhoneNumber]);
}

- (void)testDoesntHaveContactUsPhoneNumberForBadPhoneNumber2
{
    NSString *phone = @"187722692120000000";
    NSDictionary *settings = @{ @"ContactUsPhoneNumber" : phone };
    OCMStub([self.mock settings]).andReturn(settings);
    XCTAssertFalse([self.settingsTest hasContactUsPhoneNumber]);
}

- (void)testContactUsEmail
{
    NSString *email = @"support@desk.com";
    NSDictionary *settings = @{ @"ContactUsToEmailAddress" : email };
    OCMStub([self.mock settings]).andReturn(settings);
    NSString *contactUs = [self.settingsTest contactUsToEmailAddress];
    XCTAssertTrue([contactUs isEqualToString:email]);
}

- (void)testHasContactUsEmail
{
    NSString *email = @"support@desk.com";
    NSDictionary *settings = @{ @"ContactUsToEmailAddress" : email };
    OCMStub([self.mock settings]).andReturn(settings);
    XCTAssertTrue([self.settingsTest hasContactUsToEmailAddress]);
}

- (void)testDoesntHaveContactUsEmailForEmptyString
{
    NSString *email = @"";
    NSDictionary *settings = @{ @"ContactUsEmailAddress" : email };
    OCMStub([self.mock settings]).andReturn(settings);
    XCTAssertFalse([self.settingsTest hasContactUsToEmailAddress]);
}

- (void)testDoesntHaveContactUsEmailForBadEmail
{
    NSString *email = @"asdf";
    NSDictionary *settings = @{ @"ContactUsEmailAddress" : email };
    OCMStub([self.mock settings]).andReturn(settings);
    XCTAssertFalse([self.settingsTest hasContactUsToEmailAddress]);
}

- (void)testDoesntHaveContactUsEmailForBadEmail2
{
    NSString *email = @"support@desk@com";
    NSDictionary *settings = @{ @"ContactUsEmailAddress" : email };
    OCMStub([self.mock settings]).andReturn(settings);
    XCTAssertFalse([self.settingsTest hasContactUsToEmailAddress]);
}

- (void)testDoesntHaveSettings
{
    OCMStub([self.mock settings]).andReturn(nil);
    XCTAssertFalse([self.settingsTest hasContactUsPhoneNumber]);
    XCTAssertFalse([self.settingsTest hasContactUsToEmailAddress]);
}

- (void)testBrandId
{
    NSString *brandId = @"1234";
    NSDictionary *settings = @{ @"BrandId" : brandId };
    OCMStub([self.mock settings]).andReturn(settings);
    NSString *brandIdSetting = [self.settingsTest brandId];
    XCTAssertTrue([brandIdSetting isEqualToString:brandId]);
}

- (void)testHasBrandId
{
    NSString *brandId = @"1234";
    NSDictionary *settings = @{ @"BrandId" : brandId };
    OCMStub([self.mock settings]).andReturn(settings);
    XCTAssertTrue([self.settingsTest hasBrandId]);
}

- (void)testDoesntHaveBrandIdForEmptyString
{
    NSString *brandId = @"";
    NSDictionary *settings = @{ @"BrandId" : brandId };
    OCMStub([self.mock settings]).andReturn(settings);
    XCTAssertFalse([self.settingsTest hasBrandId]);
}

- (void)testBrandResource
{
    NSString *brandId = @"1234";
    NSDictionary *settings = @{ @"BrandId" : brandId };
    OCMStub([self.mock settings]).andReturn(settings);
    DSAPIBrand *brand = [self.settingsTest brand];
    XCTAssertTrue([brand isKindOfClass:[DSAPIBrand class]]);
}

- (void)testTopNavTintColorRgba
{
    NSDictionary *color = [self colorRgbaSettings];
    OCMStub([self.mock settings]).andReturn(color);
    NSDictionary *colorSetting = [self.settingsTest topNavTintColorRGBA];
    XCTAssertTrue([colorSetting isEqual:color[@"NavigationBar"][@"TintColorRGBA"]]);
}

- (void)testHasTopNavTintColorRgba
{
    NSDictionary *settings = [self colorRgbaSettings];
    OCMStub([self.mock settings]).andReturn(settings);
    XCTAssertTrue([self.settingsTest hasTopNavTintColorRGBA]);
}

- (void)testDoesntHaveTopNavTintColorRgbaForEmptyDictionary
{
    NSDictionary *settings = @{};
    OCMStub([self.mock settings]).andReturn(settings);
    XCTAssertFalse([self.settingsTest hasTopNavTintColorRGBA]);
}

- (void)testTopNavTintColor
{
    OCMStub([self.mock settings]).andReturn([self colorRgbaSettings]);
    UIColor *color = [self.settingsTest topNavTintColor];
    XCTAssertTrue([color isKindOfClass:[UIColor class]]);
}

- (void)testTopNavBarTintColorRgba
{
    NSDictionary *color = [self colorRgbaSettings];
    OCMStub([self.mock settings]).andReturn(color);
    NSDictionary *colorSetting = [self.settingsTest topNavBarTintColorRGBA];
    XCTAssertTrue([colorSetting isEqual:color[@"NavigationBar"][@"BarTintColorRGBA"]]);
}

- (void)testHasTopNavBarTintColorRgba
{
    OCMStub([self.mock settings]).andReturn([self colorRgbaSettings]);
    XCTAssertTrue([self.settingsTest hasTopNavBarTintColorRGBA]);
}

- (void)testDoesntHaveTopNavBarTintColorRgbaForEmptyDictionary
{
    NSDictionary *settings = @{};
    OCMStub([self.mock settings]).andReturn(settings);
    XCTAssertFalse([self.settingsTest hasTopNavBarTintColorRGBA]);
}

- (void)testTopNavBarTintColor
{
    OCMStub([self.mock settings]).andReturn([self colorRgbaSettings]);
    UIColor *color = [self.settingsTest topNavBarTintColor];
    XCTAssertTrue([color isKindOfClass:[UIColor class]]);
}

- (void)testTopNavIconFileName
{
    NSString *fileName = @"home";
    NSDictionary *settings = @{ @"TopNavIconFileName" : fileName };
    OCMStub([self.mock settings]).andReturn(settings);
    NSString *brandIdSetting = [self.settingsTest topNavIconFileName];
    XCTAssertTrue([brandIdSetting isEqualToString:fileName]);
}

- (void)testHasTopNavIconFileName
{
    NSString *fileName = @"home";
    NSDictionary *settings = @{ @"TopNavIconFileName" : fileName };
    OCMStub([self.mock settings]).andReturn(settings);
    XCTAssertTrue([self.settingsTest hasTopNavIconFileName]);
}

- (void)testDoesntHaveTopNavIconFileNameForEmptyString
{
    NSString *fileName = @"";
    NSDictionary *settings = @{ @"TopNavIconFileName" : fileName };
    OCMStub([self.mock settings]).andReturn(settings);
    XCTAssertFalse([self.settingsTest hasTopNavIconFileName]);
}

- (void)testTopNavIcon
{
    NSString *fileName = @"home";
    NSDictionary *settings = @{ @"TopNavIconFileName" : fileName };
    OCMStub([self.mock settings]).andReturn(settings);
    id ImageClassMock = OCMClassMock([UIImage class]);
    __unused UIImage *topNavIcon = [self.settingsTest topNavIcon];
    OCMVerify([ImageClassMock imageNamed:fileName]);
}

#pragma mark - Utility methods

- (NSDictionary *)colorRgbaSettings
{
    NSDictionary *color = @{ @"Red" : @25,
                             @"Green" : @151,
                             @"Blue" : @93,
                             @"Alpha" : @1 };
    NSDictionary *colors = @{ @"BarTintColorRGBA" : color,
                              @"TintColorRGBA" : color };
    return @{ @"NavigationBar" : colors };
}

@end
