//
//  DKContactUsViewModel.m
//  DeskKit
//
//  Created by Noel Artiles on 7/28/15.
//  Copyright (c) 2015 Desk.com. All rights reserved.
//

#import "DKContactUsViewModel.h"

@interface DKContactUsViewModel ()

@property (nonatomic) NSArray *sections;
@property (nonatomic) NSIndexPath *messageIndexPath;

@end

@implementation DKContactUsViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSArray *staticSection = [self createStaticLabelItems];
        _sections = @[staticSection];
    }
    return self;
}

- (NSArray *)createStaticLabelItems
{
    DKContactUsInputTextItem *name = [[DKContactUsInputTextItem alloc] initWithCellID:DKContactUsTextFieldTableViewCellID
                                                                         text:nil
                                                              placeHolderText:[[NSAttributedString alloc] initWithString:@"Your Name"]
                                                                     required:NO];
    DKContactUsInputTextItem *email = [[DKContactUsInputTextItem alloc] initWithCellID:DKContactUsTextFieldTableViewCellID
                                                                          text:nil
                                                               placeHolderText:[[NSAttributedString alloc] initWithString:@"Your Email"]
                                                                      required:YES];
    DKContactUsInputTextItem *subject = [[DKContactUsInputTextItem alloc] initWithCellID:DKContactUsTextFieldTableViewCellID
                                                                            text:nil
                                                                 placeHolderText:[[NSAttributedString alloc] initWithString:@"Subject"]
                                                                        required:NO];
    DKContactUsInputTextItem *message = [[DKContactUsInputTextItem alloc] initWithCellID:DKContactUsTextViewTableViewCellID
                                                                            text:nil
                                                                 placeHolderText:[[NSAttributedString alloc] initWithString:@"Message"]
                                                                        required:YES];
    self.messageIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    return @[name, email, subject, message];
}




@end
