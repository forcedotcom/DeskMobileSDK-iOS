//
//  DKContactUsViewModel.m
//  DeskKit
//
//  Created by Noel Artiles on 7/28/15.
//  Copyright (c) 2015 Desk.com. All rights reserved.
//

#import "DKContactUsViewModel.h"
#import "DKConstants.h"

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
        self.nameItem = [[DKContactUsInputTextItem alloc] initWithCellID:DKContactUsTextFieldTableViewCellID
                                                                    text:[self attributedTextWithString:self.userIdentity.fullName]
                                                         placeHolderText:[self attributedPlaceholderTextWithString:DKYourName]
                                                                required:NO];
        [items addObject:self.nameItem];
    }
    
    // Email
    if ([[self class] isEmptyString:self.userIdentity.email] || self.includeYourEmailItem) {
        self.emailItem = [[DKContactUsInputTextItem alloc] initWithCellID:DKContactUsTextFieldTableViewCellID
                                                                     text:[self attributedTextWithString:self.userIdentity.email]
                                                          placeHolderText:[self attributedPlaceholderTextWithString:DKYourEmail]
                                                                 required:YES];
        [items addObject:self.emailItem];
    }
    
    
    // Subject
    if (self.includeAllOptionalItems || self.includeSubjectItem) {
        self.subjectItem = [[DKContactUsInputTextItem alloc] initWithCellID:DKContactUsTextFieldTableViewCellID
                                                                       text:[self attributedTextWithString:self.subject]
                                                            placeHolderText:[self attributedPlaceholderTextWithString:DKSubject]
                                                                   required:NO];
        [items addObject:self.subjectItem];
    }
    
    // Body
    self.bodyItem = [[DKContactUsInputTextItem alloc] initWithCellID:DKContactUsTextViewTableViewCellID
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
    BOOL valid = [self validToRecipient] && [self requiredItemsHaveText] && [self validFromEmail];
    
    return valid;
}

- (BOOL)requiredItemsHaveText
{
    __block BOOL allPresent = YES;
    [self.sections enumerateObjectsUsingBlock:^(NSArray *section, NSUInteger idx, BOOL *stop) {
        [section enumerateObjectsUsingBlock:^(DKContactUsItem *item, NSUInteger idx, BOOL *stop) {
            if ([item isKindOfClass:[DKContactUsInputTextItem class]]) {
                DKContactUsInputTextItem *inputTextItem = (DKContactUsInputTextItem *)item;
                if (inputTextItem.required && [[self class] isEmptyString:inputTextItem.text.string]) {
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

+ (BOOL)isEmptyString:(NSString *)string
{
    return string == nil || [string isEqualToString:@""];
}

+ (BOOL)isNotEmptyString:(NSString *)string
{
    return ![[self class] isEmptyString:string];
}

- (BOOL)validToRecipient
{
    return [[self class] isNotEmptyString:self.toRecipient];
}

- (BOOL)validFromEmail
{
    return [[self class] isNotEmptyString:[self bestFromEmail]];
}

- (NSString *)bestFromEmail
{
    if ([[self class] isNotEmptyString:self.emailItem.text.string]) {
        return self.emailItem.text.string;
    }
    if ([[self class] isNotEmptyString:self.userIdentity.email]) {
        return self.userIdentity.email;
    }
    return nil;
}

- (NSString *)bestFullName
{
    if ([[self class] isNotEmptyString:self.nameItem.text.string]) {
        return self.emailItem.text.string;
    }
    if ([[self class] isNotEmptyString:self.userIdentity.fullName]) {
        return self.userIdentity.fullName;
    }
    return nil;
}

- (NSString *)bestSubject
{
    if ([[self class] isNotEmptyString:self.subjectItem.text.string]) {
        return self.emailItem.text.string;
    }
    if ([[self class] isNotEmptyString:self.subject]) {
        return self.userIdentity.fullName;
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
                           queue:queue
                         success:success
                         failure:failure];
}

- (NSDictionary *)caseDictionary
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    // Add optional keys
    NSString *name = [self bestFullName];
    if ([[self class] isNotEmptyString:name]) {
        dictionary[DKCaseNameKey] = self.nameItem.text.string;
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
                                         DKMessageToKey: self.toRecipient
                                         } mutableCopy];
    
    // Add optional keys
    NSString *subject = [self bestSubject];
    if ([[self class] isNotEmptyString:subject]) {
        dictionary[DKMessageSubjectKey] = subject;
    }
    
    return [dictionary copy];
}



@end
