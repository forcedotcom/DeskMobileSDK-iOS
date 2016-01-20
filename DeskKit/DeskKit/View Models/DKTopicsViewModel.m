//
//  DKTopicsViewModel.m
//  DeskKit
//
//  Created by Desk.com on 9/10/14.
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

#import "DKTopicsViewModel.h"
#import "DKAPIManager.h"

NSString *const DKInSupportCenterKey = @"in_support_center";

@interface DKTopicsViewModel ()

- (NSDictionary *)parametersForPageNumber:(NSNumber *)pageNumber
                                  perPage:(NSNumber *)perPage;

@end

@implementation DKTopicsViewModel

- (NSDictionary *)parametersForPageNumber:(NSNumber *)pageNumber
                                  perPage:(NSNumber *)perPage
{
    return @{ kPageKey : pageNumber,
              kPerPageKey : perPage,
              DKInSupportCenterKey : @YES,
              DKSortFieldKey : DKTopicPositionKey,
              DKSortDirectionKey : DKSortDirectionAsc };
}

- (NSURLSessionDataTask *)fetchItemsOnPageNumber:(NSNumber *)pageNumber
                                         perPage:(NSNumber *)perPage
                                           queue:(NSOperationQueue *)queue
                                         success:(DSAPIPageSuccessBlock)success
                                         failure:(DSAPIFailureBlock)failure
{
    if (self.shouldAddBrandContext) {
        return [self.brand listTopicsWithParameters:[self parametersForPageNumber:pageNumber
                                                                          perPage:perPage]
                                              queue:queue
                                            success:success
                                            failure:failure];
    } else {
        return [DSAPITopic listTopicsWithParameters:[self parametersForPageNumber:pageNumber
                                                                          perPage:perPage]
                                             client:[DKAPIManager sharedInstance].client
                                              queue:queue
                                            success:success
                                            failure:failure];
    }
}

- (NSString *)textForDisplayAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self itemAtIndexPath:indexPath] valueForKey:DKTopicNameKey];
}

@end
