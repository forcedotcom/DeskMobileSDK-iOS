//
//  DKContactUsViewModel.h
//  DeskKit
//
//  Created by Noel Artiles on 7/28/15.
//  Copyright (c) 2015 Desk.com. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "DKContactUsInputTextItem.h"
#import <DeskAPIClient/DSAPICase.h>
#import "DKUserIdentity.h"

@interface DKContactUsViewModel : NSObject

@property (nonatomic, readonly) NSArray *sections;
@property (nonatomic, readonly) NSIndexPath *messageIndexPath;

// Used to configure initial state. User can override these if exposed through the UI.
@property (nonatomic) DKUserIdentity *userIdentity;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *toEmailAddress;
@property (nonatomic, copy) NSDictionary *customFields;

// Identifiers for UI components. For example, for UITableViewCell identifiers.
@property (nonatomic, copy) NSString *nameItemIdentifier;
@property (nonatomic, copy) NSString *emailItemIdentifier;
@property (nonatomic, copy) NSString *subjectItemIdentifier;
@property (nonatomic, copy) NSString *messageBodyItemIdentifier;

// These control what to show in the UI.
@property (nonatomic) BOOL includeAllOptionalItems;
@property (nonatomic) BOOL includeYourNameItem;
@property (nonatomic) BOOL includeYourEmailItem;
@property (nonatomic) BOOL includeSubjectItem;

- (instancetype)initIncludingOptionalItems:(BOOL)include;
- (void)updateText:(NSAttributedString *)text indexPath:(NSIndexPath *)indexPath;

- (BOOL)isValidEmailCase;
- (NSURLSessionDataTask *)createEmailCaseWithQueue:(NSOperationQueue *)queue
                                           success:(void (^)(DSAPICase *newCase))success
                                           failure:(DSAPIFailureBlock)failure;

@end
