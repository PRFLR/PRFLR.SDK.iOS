//
//  PRFLR.m
//  PRFLR
//

#import "PRFLR.h"
#import "GCDAsyncUdpSocket.h"
#include <assert.h>
#include <mach/mach.h>
#include <mach/mach_time.h>
#include <unistd.h>

@implementation NSString (PRFLRTrim)

- (NSString *)substringByTrimmingToLength:(NSUInteger)length
{
    if (length >= self.length) {
        return self;
    }
    return [self substringToIndex:length];
}

@end

@interface PRFLR () <GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *apiKey;

@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
@property (nonatomic, strong) NSMutableDictionary *timers;

@end

@implementation PRFLR

const NSUInteger kOverflowCount = 100;

- (instancetype)initWithSource:(NSString *)source apiKey:(NSString *)apiKey
{
    self = [super init];
    if (!self) {
        return nil;
    }
    NSArray *components = [apiKey componentsSeparatedByString:@"@"];
    NSAssert(components.count == 2, @"API Key should consist of 2 parts separated by '@'");
    apiKey = components[0];
    components = [components[1] componentsSeparatedByString:@":"];
    NSAssert(components.count == 2, @"Invalid format of destination - should be 'host:port'");
    NSString *host = components[0];
    uint16_t port = [components[1] integerValue];
    NSAssert(port != 0, @"Invalid port");
    _source = source;
    _apiKey = apiKey;
    _timers = [NSMutableDictionary dictionaryWithCapacity:kOverflowCount];
    _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                               delegateQueue:dispatch_get_main_queue()];
    [_udpSocket connectToHost:host onPort:port error:nil];
    return self;
}

- (void)cleanTimers
{
    [self.timers removeAllObjects];
}

- (void)begin:(NSString *)timerName
{
    if (self.timers.count > kOverflowCount) {
        [self cleanTimers];
    }
    uint64_t begin = mach_absolute_time();
    self.timers[timerName] = @(begin);
}

- (void)end:(NSString *)timerName info:(NSString *)info
{
    uint64_t        start;
    uint64_t        end;
    uint64_t        elapsed;
    uint64_t        elapsedNano;
    static mach_timebase_info_data_t    sTimebaseInfo;
    
    start = [[self.timers objectForKey:timerName] unsignedLongLongValue];
    
    if (start == 0) {
        return;
    }

    // Stop the clock.
    end = mach_absolute_time();
    
    // Calculate the duration.
    elapsed = end - start;
    
    // Convert to nanoseconds.
    // https://developer.apple.com/library/mac/qa/qa1398/_index.html
    
    if ( sTimebaseInfo.denom == 0 ) {
        (void) mach_timebase_info(&sTimebaseInfo);
    }
    
    elapsedNano = elapsed * sTimebaseInfo.numer / sTimebaseInfo.denom;
    
    // Convert to milliseconds.
    double milliSeconds = elapsedNano * 1e-6;
    
    [self send:timerName time:milliSeconds thread:[NSThread currentThread] info:info];
}

- (void)send:(NSString *)timerName time:(double)milliSeconds thread:(NSThread *)thread info:(NSString *)info
{
    NSArray *params = @[[NSString stringWithFormat:@"%lu", (unsigned long)[thread hash]],
                        [_source substringByTrimmingToLength:32],
                        [timerName substringByTrimmingToLength:48],
                        [NSString stringWithFormat:@"%.6f", milliSeconds],
                        [info substringByTrimmingToLength:32],
                        [_apiKey substringByTrimmingToLength:32]];
    NSString *msg = [params componentsJoinedByString:@"|"];
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [_udpSocket sendData:data withTimeout:-1 tag:0];
}

@end
