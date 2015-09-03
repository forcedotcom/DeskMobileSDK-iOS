//
//  DKContactUsItem.m
//  DeskKit
//
//  Created by Noel Artiles on 7/28/15.
//  Copyright (c) 2015 Desk.com. All rights reserved.
//

#import "DKContactUsItem.h"

@implementation DKContactUsItem

- (instancetype)initWithIdentifer:(NSString *)identifier
{
    self = [super init];
    if (self) {
        _identifier = identifier;
    }
    return self;
}
@end
