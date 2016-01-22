//
//  DKSearchResultsViewController.m
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

#import "DKSearchResultsViewController.h"
#import "DKArticlesSearchViewModel.h"

#import "UIAlertController+Additions.h"

#define DKSearchResultsPrefix NSLocalizedString(@"Search Results: ", @"Prefix displayed before the search term when displaying search results")

NSString *const DKSearchResultsViewControllerId = @"DKSearchResultsViewController";

@interface DKSearchResultsViewController ()

@property (nonatomic) DKArticlesSearchViewModel *viewModel;

@end

@implementation DKSearchResultsViewController

@dynamic viewModel;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initializing the viewmodel here so it's ready by the time the superclass's viewDidLoad is called
        self.viewModel = [DKArticlesSearchViewModel new];
        self.viewModel.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSearchTerm:(NSString *)searchTerm topic:(DSAPITopic *)topic
{
    self.title = [DKSearchResultsPrefix stringByAppendingString:searchTerm];
    self.viewModel.searchTerm = searchTerm;
    self.viewModel.topic = topic;
}

- (void)resetSearchWithSearchTerm:(NSString *)searchTerm topic:(DSAPITopic *)topic
{
    [self.viewModel reset];
    [self setSearchTerm:searchTerm topic:topic];
    [self beginLoadingData];
}

- (void)reset
{
    [self.viewModel reset];
    [self.tableView reloadData];
}

- (NSString *)textFromSearchBar:(UISearchBar *)searchBar
{
    return [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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
    return [self hasSearchTerm];
}

- (BOOL)hasSearchTerm
{
    return self.viewModel.searchTerm.length > 0;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.delegate respondsToSelector:@selector(searchResultsViewController:didSelectArticle:)]) {
        DSAPIArticle *article = (DSAPIArticle *)[self.viewModel itemAtIndexPath:indexPath];
        [self.delegate searchResultsViewController:self didSelectArticle:article];
    }
}
@end
