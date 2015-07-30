//
//  DKContactUsLabelItem.m
//  DeskKit
//
//  Created by Noel Artiles on 7/28/15.
//  Copyright (c) 2015 Desk.com. All rights reserved.
//

#import "DKContactUsInputTextItem.h"

@interface DKContactUsInputTextItem ()

@property (nonatomic) BOOL required;

@end

@implementation DKContactUsInputTextItem

- (instancetype)initWithCellID:(NSString *)cellID
                          text:(NSAttributedString *)text
               placeHolderText:(NSAttributedString *)placeholder
                      required:(BOOL)required
{
    self = [super initWithCellID:cellID];
    if (self) {
        _text = text;
        _placeholderText = placeholder;
        _required = required;
    }
    return self;
}

@end
