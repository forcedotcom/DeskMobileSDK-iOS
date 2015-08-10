//
//  DKContactUsTableViewController.m
//  DeskKit
//
//  Created by Noel Artiles on 7/28/15.
//  Copyright (c) 2015 Desk.com. All rights reserved.
//

#import "DKContactUsViewController.h"
#import "DKContactUsViewModel.h"
#import "DKContactUsTextFieldTableViewCell.h"
#import "DKContactUsTextViewTableViewCell.h"
#import "DKConstants.h"
#import "UIAlertController+Additions.h"

#define DKMessageSent NSLocalizedString(@"Message Sent", comment: @"Message Sent title")
#define DKMessageSentText NSLocalizedString(@"Thank you for contacting us. We will get back to you as soon as possible.", comment: @"Message Sent body.")

NSString *const DKContactUsViewControllerId = @"DKContactUsViewController";
static CGFloat standardCellHeight = 44.0; // This matches the contraint in storyboard.

@interface DKContactUsViewController () <UITextViewDelegate>

@property (nonatomic) DKContactUsViewModel *viewModel;
@property (nonatomic) UIBarButtonItem *sendButton;
@property (nonatomic) UIBarButtonItem *cancelButton;
@property (nonatomic) NSLayoutConstraint *textViewCellHeightContraint;
@property (nonatomic) UITableViewCell *messageCell;
@property (nonatomic) UITextView *textView;
@property (nonatomic) CGFloat keyboardOverlap;
@property (nonatomic) NSOperationQueue *APICallbackQueue;
@property (nonatomic) NSURLSessionDataTask *createCaseTask;
@property (nonatomic) BOOL isUIReadOnly;

@end

@implementation DKContactUsViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _keyboardOverlap = 0;
        _isUIReadOnly = NO;
        _APICallbackQueue = [NSOperationQueue new];
        [self setupNavigationItem];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViewModel];
    self.sendButton.enabled = [self shouldEnableSendButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self registerKeyboardNotifications];
    [self registerForUITextFieldNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self unRegisterKeyboardNotfications];
    [self unRegisterForUITextFieldNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupViewModel
{
    NSAssert(self.toEmailAddress, @"toEmailAddress cannot be nil");
    
    self.viewModel = [[DKContactUsViewModel alloc] initIncludingOptionalItems:self.showAllOptionalItems];
    self.viewModel.userIdentity = self.userIdentity;
    self.viewModel.subject = self.subject;
    self.viewModel.toEmailAddress = self.toEmailAddress;
    
    self.viewModel.includeYourNameItem = self.showYourNameItem;
    self.viewModel.includeYourEmailItem = self.showYourEmailItem;
    self.viewModel.includeSubjectItem = self.showSubjectItem;

}

- (CGFloat)messageCellHeight
{
    NSAttributedString *text = self.textView.attributedText;
    CGSize containerSize = self.textView.textContainer.size;
    CGFloat padding = self.messageCell.contentView.bounds.size.height - containerSize.height;
    CGSize boundingSize = CGSizeMake(containerSize.width, CGFLOAT_MAX);

    CGFloat textHeight = ceilf([text boundingRectWithSize:boundingSize options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height);
    CGFloat minHeight = [self minimumTextViewCellHeight];
    [self.textView setNeedsDisplay];
    if (textHeight + padding > minHeight) {
        return ceilf(textHeight + padding);
    } else {
        return minHeight;
    }
}

- (CGFloat)minimumTextViewCellHeight
{
    __block NSUInteger standardCellCount = 0;
    [self.viewModel.sections enumerateObjectsUsingBlock:^(NSArray *section, NSUInteger idx, BOOL *stop) {
        [section enumerateObjectsUsingBlock:^(DKContactUsItem *item, NSUInteger idx, BOOL *stop) {
            if (item.cellId != DKContactUsTextViewTableViewCellId) {
                standardCellCount++;
            }
        }];
    }];
    
    CGFloat totalHeight = CGRectGetHeight(self.tableView.bounds) - self.topLayoutGuide.length - self.keyboardOverlap;
    CGFloat totalStandardCellsHeight = standardCellHeight * standardCellCount;
    
    CGFloat minHeight = totalHeight - totalStandardCellsHeight;
    
    return minHeight;
}

- (UITableViewCell *)configureTextFieldCell:(DKContactUsTextFieldTableViewCell *)cell item:(DKContactUsInputTextItem *)item
{
    cell.textField.enabled = !self.isUIReadOnly;
    cell.textField.attributedText = item.text;
    cell.textField.attributedPlaceholder = item.placeholderText;
    
    return cell;
}

- (UITableViewCell *)configureTextViewCell:(DKContactUsTextViewTableViewCell *)cell item:(DKContactUsInputTextItem *)item
{
    self.messageCell = cell;
    self.textView = cell.textView;
    
    self.textView.editable = !self.isUIReadOnly;
    self.textView.attributedText = item.text;
    self.textView.delegate = self;
    
    return cell;
}

- (void)updateSendButtonAndUpdateText:(NSAttributedString *)text indexPath:(NSIndexPath *)indexPath
{
    [self.viewModel updateText:text indexPath:indexPath];
    self.sendButton.enabled = [self shouldEnableSendButton];
}

- (BOOL)shouldEnableSendButton
{
    return [self.viewModel isValidEmailCase];
}

- (void)makeUIReadOnly:(BOOL)readOnly
{
    self.isUIReadOnly = readOnly;
    self.sendButton.enabled = readOnly ? NO : [self shouldEnableSendButton];
    [self.tableView reloadData];
}

- (NSIndexPath *)indexPathWithTextField:(UITextField *)textField
{
    __block NSIndexPath *indexPath = nil;
    [self.viewModel.sections enumerateObjectsUsingBlock:^(NSArray *section, NSUInteger sectionIndex, BOOL *stop) {
        [section enumerateObjectsUsingBlock:^(DKContactUsItem *item, NSUInteger rowIndex, BOOL *stop) {
            NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:currentIndexPath];
            if ([textField isDescendantOfView:cell]) {
                indexPath = currentIndexPath;
                *stop = YES;
            }
        }];
        if (indexPath) {
            *stop = YES;
        }
    }];
    return indexPath;
}

#pragma mark - Navigation Item

- (void)setupNavigationItem
{
    self.sendButton = [[UIBarButtonItem alloc] initWithTitle:DKSend
                                                       style:UIBarButtonItemStyleDone
                                                      target:self
                                                      action:@selector(sendButtonTapped:)];
    self.cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                      target:self
                                                                      action:@selector(cancelButtonTapped:)];
    self.navigationItem.title = DKContactUs;
    self.navigationItem.rightBarButtonItem = self.sendButton;
    self.navigationItem.leftBarButtonItem = self.cancelButton;
}

- (void)sendButtonTapped:(id)sender
{
    [self resignFirstResponder];
    [self makeUIReadOnly:YES];
    self.createCaseTask = [self.viewModel createEmailCaseWithQueue:self.APICallbackQueue
                                                           success:^(DSAPICase *newCase) {
                                                               [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                                   UIAlertController *alertController = [UIAlertController alertWithTitle:DKMessageSent text:DKMessageSentText handler:^(UIAlertAction *action) {
                                                                       [self.delegate contactUsViewControllerDidSendMessage:self];
                                                                   }];
                                                                   [self presentViewController:alertController animated:YES completion:nil];
                                                               }];
                                                           }
                                                           failure:^(NSHTTPURLResponse *response, NSError *error) {
                                                               [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                                   [self makeUIReadOnly:NO];
                                                                   UIAlertController *alertController = [UIAlertController alertWithTitle:DKError text:DKErrorMessageContactUsFailed];
                                                                   [self presentViewController:alertController animated:YES completion:nil];
                                                               }];
                                                           }];

}

- (void)cancelButtonTapped:(id)sender
{
    [self.createCaseTask cancel];
    
    [self.delegate contactUsViewControllerDidCancel:self];
}

#pragma mark - UITextFieldDelegate and Notifications

- (void)registerForUITextFieldNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(textFieldDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)unRegisterForUITextFieldNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)textFieldDidChangeNotification:(NSNotification *)notification
{
    UITextField *textField = notification.object;
    [self updateSendButtonAndUpdateText:textField.attributedText indexPath:[self indexPathWithTextField:textField]];
}


#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self.tableView beginUpdates];
    [self.tableView endUpdates];

    CGRect oldRect = textView.frame;
    textView.frame = CGRectMake(oldRect.origin.x, oldRect.origin.y, oldRect.size.width, [self messageCellHeight]);
    textView.selectedRange = [textView selectedRange];
    
    [self updateSendButtonAndUpdateText:textView.attributedText indexPath:self.viewModel.messageIndexPath];
    // TODO: Check performance and slow network connection.
}

#pragma mark - Keyboard

- (void)registerKeyboardNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardDidShowNotification:) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unRegisterKeyboardNotfications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [center removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidShowNotification:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGRect endRect = [self.tableView convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
    
    self.keyboardOverlap = CGRectGetHeight(endRect);
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)keyboardWillHideNotification:(NSNotification *)notification
{
    self.keyboardOverlap = 0;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel.sections[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DKContactUsInputTextItem *item = self.viewModel.sections[indexPath.section][indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item.cellId forIndexPath:indexPath];
    if ([item.cellId isEqualToString:DKContactUsTextFieldTableViewCellId]) {
        [self configureTextFieldCell:(DKContactUsTextFieldTableViewCell *)cell item:item];
    } else if ([item.cellId isEqualToString:DKContactUsTextViewTableViewCellId]) {
        [self configureTextViewCell:(DKContactUsTextViewTableViewCell *)cell item:item];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DKContactUsItem *item = self.viewModel.sections[indexPath.section][indexPath.row];
    if ([item.cellId isEqualToString:DKContactUsTextViewTableViewCellId]) {
        return [self messageCellHeight];
    } else {
        return standardCellHeight;
    }
}

@end
