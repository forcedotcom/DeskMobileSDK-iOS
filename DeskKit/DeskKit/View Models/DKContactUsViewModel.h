//
//  DKContactUsViewModel.h
//  DeskKit
//
//  Created by Noel Artiles on 7/28/15.
//  Copyright (c) 2015 Desk.com. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "DKContactUsInputTextItem.h"

static NSString *const DKContactUsTextFieldTableViewCellID = @"DKContactUsTextFieldTableViewCell";
static NSString *const DKContactUsTextViewTableViewCellID = @"DKContactUsTextViewTableViewCell";

@interface DKContactUsViewModel : NSObject

@property (nonatomic, readonly) NSArray *sections;
@property (nonatomic, readonly) NSIndexPath *messageIndexPath;

@end
