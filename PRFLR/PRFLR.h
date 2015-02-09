//
//  PRFLR.h
//  PRFLR
//

#import <Foundation/Foundation.h>

@interface PRFLR : NSObject

- (instancetype)initWithSource:(NSString *)source apiKey:(NSString *)apiKey;

- (void)cleanTimers;
- (void)begin:(NSString *)timerName;
- (void)end:(NSString *)timerName info:(NSString *)info;

@end
