//
//  DKConstants.h
//  DeskKit
//
//  Created by Desk.com on 9/19/14.
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

#pragma mark - Lists

extern NSInteger const DKItemsPerPage;

#pragma mark - Model Fields

extern NSString *const DKTopicNameKey;
extern NSString *const DKTopicPositionKey;
extern NSString *const DKArticleSubjectKey;
extern NSString *const DKArticlePublicURLKey;
extern NSString *const DKArticleBodyKey;
extern NSString *const DKArticlePrivateSearchKey;
extern NSString *const DKArticlePositionKey;

#pragma mark - API Parameters

extern NSString *const DKFieldsKey;
extern NSString *const DKSortFieldKey;
extern NSString *const DKSortDirectionKey;
extern NSString *const DKSortDirectionAsc;
extern NSString *const DKSortDirectionDesc;
extern NSString *const DKTopicIdsKey;
extern NSString *const DKTopicIdKey;
extern NSString *const DKBrandIdsKey;

#pragma mark - UI

extern CGFloat const DKSearchBarHeight;

#pragma mark - Strings

#define DKCallUs NSLocalizedString(@"Call Us", @"Call Us button title")
#define DKEmailUs NSLocalizedString(@"Email Us", @"Email Us button title")
#define DKCancel NSLocalizedString(@"Cancel", @"Cancel button title")
#define DKOk NSLocalizedString(@"OK", @"OK button title")
#define DKDone NSLocalizedString(@"Done", @"Done button title")
#define DKContactUs NSLocalizedString(@"Contact Us", @"Contact Us button title")
#define DKSend NSLocalizedString(@"Send", comment: @"Send button title")
#define DKYourName NSLocalizedString(@"Your Name", comment: @"The user's full name")
#define DKYourEmail NSLocalizedString(@"Your Email", comment: @"The user's email")
#define DKSubject NSLocalizedString(@"Subject", comment: @"The subject of the message in Contact Us form")
#define DKDefaultSubject NSLocalizedString(@"Feedback via iOS app", comment: @"Default subject for Contact Us")
#define DKMessage NSLocalizedString(@"Message", comment: @"Placeholder for the message to be sent")

#define DKError NSLocalizedString(@"Error", @"Error alert title")
#define DKNoResults NSLocalizedString(@"No Results", @"No Results alert title")
#define DKSearchAllArticles NSLocalizedString(@"Search All Articles", @"Placeholder text for search bar on topics screen")
#define DKSearchArticlesInTopic NSLocalizedString(@"Search Articles in Topic", @"Placeholder text for search bar on articles screen")
#define DKNoArticlesResultsMessage NSLocalizedString(@"There are no articles matching that search. Please try again with a different search.", @"No results message body")
#define DKOptional NSLocalizedString(@"Optional", @"Indicates that a certain input field is optional")

#pragma mark - Error Messages

#define DKErrorMessageNetworkFailed NSLocalizedString(@"Failed to load content. Please ensure you are connected to the internet and try again.", @"Error displayed when a network error occurs.")
#define DKErrorMessageContactUsFailed NSLocalizedString(@"Failed to send message. Please ensure you are connected to the internet and try again.", @"Error displayed when a network error occurs trying to contact us.")