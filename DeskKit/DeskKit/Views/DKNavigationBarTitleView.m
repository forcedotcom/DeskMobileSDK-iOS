//
//  DKNavigationBarTitleView.m
//  DeskKit
//
//  Created by Desk.com on 12/8/14.
//  Copyright (c) 2015, Salesforce.com, Inc.
//  All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided
//  that the following conditions are met:
//  
//     Redistributions of source code must retain the above copyright notice, this list of conditions and the
//     following disclaimer.
//  
//     Redistributions in binary form must reproduce the above copyright notice, this list of conditions and
//     the following disclaimer in the documentation and/or other materials provided with the distribution.
//  
//     Neither the name of Salesforce.com, Inc. nor the names of its contributors may be used to endorse or
//     promote products derived from this software without specific prior written permission.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
//  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
//  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//

#import "DKNavigationBarTitleView.h"
#import "DKSettings.h"

@interface DKNavigationBarTitleView ()

- (void)addConstraintsForLabel:(UILabel *)label nextToImageView:(UIImageView *)imageView;

@end

@implementation DKNavigationBarTitleView

- (instancetype)initWithIconImage:(UIImage *)icon title:(NSString *)title
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:imageView];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.text = title;
        label.textColor = [[DKSettings sharedInstance] topNavTintColor];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [label sizeToFit];
        [self addSubview:label];
        [self addConstraintsForLabel:label nextToImageView:imageView];
        CGSize size = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        self.frame = CGRectMake(0, 0, size.width, size.height);
    }
    return self;
}

- (void)addConstraintsForLabel:(UILabel *)label nextToImageView:(UIImageView *)imageView
{
    NSDictionary *views = NSDictionaryOfVariableBindings(imageView, label);

    NSString *horizontalVisualFormat;
    NSString *verticalVisualFormat;

    if (imageView.image) {
        horizontalVisualFormat = @"H:|-8-[imageView]-8-[label]-8-|";
        verticalVisualFormat = @"V:|[imageView]|";
    } else {
        horizontalVisualFormat = @"H:|-8-[label]-8-|";
        verticalVisualFormat = @"V:|[label]|";
    }

    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:horizontalVisualFormat
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:nil
                                                                               views:views];
    [self addConstraints:horizontalConstraints];
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:verticalVisualFormat
                                                                           options:NSLayoutFormatAlignAllLeft
                                                                           metrics:nil
                                                                             views:views];
    [self addConstraints:verticalConstraints];
}

@end
