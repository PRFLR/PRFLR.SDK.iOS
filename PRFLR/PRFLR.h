//
//  PRFLR.h
//  Example
//
//  Created by Roman on 04/02/15.
//  Copyright (c) 2015 PRFLR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRFLR : NSObject

- (instancetype)initWithSource:(NSString *)source apiKey:(NSString *)apiKey;

- (void)cleanTimers;
- (void)begin:(NSString *)timerName;
- (void)end:(NSString *)timerName info:(NSString *)info;

@end
