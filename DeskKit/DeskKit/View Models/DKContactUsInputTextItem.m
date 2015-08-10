//
//  DKContactUsLabelItem.m
//  DeskKit
//
//  Created by Noel Artiles on 7/28/15.
//  Copyright (c) 2015 Desk.com. All rights reserved.
//

#import "DKContactUsInputTextItem.h"
#import "DKConstants.h"

@interface DKContactUsInputTextItem ()

@property (nonatomic) BOOL required;

@end

@implementation DKContactUsInputTextItem

- (instancetype)initWithCellId:(NSString *)cellId
                          text:(NSAttributedString *)text
               placeHolderText:(NSAttributedString *)placeholder
                      required:(BOOL)required
{
    self = [super initWithCellId:cellId];
    if (self) {
        _text = text;
        _placeholderText = placeholder;
        _required = required;
    }
    return self;
}

- (NSAttributedString *)placeholderText
{
    if (_required) {
        return _placeholderText;
    } else {
        NSString *newString = [NSString stringWithFormat:@"%@ (%@)", _placeholderText.string, DKOptional];
        return [[NSAttributedString alloc] initWithString:newString];
    }

}

@end
