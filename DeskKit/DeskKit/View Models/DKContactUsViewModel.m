//
//  DKContactUsViewModel.m
//  DeskKit
//
//  Created by Desk.com on 7/28/15.
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

#import "DKContactUsViewModel.h"
#import "DKAPIManager.h"
#import "DKConstants.h"
#import "NSString+Additions.h"

@interface DKContactUsViewModel ()

@property (nonatomic) NSArray *sections;
@property (nonatomic) NSIndexPath *messageIndexPath;

@property (nonatomic) DKContactUsInputTextItem *nameItem;
@property (nonatomic) DKContactUsInputTextItem *emailItem;
@property (nonatomic) DKContactUsInputTextItem *bodyItem;
@property (nonatomic) DKContactUsInputTextItem *subjectItem;

@end

@implementation DKContactUsViewModel

static NSString * const DKCaseTypeKey = @"type";
static NSString * const DKCaseNameKey = @"name";
static NSString * const DKCaseMessageKey = @"message";
static NSString * const DKCaseCustomFieldsKey = @"custom_fields";
static NSString * const DKMessageDirectionKey = @"direction";
static NSString * const DKMessageBodyKey = @"body";
static NSString * const DKMessageFromKey = @"from";
static NSString * const DKMessageToKey = @"to";
static NSString * const DKMessageSubjectKey = @"subject";


- (instancetype)init
{
    self = [self initIncludingOptionalItems:YES];
    if (self) {
        
    }
    return self;
}

- (instancetype)initIncludingOptionalItems:(BOOL)include
{
    self = [super init];
    if (self) {
        _includeAllOptionalItems = include;
    }
    return self;
}

- (NSArray *)createStaticLabelItems
{
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:4];
    
    // Name
    if (self.includeAllOptionalItems || self.includeYourNameItem) {
        self.nameItem = [[DKContactUsInputTextItem alloc] initWithIdentifier:self.nameItemIdentifier
                                                                        text:[self attributedTextWithString:self.userIdentity.fullName]
                                                             placeHolderText:[self attributedPlaceholderTextWithString:DKYourName]
                                                                    required:NO];
        self.nameItem.keyboardType = UIKeyboardTypeNamePhonePad;
        self.nameItem.autocorrectionType = UITextAutocorrectionTypeNo;
        self.nameItem.returnKeyType = UIReturnKeyNext;
        
        [items addObject:self.nameItem];
    }
    
    // Email
    if ([NSString dkIsEmptyString:self.userIdentity.email] || self.includeYourEmailItem) {
        self.emailItem = [[DKContactUsInputTextItem alloc] initWithIdentifier:self.emailItemIdentifier
                                                                         text:[self attributedTextWithString:self.userIdentity.email]
                                                              placeHolderText:[self attributedPlaceholderTextWithString:DKYourEmail]
                                                                     required:YES];
        self.emailItem.keyboardType = UIKeyboardTypeEmailAddress;
        self.emailItem.autocorrectionType = UITextAutocorrectionTypeNo;
        self.emailItem.returnKeyType = UIReturnKeyNext;
        
        [items addObject:self.emailItem];
    }
    
    
    // Subject
    if (self.includeAllOptionalItems || self.includeSubjectItem) {
        self.subjectItem = [[DKContactUsInputTextItem alloc] initWithIdentifier:self.subjectItemIdentifier
                                                                           text:[self attributedTextWithString:self.subject]
                                                                placeHolderText:[self attributedPlaceholderTextWithString:DKSubject]
                                                                       required:NO];
        self.subjectItem.returnKeyType = UIReturnKeyNext;
        self.subjectItem.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        
        [items addObject:self.subjectItem];
    }
    
    // Body
    self.bodyItem = [[DKContactUsInputTextItem alloc] initWithIdentifier:self.messageBodyItemIdentifier
                                                                    text:nil
                                                         placeHolderText:[self attributedPlaceholderTextWithString:DKMessage]
                                                                required:YES];
    [items addObject:self.bodyItem];
    
    self.messageIndexPath = [NSIndexPath indexPathForRow:[items indexOfObject:self.bodyItem] inSection:0];
    return [items copy];
}

- (NSArray *)sections
{
    if (_sections == nil) {
        _sections = @[[self createStaticLabelItems]];
    }
    
    return _sections;
}

- (NSAttributedString *)attributedTextWithString:(NSString *)string
{
    if (string) {
        return [[NSAttributedString alloc] initWithString:string];
    }
    return nil;
}

- (NSAttributedString *)attributedPlaceholderTextWithString:(NSString *)string
{
    if (string) {
        return [[NSAttributedString alloc] initWithString:string];
    }
    return nil;
}

- (void)updateText:(NSAttributedString *)text indexPath:(NSIndexPath *)indexPath
{
    DKContactUsItem *item = self.sections[indexPath.section][indexPath.row];
    NSAssert([item isKindOfClass:[DKContactUsInputTextItem class]], @"Item at indexPath is not an Input Text Item");
    
    DKContactUsInputTextItem *inputTextItem = (DKContactUsInputTextItem *)item;
    inputTextItem.text = text;
}

- (BOOL)isValidEmailCase
{
    BOOL valid = [self validToEmail] && [self requiredItemsHaveText] && [self validFromEmail];
    
    return valid;
}

- (BOOL)requiredItemsHaveText
{
    __block BOOL allPresent = YES;
    [self.sections enumerateObjectsUsingBlock:^(NSArray *section, NSUInteger idx, BOOL *stop) {
        [section enumerateObjectsUsingBlock:^(DKContactUsItem *item, NSUInteger idx, BOOL *stop) {
            if ([item isKindOfClass:[DKContactUsInputTextItem class]]) {
                DKContactUsInputTextItem *inputTextItem = (DKContactUsInputTextItem *)item;
                if (inputTextItem.required && [NSString dkIsEmptyString:inputTextItem.text.string]) {
                    allPresent = NO;
                    *stop = YES;
                }
            }
        }];
        if (!allPresent) {
            *stop = YES;
        }
    }];
    
    return allPresent;
}

- (BOOL)validToEmail
{
    return [NSString dkIsNotEmptyString:self.toEmailAddress];
}

- (BOOL)validFromEmail
{
    NSString *email = [self bestFromEmail];
    return [NSString dkIsNotEmptyString:email] && [self validRFC5322Email:email];
}

- (BOOL)validRFC5322Email:(NSString *)email
{
    // See: http://www.regular-expressions.info/email.html
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:email];
}

- (NSString *)bestFromEmail
{
    if ([NSString dkIsNotEmptyString:self.emailItem.text.string]) {
        return self.emailItem.text.string;
    }
    if ([NSString dkIsNotEmptyString:self.userIdentity.email]) {
        return self.userIdentity.email;
    }
    return nil;
}

- (NSString *)bestFullName
{
    if ([NSString dkIsNotEmptyString:self.nameItem.text.string]) {
        return self.nameItem.text.string;
    }
    if ([NSString dkIsNotEmptyString:self.userIdentity.fullName]) {
        return self.userIdentity.fullName;
    }
    return nil;
}

- (NSString *)bestSubject
{
    if ([NSString dkIsNotEmptyString:self.subjectItem.text.string]) {
        return self.subjectItem.text.string;
    }
    if ([NSString dkIsNotEmptyString:self.subject]) {
        return self.subject;
    }
    return DKDefaultSubject;
}

#pragma mark - API Calls

- (NSURLSessionDataTask *)createEmailCaseWithQueue:(NSOperationQueue *)queue
                                           success:(void (^)(DSAPICase *newCase))success
                                           failure:(DSAPIFailureBlock)failure
{
    NSAssert([self isValidEmailCase], @"Email case is invalid");
    
    NSDictionary *dictionary = [self caseDictionary];
    return [DSAPICase createCase:dictionary
                          client:[DKAPIManager sharedInstance].client
                           queue:queue
                         success:success
                         failure:failure];
}

- (NSDictionary *)caseDictionary
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    // Add optional keys
    NSString *name = [self bestFullName];
    if ([NSString dkIsNotEmptyString:name]) {
        dictionary[DKCaseNameKey] = name;
    }
    if (self.customFields.count) {
        dictionary[DKCaseCustomFieldsKey] = self.customFields;
    }
    
    // Add required keys
    dictionary[DKCaseTypeKey] = @"email";
    dictionary[DKCaseMessageKey] = [self messageDictionary];
    
    return [dictionary copy];
}

- (NSDictionary *)messageDictionary
{
    NSString *fromEmail = [self bestFromEmail];
    NSMutableDictionary *dictionary = [@{
                                         DKMessageDirectionKey: @"in",
                                         DKMessageBodyKey: self.bodyItem.text.string,
                                         DKMessageFromKey: fromEmail,
                                         DKMessageToKey: self.toEmailAddress
                                         } mutableCopy];
    
    NSString *subject = [self bestSubject];
    dictionary[DKMessageSubjectKey] = subject;
    
    return [dictionary copy];
}

@end
