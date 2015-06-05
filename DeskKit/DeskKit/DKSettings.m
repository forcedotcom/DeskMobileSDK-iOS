//
//  DKSettings.m
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

#import "DKSettings.h"
#import "NSTextCheckingResult+Additions.h"
#import "UIColor+Additions.h"

static NSString *const DKSettingsPListName = @"DeskKitSettings";
static NSString *const DKSettingsContactUsPhoneNumberKey = @"ContactUsPhoneNumber";
static NSString *const DKSettingsContactUsEmailKey = @"ContactUsEmailAddress";
static NSString *const DKSettingsShowContactUsWebForm = @"ShowContactUsWebForm";
static NSString *const DKSettingsBrandIdKey = @"BrandId";
static NSString *const DKSettingsTopNavKey = @"NavigationBar";
static NSString *const DKSettingsTopNavTintColorRgbaKey = @"TintColorRGBA";
static NSString *const DKSettingsTopNavBarTintColorRgbaKey = @"BarTintColorRGBA";
static NSString *const DKSettingsTopNavIconFileNameKey = @"TopNavIconFileName";
static NSString *const DKEmailRegex = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";

@interface DKSettings ()

@property (nonatomic, strong) NSDictionary *settings;

- (NSDictionary *)settingsDictionaryFromPlist;
- (NSDictionary *)topNavSettings;

@end

@implementation DKSettings

+ (instancetype)sharedInstance
{
    static DKSettings *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[DKSettings alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.settings = [self settingsDictionaryFromPlist];
    }
    return self;
}

- (NSDictionary *)settingsDictionaryFromPlist
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *plistUrl = [bundle URLForResource:DKSettingsPListName
                               withExtension:@"plist"];

    return [NSDictionary dictionaryWithContentsOfURL:plistUrl];
}

- (NSString *)contactUsPhoneNumber
{
    return [self.settings valueForKey:DKSettingsContactUsPhoneNumberKey];
}

- (BOOL)hasContactUsPhoneNumber
{
    if (!self.contactUsPhoneNumber.length) {
        return NO;
    }

    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber
                                                               error:&error];

    NSRange inputRange = NSMakeRange(0, self.contactUsPhoneNumber.length);
    NSArray *results = [detector matchesInString:self.contactUsPhoneNumber
                                         options:0
                                           range:inputRange];

    return [NSTextCheckingResult results:results
                         matchInputRange:inputRange
                           andResultType:NSTextCheckingTypePhoneNumber];
}

- (NSString *)contactUsEmailAddress
{
    return [self.settings valueForKey:DKSettingsContactUsEmailKey];
}

- (BOOL)hasContactUsEmailAddress
{
    if (!self.contactUsEmailAddress.length) {
        return NO;
    }

    NSError *error = nil;

    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:DKEmailRegex
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&error];

    NSRange inputRange = NSMakeRange(0, self.contactUsEmailAddress.length);
    NSArray *results = [regex matchesInString:self.contactUsEmailAddress options:0 range:inputRange];

    return [NSTextCheckingResult results:results
                         matchInputRange:inputRange
                           andResultType:NSTextCheckingTypeRegularExpression];
}

- (BOOL)showContactUsWebForm
{
    return [[self.settings valueForKey:DKSettingsShowContactUsWebForm] boolValue];
}

- (NSString *)brandId
{
    return [self.settings valueForKey:DKSettingsBrandIdKey];
}

- (BOOL)hasBrandId
{
    return self.brandId.length;
}

- (DSAPIBrand *)brand
{
    if (!self.hasBrandId) {
        return nil;
    }

    return (DSAPIBrand *)[DSAPIResource resourceWithId:self.brandId
                                             className:[DSAPIBrand className]];
}

- (NSDictionary *)topNavSettings
{
    return [self.settings valueForKey:DKSettingsTopNavKey];
}

- (NSDictionary *)topNavTintColorRgba
{
    return [self.topNavSettings valueForKey:DKSettingsTopNavTintColorRgbaKey];
}

- (BOOL)hasTopNavTintColorRgba
{
    return self.topNavTintColorRgba != nil;
}

- (UIColor *)topNavTintColor
{
    return self.hasTopNavTintColorRgba ? [UIColor colorWithDictionary:self.topNavTintColorRgba] : [UIColor blackColor];
}

- (NSDictionary *)topNavBarTintColorRgba
{
    return [self.topNavSettings valueForKey:DKSettingsTopNavBarTintColorRgbaKey];
}

- (BOOL)hasTopNavBarTintColorRgba
{
    return self.topNavBarTintColorRgba != nil;
}

- (UIColor *)topNavBarTintColor
{
    return self.hasTopNavBarTintColorRgba ? [UIColor colorWithDictionary:self.topNavBarTintColorRgba] : [UIColor whiteColor];
}

- (NSString *)topNavIconFileName
{
    return [self.settings valueForKey:DKSettingsTopNavIconFileNameKey];
}

- (BOOL)hasTopNavIconFileName
{
    return self.topNavIconFileName.length;
}

- (UIImage *)topNavIcon
{
    if (!self.hasTopNavIconFileName) {
        return nil;
    }

    return [UIImage imageNamed:self.topNavIconFileName];
}

@end
