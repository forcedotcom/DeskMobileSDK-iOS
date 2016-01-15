//
//  DKArticlesViewController.m
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

#import "DKArticlesViewController.h"
#import "DKSearchResultsViewController.h"
#import "DKArticleDetailViewController.h"

#import "DKSession.h"

NSString *const DKArticlesViewControllerId = @"DKArticlesViewController";

@interface DKArticlesViewController ()<DKSearchResultsViewControllerDelegate>

@property (nonatomic) DKArticlesTopicViewModel *viewModel;

@end

@implementation DKArticlesViewController

@dynamic viewModel;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initializing the viewmodel here so it's ready by the time the superclass's viewDidLoad is called
        self.viewModel = [DKArticlesTopicViewModel new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSearch];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self beginLoadingData];
}

- (void)setupSearch
{
    self.resultsViewController = [DKSession newSearchResultsViewController];
    self.resultsViewController.delegate = self;
    [self setupSearchWithResultsViewController:self.resultsViewController];
    [self setSearchBarPlaceholder:DKSearchArticlesInTopic];
}

- (void)setViewModel:(DKArticlesTopicViewModel *)viewModel topic:(DSAPITopic *)topic;
{
    self.title = [topic valueForKey:DKTopicNameKey];
    self.viewModel = viewModel;
    self.viewModel.topic = topic;
}

- (void)sendDelegateSearchTerm:(NSString *)searchTerm
{
    if ([self.delegate respondsToSelector:@selector(articlesViewController:didSearchTerm:)]) {
        [self.delegate articlesViewController:self didSearchTerm:searchTerm];
    }
}

- (BOOL)hasTopic
{
    return self.viewModel.topic != nil;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [super searchBarSearchButtonClicked:searchBar];
    NSString *text = [self.resultsViewController textFromSearchBar:searchBar];
    [self sendDelegateSearchTerm:text];
    [self.resultsViewController resetSearchWithSearchTerm:text topic:self.viewModel.topic];
}

#pragma mark - DKSearchResultsViewControllerDelegate

- (void)searchResultsViewController:(DKSearchResultsViewController *)searchResultsViewController didSelectArticle:(DSAPIArticle *)article
{
    if ([self.delegate respondsToSelector:@selector(articlesViewController:didSelectSearchedArticle:)]) {
        [self.delegate articlesViewController:self didSelectSearchedArticle:article];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.delegate respondsToSelector:@selector(articlesViewController:didSelectArticle:)]) {
        DSAPIArticle *article = (DSAPIArticle *)[self.viewModel itemAtIndexPath:indexPath];
        [self.delegate articlesViewController:self didSelectArticle:article];
    }
}

@end
