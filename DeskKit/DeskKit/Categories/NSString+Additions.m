//
//  NSString+Additions.m
//  DeskKit
//
//  Created by Noel Artiles on 8/5/15.
//  Copyright (c) 2015 Desk.com. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

+ (BOOL)dkIsEmptyString:(NSString *)string
{
    return string == nil || [string isEqualToString:@""];
}

+ (BOOL)dkIsNotEmptyString:(NSString *)string
{
    return ![[self class] dkIsEmptyString:string];
}

@end
