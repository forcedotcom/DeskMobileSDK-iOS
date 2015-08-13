//
//  DKTopicsViewController.m
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

#import "DKTopicsViewController.h"
#import "DKSession.h"
#import "UIAlertController+Additions.h"
#import "DKNavigationBarTitleView.h"
#import "DKSettings.h"

NSString *const DKTopicsViewControllerId = @"DKTopicsViewController";
static NSString *const DKArticlesSegueId = @"DKArticlesSegue";

@interface DKTopicsViewController ()

@property (nonatomic, strong) NSCache *cachedArticlesViewModels;

- (void)setupAppearances;
- (void)setupSearchBar;
- (DKArticlesTopicViewModel *)cachedArticlesViewModelFromTopicName:(id)topicName;
- (void)setCachedArticlesViewModel:(DKArticlesTopicViewModel *)articleViewModel topicName:(id)topicName;

@end

@implementation DKTopicsViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initializing the viewmodel here so it's ready by the time the superclass's viewDidLoad is called
        self.viewModel = [DKTopicsViewModel new];
        self.cachedArticlesViewModels = [NSCache new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupAppearances];
    [self setupSearchBar];
    [self invalidateArticleCache];
}

#pragma mark - Setup

- (void)setupAppearances
{
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)setupSearchBar
{
    [super setupSearchBar];
    [super setSearchBarPlaceholder:DKSearchAllArticles];
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    UIView *titleView = [[DKNavigationBarTitleView alloc] initWithIconImage:[DKSettings sharedInstance].topNavIcon
                                                                      title:self.title];

    self.navigationItem.titleView = titleView;
}

#pragma mark - Article View Model Caching

- (void)invalidateArticleCache
{
    [self.cachedArticlesViewModels removeAllObjects];
}

- (DKArticlesTopicViewModel *)cachedArticlesViewModelFromTopicName:(id)topicName
{
    return [self.cachedArticlesViewModels objectForKey:topicName];
}

- (void)setCachedArticlesViewModel:(DKArticlesTopicViewModel *)articlesViewModel topicName:(id)topicName
{
    [self.cachedArticlesViewModels setObject:articlesViewModel
                                      forKey:topicName];
}

- (DKArticlesTopicViewModel *)viewModelWithTopic:(DSAPITopic *)topic
{
    NSString *topicName = [topic valueForKey:DKTopicNameKey];
    DKArticlesTopicViewModel *viewModel;
    
    // Look to see if we have it in cache, if not create new one and cache it.
    if (!(viewModel = [self cachedArticlesViewModelFromTopicName:topicName])) {
        viewModel = [DKArticlesTopicViewModel new];
        viewModel.topic = topic;
        [self setCachedArticlesViewModel:viewModel
                               topicName:topicName];
    }
    return viewModel;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [super searchBarSearchButtonClicked:searchBar];
    if ([self.delegate respondsToSelector:@selector(topicsViewController:didSearchTerm:)]) {
        NSString *text = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self.delegate topicsViewController:self didSearchTerm:text];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(topicsViewController:didSelectTopic:articlesTopicViewModel:)]) {
        DSAPITopic *topic = (DSAPITopic *)[self.viewModel itemAtIndexPath:indexPath];
        DKArticlesTopicViewModel *viewModel = [self viewModelWithTopic:topic];
        
        [self.delegate topicsViewController:self didSelectTopic:topic articlesTopicViewModel:viewModel];
    }
}

@end
