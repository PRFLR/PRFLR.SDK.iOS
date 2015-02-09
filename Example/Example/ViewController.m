//
//  ViewController.m
//  Example
//
//  Created by Roman on 04/02/15.
//  Copyright (c) 2015 PRFLR. All rights reserved.
//

#import "ViewController.h"
#import "PRFLR.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)testProfile:(id)sender
{
    PRFLR *profiler = [[PRFLR alloc] initWithSource:@"ExampleApp" apiKey:@"YOUR_API_KEY"];
    [profiler begin:@"timerName"];
    [profiler end:@"timerName" info:@"info"];
}

@end
