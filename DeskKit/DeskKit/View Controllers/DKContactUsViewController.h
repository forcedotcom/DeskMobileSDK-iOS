//
//  DKContactUsTableViewController.h
//  DeskKit
//
//  Created by Noel Artiles on 7/28/15.
//  Copyright (c) 2015 Desk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DKUserIdentity.h"

extern NSString *const DKContactUsViewControllerId;

@class DKContactUsViewController;

@protocol DKContactUsViewControllerDelegate <NSObject>

- (void)contactUsViewControllerDidSendMessage:(DKContactUsViewController *)viewController;
- (void)contactUsViewControllerDidCancel:(DKContactUsViewController *)viewController;

@end


@interface DKContactUsViewController : UITableViewController

@property (weak, nonatomic) id<DKContactUsViewControllerDelegate> delegate;

// Used to configure initial state. User can override these if exposed through the UI.
@property (nonatomic) DKUserIdentity *userIdentity;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *toEmailAddress;
@property (nonatomic, copy) NSDictionary *customFields;

// These control which rows to show in the UI.
@property (nonatomic) BOOL showAllOptionalItems;
@property (nonatomic) BOOL showYourNameItem;
@property (nonatomic) BOOL showYourEmailItem;
@property (nonatomic) BOOL showSubjectItem;


@end
