//
//  Session.m
//  BenApp3
//
//  Created by Johanna Sinkkonen on 5/10/13.
//  Copyright (c) 2013 Johanna Sinkkonen. All rights reserved.
//

#import "Session.h"

@implementation Session

@synthesize startTime, assignmentDescription, isCurrent, elapsedTime;

- (id) initWithAssignmentDescription: (NSString *) description
{
    self = [super init];
    if (self) {
        self.assignmentDescription = description;
        self.startTime = [NSDate date];
        self.endTime = [[NSDate alloc] init];
        self.elapsedTime = @"YO";
        self.isCurrent = YES;
    }
    return self;
}

- (NSDictionary *) sessionToDictionary
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd hh-mm-ss"];
    NSString *startDateString = [dateFormatter stringFromDate:[self startTime]];
    NSString *endDateString = [dateFormatter stringFromDate:[self endTime]];
    
    NSMutableDictionary *sessionAsDictionary = [[NSMutableDictionary alloc] init];
    sessionAsDictionary[@"startTime"] = startDateString;
    sessionAsDictionary[@"endTime"] = endDateString;
    sessionAsDictionary[@"elapsedTime"] = self.elapsedTime;
    sessionAsDictionary[@"assignmentDescription"] = self.assignmentDescription;
    sessionAsDictionary[@"isCurrent"] = @(self.isCurrent);
    
    return sessionAsDictionary;
}

@end
