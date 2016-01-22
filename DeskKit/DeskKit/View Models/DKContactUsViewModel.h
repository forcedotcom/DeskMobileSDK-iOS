//
//  DKContactUsViewModel.h
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
