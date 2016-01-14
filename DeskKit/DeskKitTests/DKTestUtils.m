//
//  DKTestUtils.m
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

#import "DKTestUtils.h"
#import "DKAPIManager.h"

#pragma mark - Public Constants

NSTimeInterval const DKDefaultTestTimeout = 5;

#pragma mark - Private Constants

NSString *const DKPListName = @"DeskAPIAuth";
NSString *const DKHostnameKey = @"Hostname";
NSString *const DKAPITokenKey = @"APIToken";

@interface DKTestUtils()

+ (UIStoryboard *)storyboard;

@end

@implementation DKTestUtils

#pragma mark - Public Methods

+ (DKAPIManager *)authorizedAPIManager
{
    NSDictionary *authDictionary = [self authDictionaryFromPlist];
    
    DKAPIManager *manager = [DKAPIManager new];
    
    [manager APIClientWithHostname:authDictionary[DKHostnameKey]
                          APIToken:authDictionary[DKAPITokenKey]];
    
    return manager;
}

+ (NSDictionary *)authDictionaryFromPlist
{
    NSURL *plistURL = [[NSBundle bundleForClass:[self class]] URLForResource:DKPListName withExtension:@"plist"];
    return [NSDictionary dictionaryWithContentsOfURL:plistURL];
}

#pragma mark - ViewController instanitiators

+ (UIStoryboard *)storyboard
{
    return
    [UIStoryboard storyboardWithName:@"DKStoryboard" bundle:[NSBundle bundleForClass:[self class]]];
}

+ (DKTopicsViewController *)topicsViewController
{
    return [[self storyboard] instantiateViewControllerWithIdentifier:@"DKTopicsViewController"];
}

+ (DKArticlesViewController *)articlesViewController
{
    return [[self storyboard] instantiateViewControllerWithIdentifier:@"DKArticlesViewController"];
}

+ (DKArticleDetailViewController *)articleDetailViewController
{
    return [[self storyboard] instantiateViewControllerWithIdentifier:@"DKArticleDetailViewController"];
}

+ (DKSearchResultsViewController *)searchResultsViewController
{
    return [[self storyboard] instantiateViewControllerWithIdentifier:@"DKSearchResultsViewController"];
}

@end
