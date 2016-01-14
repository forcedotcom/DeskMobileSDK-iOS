//
//  DKListViewController.m
//  DeskKit
//
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

#import "DKListViewController.h"
#import "DKSearchResultsViewController.h"

#import "UIAlertController+Additions.h"
#import "DKConstants.h"
#import "DKSettings.h"

#pragma mark - private constants

static NSString *const DKListCellId = @"DKListCell";

@interface DKListViewController ()

@property (nonatomic) UISearchController *searchController;

@end

@implementation DKListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.viewModel.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.viewModel cancelFetch];
}

- (void)beginLoadingData
{
    [self.viewModel fetchItemsInSection:0];
}

- (void)setupSearchWithResultsViewController:(DKSearchResultsViewController *)resultsViewController
{
    self.resultsViewController = resultsViewController;
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:resultsViewController];
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.tableView.frame), DKSearchBarHeight);
    self.searchController.searchBar.barTintColor = [[DKSettings sharedInstance] topNavBarTintColor];
    self.searchController.searchBar.tintColor = [[DKSettings sharedInstance] topNavTintColor];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
}

- (void)setSearchBarPlaceholder:(NSString *)placeholder
{
    self.searchController.searchBar.placeholder = placeholder;
}

- (void)setSearchBarSearchTerm:(NSString *)searchTerm
{
    self.searchController.searchBar.text = searchTerm;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.resultsViewController reset];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""]) {
        [self.resultsViewController reset];
    }
}


#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.viewModel.totalPages;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.viewModel numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DKListCellId];
    cell.textLabel.text = [self.viewModel textForDisplayAtIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger middleRowOfSection = [self.viewModel numberOfItemsInSection:indexPath.section] / 2;
    if (indexPath.row == middleRowOfSection) {
        NSUInteger nextSection = indexPath.section + 1;
        [self.viewModel fetchItemsInSection:nextSection];
    }
}

#pragma mark - DKListViewModelDelegate

- (void)viewModel:(id)viewModel didFetchPage:(DSAPIPage *)page
{
    [self.tableView reloadData];
}

- (void)viewModel:(DKListViewModel *)viewModel fetchDidFailOnPageNumber:(NSNumber *)pageNumber
{
    UIAlertController *alertController = [UIAlertController alertWithTitle:DKError text:DKErrorMessageNetworkFailed];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
