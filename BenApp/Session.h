//
//  Session.h
//  BenApp3
//
//  Created by Johanna Sinkkonen on 5/10/13.
//  Copyright (c) 2013 Johanna Sinkkonen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Session : NSObject

@property NSString *assignmentDescription;
@property NSDate *startTime;
@property NSDate *endTime;
@property NSString *elapsedTime;
@property NSMutableArray *tags;
@property BOOL isCurrent;

- (id) initWithAssignmentDescription: (NSString *) description;
- (NSDictionary *) sessionToDictionary;
@end
