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
#import "NSString+Additions.h"
#import "NSDate+DSC.h"

static NSString *const DKSettingsPListName = @"DeskKitSettings";
static NSString *const DKSettingsContactUsPhoneNumberKey = @"ContactUsPhoneNumber";
static NSString *const DKSettingsContactUsToEmailKey = @"ContactUsToEmailAddress";
static NSString *const DKSettingsContactUsSubject = @"ContactUsSubject";
static NSString *const DKSettingsContactUsShowAllOptionalItems = @"ContactUsShowAllOptionalItems";
static NSString *const DKSettingsContactUsShowYourNameItem = @"ContactUsShowYourNameItem";
static NSString *const DKSettingsContactUsShowYourEmailItem = @"ContactUsShowYourEmailItem";
static NSString *const DKSettingsContactUsShowSubjectItem = @"ContactUsShowSubjectItem";
static NSString *const DKSettingsContactUsStaticCustomFields = @"ContactUsStaticCustomFields";
static NSString *const DKSettingsBrandIdKey = @"BrandId";
static NSString *const DKSettingsTopNavKey = @"NavigationBar";
static NSString *const DKSettingsTopNavTintColorRGBAKey = @"TintColorRGBA";
static NSString *const DKSettingsTopNavBarTintColorRGBAKey = @"BarTintColorRGBA";
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
    NSURL *plistURL = [bundle URLForResource:DKSettingsPListName
                               withExtension:@"plist"];

    return [NSDictionary dictionaryWithContentsOfURL:plistURL];
}

- (NSString *)contactUsPhoneNumber
{
    return self.settings[DKSettingsContactUsPhoneNumberKey];
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

- (NSString *)contactUsToEmailAddress
{
    return self.settings[DKSettingsContactUsToEmailKey];
}

- (BOOL)hasContactUsToEmailAddress
{
    if (!self.contactUsToEmailAddress.length) {
        return NO;
    }

    NSError *error = nil;

    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:DKEmailRegex
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&error];

    NSRange inputRange = NSMakeRange(0, self.contactUsToEmailAddress.length);
    NSArray *results = [regex matchesInString:self.contactUsToEmailAddress options:0 range:inputRange];

    return [NSTextCheckingResult results:results
                         matchInputRange:inputRange
                           andResultType:NSTextCheckingTypeRegularExpression];
}

- (NSString *)contactUsSubject
{
    return self.settings[DKSettingsContactUsSubject];
}

- (BOOL)hasContactUsSubject
{
    return [NSString dkIsNotEmptyString:self.contactUsSubject];
}

- (BOOL)contactUsShowAllOptionalItems
{
    return [self.settings[DKSettingsContactUsShowAllOptionalItems] boolValue];
}

- (BOOL)contactUsShowYourNameItem
{
    return [self.settings[DKSettingsContactUsShowYourNameItem] boolValue];
}

- (BOOL)contactUsShowYourEmailItem
{
    return [self.settings[DKSettingsContactUsShowYourEmailItem] boolValue];
}

- (BOOL)contactUsShowSubjectItem
{
    return [self.settings[DKSettingsContactUsShowSubjectItem] boolValue];
}

- (NSDictionary *)contactUsStaticCustomFields
{
    return [self dateFormattedDictionaryWithPlistDictionary:self.settings[DKSettingsContactUsStaticCustomFields]];
}

- (NSDictionary *)dateFormattedDictionaryWithPlistDictionary:(NSDictionary *)plistDictionary
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:plistDictionary.count];
    [plistDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSDate class]]) {
            result[key] = [(NSDate *)obj stringWithISO8601Format];
        } else {
            result[key] = obj;
        }
    }];
    return [result copy];
}

- (BOOL)hasContactUsStaticCustomFields
{
    return self.contactUsStaticCustomFields != nil;
}

- (NSString *)brandId
{
    return self.settings[DKSettingsBrandIdKey];
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
    return self.settings[DKSettingsTopNavKey];
}

- (NSDictionary *)topNavTintColorRGBA
{
    return self.topNavSettings[DKSettingsTopNavTintColorRGBAKey];
}

- (BOOL)hasTopNavTintColorRGBA
{
    return self.topNavTintColorRGBA != nil;
}

- (UIColor *)topNavTintColor
{
    return self.hasTopNavTintColorRGBA ? [UIColor colorWithDictionary:self.topNavTintColorRGBA] : [UIColor blackColor];
}

- (NSDictionary *)topNavBarTintColorRGBA
{
    return self.topNavSettings[DKSettingsTopNavBarTintColorRGBAKey];
}

- (BOOL)hasTopNavBarTintColorRGBA
{
    return self.topNavBarTintColorRGBA != nil;
}

- (UIColor *)topNavBarTintColor
{
    return self.hasTopNavBarTintColorRGBA ? [UIColor colorWithDictionary:self.topNavBarTintColorRGBA] : [UIColor whiteColor];
}

- (NSString *)topNavIconFileName
{
    return self.settings[DKSettingsTopNavIconFileNameKey];
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
