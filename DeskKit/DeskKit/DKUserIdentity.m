//
//  DKUserIdentity.m
//  DeskKit
//
//  Created by Noel Artiles on 8/3/15.
//  Copyright (c) 2015 Desk.com. All rights reserved.
//

#import "DKUserIdentity.h"
#import "NSString+Additions.h"

@implementation DKUserIdentity

- (instancetype)initWithEmail:(NSString *)email
{
    self = [super init];
    if (self) {
        _email = email;
    }
    return self;
}

- (NSString *)fullName
{
    NSMutableString *name = [NSMutableString new];
    if ([NSString dkIsNotEmptyString:self.givenName]) {
        [name appendString:self.givenName];
    }
    if ([NSString dkIsNotEmptyString:self.familyName]) {
        [name appendString:@" "];
        [name appendString:self.familyName];
    }
    
    return [NSString dkIsNotEmptyString:name] ? [name copy] : nil;
}

@end
