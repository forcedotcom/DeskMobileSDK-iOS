//
//  DKContactUsLabelItem.h
//  DeskKit
//
//  Created by Noel Artiles on 7/28/15.
//  Copyright (c) 2015 Desk.com. All rights reserved.
//

@import UIKit;

#import "DKContactUsItem.h"

@interface DKContactUsInputTextItem : DKContactUsItem <UITextInputTraits>

@property (nonatomic) NSAttributedString *text;
@property (nonatomic) NSAttributedString *placeholderText;
@property (nonatomic, readonly) BOOL required;

// UITextInputTraits
@property (nonatomic) UITextAutocapitalizationType autocapitalizationType;
@property (nonatomic) UITextAutocorrectionType autocorrectionType;
@property (nonatomic) UITextSpellCheckingType spellCheckingType;
@property (nonatomic) BOOL enablesReturnKeyAutomatically;
@property (nonatomic) UIKeyboardAppearance keyboardAppearance;
@property (nonatomic) UIKeyboardType keyboardType;
@property (nonatomic) UIReturnKeyType returnKeyType;
@property (nonatomic, getter=isSecureTextEntry) BOOL secureTextEntry;

- (instancetype)initWithIdentifier:(NSString *)identifier
                              text:(NSAttributedString *)text
                   placeHolderText:(NSAttributedString *)placeholder
                          required:(BOOL)required;
@end
