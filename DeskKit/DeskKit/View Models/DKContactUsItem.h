//
//  DKContactUsItem.h
//  DeskKit
//
//  Created by Noel Artiles on 7/28/15.
//  Copyright (c) 2015 Desk.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DKContactUsItem : NSObject

@property (nonatomic, readonly) NSString *identifier;

- (instancetype)initWithIdentifer:(NSString *)identifier;

@end
