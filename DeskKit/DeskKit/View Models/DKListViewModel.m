//
//  DKListViewModel.m
//  DeskKit
//
//  Created by Desk.com on 9/18/14.
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

#import "DKListViewModel.h"
#import "DKSession.h"
#import "DKSettings.h"

@interface DKListViewModel ()

@property (nonatomic) NSNumber *totalItems;
@property (nonatomic, strong) NSMutableDictionary *loadedPages;
@property (nonatomic) NSOperationQueue *APICallbackQueue;
@property (nonatomic) NSURLSessionDataTask *fetchTask;

@end

@implementation DKListViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self reset];
    }
    return self;
}

- (void)reset
{
    [self cancelFetch];
    self.loadedPages = [NSMutableDictionary new];
    self.totalItems = @0;
    self.APICallbackQueue = [NSOperationQueue new];
}

- (void)cancelFetch
{
    [self.fetchTask cancel];
}

- (NSInteger)totalPages
{
    return (NSInteger)ceil([self.totalItems floatValue] / DKItemsPerPage);
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section
{
    NSInteger remainingItems = [self.totalItems integerValue] - (section * DKItemsPerPage);
    return remainingItems > DKItemsPerPage ? DKItemsPerPage : remainingItems;
}

- (void)fetchItemsInSection:(NSInteger)section
{
    if ([DKSession isSessionStarted]) {
        NSInteger pageNumber = [self pageNumberFromSection:section];
        if ([self shouldFetchItemsOnPageNumber:@(pageNumber)]) {
            [self sendWillFetchPageNumber:@(pageNumber)];
            [self cancelFetch];
            self.fetchTask = [self fetchItemsOnPageNumber:@(pageNumber)
                                                  perPage:@(DKItemsPerPage)
                                                    queue:self.APICallbackQueue
                                                  success:^(DSAPIPage *page) {
                                                      dispatch_sync(dispatch_get_main_queue(), ^{
                                                          [self handleLoadedItemsOnPage:page];
                                                      });
                                                  }
                                                  failure:^(NSHTTPURLResponse *response, NSError *error) {
                                                      dispatch_sync(dispatch_get_main_queue(), ^{
                                                          [self sendFetchDidFailOnPageNumber:@(pageNumber)];
                                                      });
                                                  }];
        }
    }
}

- (BOOL)shouldFetchItemsOnPageNumber:(NSNumber *)pageNumber
{
    if ([self alreadyLoadedItemsOnPageNumber:pageNumber]) {
        return NO;
    }
    if (pageNumber.integerValue == 1) {
        // always load page 1
        return YES;
    }
    return [self pageNumberIsFetchable:pageNumber];
}

- (BOOL)alreadyLoadedItemsOnPageNumber:(NSNumber *)pageNumber
{
    return [self.loadedPages objectForKey:pageNumber] != nil;
}

- (BOOL)pageNumberIsFetchable:(NSNumber *)pageNumber
{
    return (pageNumber.integerValue > 0 && pageNumber.integerValue <= self.totalPages);
}

- (NSURLSessionDataTask *)fetchItemsOnPageNumber:(NSNumber *)pageNumber
                                         perPage:(NSNumber *)perPage
                                           queue:(NSOperationQueue *)queue
                                         success:(DSAPIPageSuccessBlock)success
                                         failure:(DSAPIFailureBlock)failure
{
    // override in subclass
    return nil;
}

- (void)handleLoadedItemsOnPage:(DSAPIPage *)page
{
    self.totalItems = page.totalEntries;
    if ([self.totalItems integerValue] > 0) {
        [self.loadedPages setObject:page forKey:@(page.pageNumber)];
        [self sendDidFetchPage:page];
    } else {
        [self sendNoResults];
    }
}

- (void)sendWillFetchPageNumber:(NSNumber *)pageNumber
{
    if ([self.delegate respondsToSelector:@selector(viewModel:willFetchPageNumber:)]) {
        [self.delegate viewModel:self willFetchPageNumber:pageNumber];
    }
}

- (void)sendDidFetchPage:(DSAPIPage *)page
{
    if ([self.delegate respondsToSelector:@selector(viewModel:didFetchPage:)]) {
        [self.delegate viewModel:self didFetchPage:page];
    }
}

- (void)sendNoResults
{
    if ([self.delegate respondsToSelector:@selector(viewModelDidFetchNoResults:)]) {
        [self.delegate viewModelDidFetchNoResults:self];
    }
}

- (void)sendFetchDidFailOnPageNumber:(NSNumber *)pageNumber
{
    if ([self.delegate respondsToSelector:@selector(viewModel:fetchDidFailOnPageNumber:)]) {
        [self.delegate viewModel:self fetchDidFailOnPageNumber:pageNumber];
    }
}

- (DSAPIResource *)itemAtIndexPath:(NSIndexPath *)indexPath
{
    DSAPIPage *page = [self loadedPageAtIndexPath:indexPath];
    return [page.entries objectAtIndex:indexPath.row];
}

- (NSString *)textForDisplayAtIndexPath:(NSIndexPath *)indexPath
{
    // override in subclass
    return @"";
}

- (DSAPIPage *)loadedPageAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.loadedPages objectForKey:@([self pageNumberFromSection:indexPath.section])];
}

- (NSInteger)pageNumberFromSection:(NSInteger)section
{
    return section + 1;
}

- (NSInteger)sectionFromPageNumber:(NSInteger)pageNumber
{
    return pageNumber - 1;
}

- (BOOL)shouldAddBrandContext
{
    return [DKSettings sharedInstance].hasBrandId;
}

- (DSAPIBrand *)brand
{
    return [[DKSettings sharedInstance] brand];
}

@end
