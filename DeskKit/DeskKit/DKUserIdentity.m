//
//  DKUserIdentity.m
//  DeskKit
//
//  Created by Noel Artiles on 8/3/15.
//  Copyright (c) 2015 Desk.com. All rights reserved.
//

#import "DKUserIdentity.h"

@implementation DKUserIdentity

- (instancetype)initWithEmail:(NSString *)email
{
    self = [super init];
    if (self) {
        _email = email;
    }
    return self;
}

@end
