//
//  DKContactUsAlertController.m
//  DeskKit
//
//  Created by Desk.com on 9/29/14.
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

#import "DKContactUsAlertController.h"
#import "DKConstants.h"
#import "DKSession.h"

#define DKCallUs NSLocalizedString(@"Call Us", @"Call Us button title")
#define DKEmailUs NSLocalizedString(@"Email Us", @"Email Us button title")

@interface DKContactUsAlertController ()

@property (nonatomic) BOOL hasEmailUsAction;

@property (nonatomic, weak) UIAlertAction *emailUsAction;

@end

@implementation DKContactUsAlertController

+ (instancetype)contactUsAlertController
{
    DKContactUsAlertController *contactUsSheet = [DKContactUsAlertController alertControllerWithTitle:DKContactUs
                                                                                              message:nil
                                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    
    [contactUsSheet addCancelButton];
    [contactUsSheet addCallUsButton];
    return contactUsSheet;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addEmailUsButton];
}

- (void)addCancelButton
{
    [self addAction:[UIAlertAction actionWithTitle:DKCancel
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
}

- (void)addCallUsButton;
{
    if ([[DKSession sharedInstance] hasContactUsPhoneNumber]) {
        [self addCallUsAction];
    }
}

- (void)addCallUsAction
{
    [self addAction:[UIAlertAction actionWithTitle:DKCallUs
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action) {
                                               [[UIApplication sharedApplication] openURL:[DKSession sharedInstance].contactUsPhoneNumberUrl];
                                           }]];
}

- (void)addEmailUsButton
{
    [self addEmailUsAction];
    self.emailUsAction.enabled = NO;
    [[DKSession sharedInstance] hasContactUsEmailAddressWithCompletionHandler:^(BOOL hasContactUsEmailAddress) {
        self.emailUsAction.enabled = hasContactUsEmailAddress;
    }];
}

- (void)addEmailUsAction
{
    if (!self.hasEmailUsAction) {
        self.emailUsAction = [UIAlertAction actionWithTitle:DKEmailUs
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) {
                                                        if ([self.delegate respondsToSelector:@selector(alertControllerDidTapSendEmail)]) {
                                                            [self.delegate alertControllerDidTapSendEmail];
                                                        }
                                                    }];
        [self addAction:self.emailUsAction];
        self.hasEmailUsAction = YES;
    }
}

@end
