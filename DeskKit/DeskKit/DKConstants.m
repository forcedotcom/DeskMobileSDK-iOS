//
//  DKConstants.m
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

#import "DKConstants.h"

#pragma mark - Lists

NSInteger const DKItemsPerPage = 50;

#pragma mark - Model Fields

NSString *const DKTopicNameKey = @"name";
NSString *const DKTopicPositionKey = @"position";
NSString *const DKArticleSubjectKey = @"subject";
NSString *const DKArticlePublicURLKey = @"public_url";
NSString *const DKArticleBodyKey = @"body";
NSString *const DKArticlePrivateSearchKey = @"private_search";
NSString *const DKArticlePositionKey = @"position";

#pragma mark - API Parameters

NSString *const DKFieldsKey = @"fields";
NSString *const DKSortFieldKey = @"sort_field";
NSString *const DKSortDirectionKey = @"sort_direction";
NSString *const DKSortDirectionAsc = @"asc";
NSString *const DKSortDirectionDesc = @"desc";
NSString *const DKTopicIdsKey = @"topic_ids";
NSString *const DKTopicIdKey = @"id";
NSString *const DKBrandIdsKey = @"brand_ids";

#pragma mark - UI

CGFloat const DKSearchBarHeight = 44.f;
