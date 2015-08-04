//
//  DKContactUsLabelItem.h
//  DeskKit
//
//  Created by Noel Artiles on 7/28/15.
//  Copyright (c) 2015 Desk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DKContactUsItem.h"

@interface DKContactUsInputTextItem : DKContactUsItem

@property (nonatomic) NSAttributedString *text;
@property (nonatomic) NSAttributedString *placeholderText;
@property (nonatomic, readonly) BOOL required;

- (instancetype)initWithCellID:(NSString *)cellID
                          text:(NSAttributedString *)text
               placeHolderText:(NSAttributedString *)placeholder
                      required:(BOOL)required;
@end
