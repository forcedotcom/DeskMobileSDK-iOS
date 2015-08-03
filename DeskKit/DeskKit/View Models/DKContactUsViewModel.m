//
//  DKContactUsViewModel.m
//  DeskKit
//
//  Created by Noel Artiles on 7/28/15.
//  Copyright (c) 2015 Desk.com. All rights reserved.
//

#import "DKContactUsViewModel.h"

@interface DKContactUsViewModel ()

@property (nonatomic) NSArray *sections;
@property (nonatomic) NSIndexPath *messageIndexPath;

@property (nonatomic) DKContactUsInputTextItem *name;
@property (nonatomic) DKContactUsInputTextItem *email;
@property (nonatomic) DKContactUsInputTextItem *body;
@property (nonatomic) DKContactUsInputTextItem *subject;

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
    
    if (self.includeAllOptionalItems || self.includeYourNameItem) {
        self.name = [[DKContactUsInputTextItem alloc] initWithCellID:DKContactUsTextFieldTableViewCellID
                                                                                     text:nil
                                                                          placeHolderText:[[NSAttributedString alloc] initWithString:@"Your Name"]
                                                                                 required:NO];
        [items addObject:self.name];
    }
    
    self.email = [[DKContactUsInputTextItem alloc] initWithCellID:DKContactUsTextFieldTableViewCellID
                                                                          text:nil
                                                               placeHolderText:[[NSAttributedString alloc] initWithString:@"Your Email"]
                                                                      required:YES];
    [items addObject:self.email];
    
    if (self.includeAllOptionalItems || self.includeSubjectItem) {
        self.subject = [[DKContactUsInputTextItem alloc] initWithCellID:DKContactUsTextFieldTableViewCellID
                                                                                        text:nil
                                                                             placeHolderText:[[NSAttributedString alloc] initWithString:@"Subject"]
                                                                                    required:NO];
        [items addObject:self.subject];
    }
    
    self.body = [[DKContactUsInputTextItem alloc] initWithCellID:DKContactUsTextViewTableViewCellID
                                                                            text:nil
                                                                 placeHolderText:[[NSAttributedString alloc] initWithString:@"Message"]
                                                                        required:YES];
    [items addObject:self.body];
    
    self.messageIndexPath = [NSIndexPath indexPathForRow:[items indexOfObject:self.body] inSection:0];
    return [items copy];
}

- (NSArray *)sections
{
    if (_sections == nil) {
        _sections = @[[self createStaticLabelItems]];
    }
    
    return _sections;
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
    BOOL valid = [self validToRecipient] && [self requiredItemsArePresent];
    
    return valid;
}

- (BOOL)requiredItemsArePresent
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

- (BOOL)validToRecipient
{
    return ![[self class] isEmptyString:self.toRecipient];
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
    if (![[self class] isEmptyString:self.name.text.string]) {
        dictionary[DKCaseNameKey] = self.name.text.string;
    }
    
    // Add required keys
    dictionary[DKCaseTypeKey] = @"email";
    dictionary[DKCaseMessageKey] = [self messageDictionary];
    
    return [dictionary copy];
}

- (NSDictionary *)messageDictionary
{
    NSMutableDictionary *dictionary = [@{
                                        DKMessageDirectionKey: @"in",
                                        DKMessageBodyKey: self.body.text.string,
                                        DKMessageFromKey: self.email.text.string,
                                        DKMessageToKey: self.toRecipient
                                        } mutableCopy];
    
    // Add optional keys
    if (![[self class] isEmptyString:self.subject.text.string]) {
        dictionary[DKMessageSubjectKey] = self.subject.text.string;
    }
    
    return [dictionary copy];
}



@end
