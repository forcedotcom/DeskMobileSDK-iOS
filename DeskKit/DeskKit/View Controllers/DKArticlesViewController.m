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
#import "DKArticleDetailViewController.h"
#import "DKArticlesSearchViewModel.h"
#import "UIAlertController+Additions.h"

#define DKSearchResultsPrefix NSLocalizedString(@"Search Results: ", @"Prefix displayed before the search term when displaying search results")

NSString *const DKArticlesViewControllerId = @"DKArticlesViewController";

@interface DKArticlesViewController ()

@property (nonatomic, weak) DKArticlesViewModel *viewModel;
@property (nonatomic, strong) DKArticlesTopicViewModel *topicViewModel;
@property (nonatomic, strong) DKArticlesSearchViewModel *searchViewModel;

- (void)setupSearchBar;
- (NSString *)searchBarPlaceholderText;
- (void)sendDelegateChangeSearchTerm:(NSString *)searchTerm;
- (void)resetSearchWithSearchTerm:(NSString *)searchTerm;
- (void)cancelSearchForArticlesInTopic;
- (BOOL)shouldShowNoSearchResultsMessage;
- (BOOL)userEnteredSearchTerms;
- (BOOL)hasTopic;

@end

@implementation DKArticlesViewController
@dynamic viewModel;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initializing the viewmodel here so it's ready by the time the superclass's viewDidLoad is called
        self.topicViewModel = [DKArticlesTopicViewModel new];
        self.searchViewModel = [DKArticlesSearchViewModel new];
        self.searchViewModel.delegate = self;
        self.viewModel = self.topicViewModel;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSearchBar];
}

- (void)setupSearchBar
{
    [super setupSearchBar];
    [self setSearchBarPlaceholder:self.searchBarPlaceholderText];
    if (self.searchViewModel.searchTerm) {
        [super setSearchBarSearchTerm:self.searchViewModel.searchTerm];
    }
}

- (NSString *)searchBarPlaceholderText
{
    return self.topicViewModel.topic ? DKSearchArticlesInTopic : DKSearchAllArticles;
}

- (void)setViewModel:(DKArticlesTopicViewModel *)viewModel topic:(DSAPITopic *)topic;
{
    self.title = [topic valueForKey:DKTopicNameKey];
    self.topicViewModel = viewModel;
    self.topicViewModel.topic = topic;
    self.viewModel = self.topicViewModel;
    self.searchViewModel.topic = topic;
}

- (void)setSearchTerm:(NSString *)searchTerm
{
    self.title = [DKSearchResultsPrefix stringByAppendingString:searchTerm];
    self.searchViewModel.searchTerm = searchTerm;
    self.viewModel = self.searchViewModel;
    [self sendDelegateChangeSearchTerm:searchTerm];
}

- (void)sendDelegateChangeSearchTerm:(NSString *)searchTerm
{
    if ([self.delegate respondsToSelector:@selector(articlesViewController:didChangeSearchTerm:)]) {
        [self.delegate articlesViewController:self didChangeSearchTerm:searchTerm];
    }
}

- (void)resetSearchWithSearchTerm:(NSString *)searchTerm
{
    [self.searchViewModel reset];
    [self setSearchTerm:searchTerm];
    [self beginLoadingData];
}

- (void)cancelSearchForArticlesInTopic
{
    [self setViewModel:self.topicViewModel topic:self.topicViewModel.topic];
    [self.tableView reloadData];
}


- (void)viewModelDidFetchNoResults:(DKListViewModel *)viewModel
{
    [self.tableView reloadData];
    if ([self shouldShowNoSearchResultsMessage]) {
        UIAlertController *alertController = [UIAlertController alertWithTitle:DKNoResults
                                                                          text:DKNoArticlesResultsMessage
                                                                       handler:nil];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (BOOL)shouldShowNoSearchResultsMessage
{
    return [self userEnteredSearchTerms];
}

- (BOOL)userEnteredSearchTerms
{
    return self.searchViewModel.searchTerm.length > 0;
}

- (BOOL)hasTopic
{
    return self.topicViewModel.topic != nil;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [super searchBarSearchButtonClicked:searchBar];
    [self resetSearchWithSearchTerm:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self cancelSearchForArticlesInTopic];
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
