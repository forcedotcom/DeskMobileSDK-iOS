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
    self = [self initIncludingOptionalItems:YES];
    if (self) {

    }
    return self;
}

- (instancetype)initIncludingOptionalItems:(BOOL)include
{
    self = [super init];
    if (self) {
        _includeAllOptionalItems = include;
    }
    return self;
}

- (NSArray *)createStaticLabelItems
{
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:4];
    
    if (self.includeAllOptionalItems || self.includeYourNameItem) {
        DKContactUsInputTextItem *name = [[DKContactUsInputTextItem alloc] initWithCellID:DKContactUsTextFieldTableViewCellID
                                                                                     text:nil
                                                                          placeHolderText:[[NSAttributedString alloc] initWithString:@"Your Name"]
                                                                                 required:NO];
        [items addObject:name];
    }
    
    DKContactUsInputTextItem *email = [[DKContactUsInputTextItem alloc] initWithCellID:DKContactUsTextFieldTableViewCellID
                                                                          text:nil
                                                               placeHolderText:[[NSAttributedString alloc] initWithString:@"Your Email"]
                                                                      required:YES];
    [items addObject:email];
    
    if (self.includeAllOptionalItems || self.includeSubjectItem) {
        DKContactUsInputTextItem *subject = [[DKContactUsInputTextItem alloc] initWithCellID:DKContactUsTextFieldTableViewCellID
                                                                                        text:nil
                                                                             placeHolderText:[[NSAttributedString alloc] initWithString:@"Subject"]
                                                                                    required:NO];
        [items addObject:subject];
    }
    
    DKContactUsInputTextItem *message = [[DKContactUsInputTextItem alloc] initWithCellID:DKContactUsTextViewTableViewCellID
                                                                            text:nil
                                                                 placeHolderText:[[NSAttributedString alloc] initWithString:@"Message"]
                                                                        required:YES];
    [items addObject:message];
    
    self.messageIndexPath = [NSIndexPath indexPathForRow:[items indexOfObject:message] inSection:0];
    return [items copy];
}

- (NSArray *)sections
{
    if (_sections == nil) {
        _sections = @[[self createStaticLabelItems]];
    }
    
    return _sections;
}



@end
