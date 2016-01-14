//
//  DKSearchResultsViewController.m
//  DeskKit
//
//  Created by Noel Artiles on 1/12/16.
//  Copyright © 2016 Desk.com. All rights reserved.
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
