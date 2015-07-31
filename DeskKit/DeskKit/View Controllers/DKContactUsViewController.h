//
//  DKContactUsTableViewController.h
//  DeskKit
//
//  Created by Noel Artiles on 7/28/15.
//  Copyright (c) 2015 Desk.com. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const DKContactUsViewControllerID;

@class DKContactUsViewController;

@protocol DKContactUsViewControllerDelegate <NSObject>

- (void)contactUsViewControllerDidSendMessage:(DKContactUsViewController *)viewController;
- (void)contactUsViewControllerDidCancel:(DKContactUsViewController *)viewController;

@end


@interface DKContactUsViewController : UITableViewController

@property (weak, nonatomic) id<DKContactUsViewControllerDelegate> delegate;
@property (nonatomic) BOOL showAllOptionalItems;
@property (nonatomic) BOOL showYourNameItem;
@property (nonatomic) BOOL showSubjectItem;
@property (nonatomic) NSArray *toRecipients;

@end
