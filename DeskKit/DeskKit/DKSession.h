//
//  DKSession.h
//  DeskKit
//
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

@import UIKit;
#import <DeskAPIClient/DeskAPIClient.h>
#import "DKTopicsViewController.h"
#import "DKArticlesViewController.h"
#import "DKArticleDetailViewController.h"
#import "DKContactUsViewController.h"

@interface DKSession : NSObject

// Contact Us Phone Number read from DKSettings
@property (nonatomic, readonly, nullable) NSURL *contactUsPhoneNumberURL;

NS_ASSUME_NONNULL_BEGIN
/**
 Starts a DeskKit Session. This method should be called in your app delegate, or in any view controller
 you'll use to display the DeskKit support screens. You only need to call this once, but multiple calls
 have no negative effect if the session has already been started.
 
 @param hostname The Desk.com sitename, e.g. "yoursite.desk.com"
 @param APIToken The API token of the API application found in the site's admin admin
 */
+ (void)startWithHostname:(NSString *)hostname
                 APIToken:(NSString *)APIToken;

/**
 Returns the DeskKit Session singleton
 
 @return The DeskKit Session singleton
 */
+ (instancetype)sharedInstance;

/**
 Tells whether the DeskKit Session is started or not.
 
 @return A boolean indicating whether the session has been started.
 */
+ (BOOL)isSessionStarted;

/**
 New instance of DKTopicsViewController.
 
 @return new instance of DKTopicsViewController.
 */
+ (DKTopicsViewController *)newTopicsViewController;

/**
 New instance of DKArticlesViewController.
 
 @return new instance of DKArticlesViewController.
 */
+ (DKArticlesViewController *)newArticlesViewController;

/**
 New instance of a UIAlertController with Contact Us choices.
 
 @param callHandler Block to execute when Call Us button is tapped.
 @param emailHandler Block to execute when Email Us button is tapped.
 
 @return instance of a UIAlertController.
 */

+ (UIAlertController *)newContactUsAlertControllerWithCallHandler:(void (^)(UIAlertAction *action))callHandler
                                                     emailHandler:(void (^)(UIAlertAction *action))emailHandler;

/**
 New instance of DKContactUsViewController.
 
 @return new instance of DKContactUsViewController.
 */
- (DKContactUsViewController *)newContactUsViewController;

/**
 New instance of DKArticleDetailViewController.
 
 @return new instance of DKArticleDetailViewController.
 */
+ (DKArticleDetailViewController *)newArticleDetailViewController;

NS_ASSUME_NONNULL_END

#pragma mark - Internal Methods

/**
 The following are internal methods used by DeskKit. Generally clients will not need to call these methods.
 */

+ (BOOL)hasContactUsPhoneNumber;
- (nullable NSString *)contactUsToEmailAddress;
- (void)hasContactUsToEmailAddressWithCompletionHandler:(void (^ __nonnull)(BOOL hasContactUsToEmailAddress))completionHandler;

@end
