//
//  Couch.m
//  BenApp3
//
//  Created by Johanna Sinkkonen on 5/10/13.
//  Copyright (c) 2013 Johanna Sinkkonen. All rights reserved.
//

#import "Couch.h"
#import "Session.h"

@implementation Couch

- (void) postSessionToDB: (Session *) session
{

    NSDictionary *sessionAsDictionary = [session sessionToDictionary];
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:sessionAsDictionary options:0 error:nil];
    
    NSURL *url = [NSURL URLWithString:@"http://localhost:5984/benapp"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postdata];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *resp, NSData *data, NSError *error) {
        
        if (error) {
            //do some offline code here
            NSMutableArray *sessionsFromFile = [NSMutableArray arrayWithContentsOfFile:@"/Users/josinkko/Documents/benappsessions"];
            // få tillbaka en plist och serialisera den till json sen
            
            NSMutableString *jsonString = [NSMutableString stringWithContentsOfFile:@"/Users/josinkko/Documents/hejsan.txt" encoding:NSUTF8StringEncoding error:0];
            //NSMutableDictionary *stringAsJSON = []
            
            NSLog(@"You're offline. Session saved to file.");
        } else {
            NSLog(@"Session saved to DB.");
        }
    }];
    
}

- (NSMutableDictionary *) getCurrentSession;
{
    NSURL *url = [NSURL URLWithString:@"http://localhost:5984/benapp/_design/benapp/_list/getvalues/currentsession"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    
    NSURLResponse *resp;
    NSError *err;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:
                              &resp error:&err];

    NSMutableDictionary *responseAsDictionary = [[NSJSONSerialization JSONObjectWithData:response options:0 error:nil] objectAtIndex:0];
    
    return responseAsDictionary;

}

- (void) getPreviousSessionsWithCompletionHandler:(void(^)(NSArray *responseData)) callback
{
    NSURL *url = [NSURL URLWithString:@"http://localhost:5984/benapp/_design/benapp/_list/getvalues/previoussessions"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *resp, NSData *data, NSError *error) {
        id response = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        NSMutableArray *responseData = [[NSMutableArray alloc] init];
        for (int i = 0; i < [response count]; i++) {
            [responseData addObject:[response objectAtIndex:i]];
            
        }
        callback(responseData);
        
    }];
}

- (void) updateCurrentSession
{
    Couch *couch = [[Couch alloc] init];
    NSMutableDictionary *currentSession = [couch getCurrentSession];
    
    NSString *ID = [currentSession valueForKey:@"_id"];
    NSString *revNumber = [currentSession valueForKey:@"_rev"];
    
    NSMutableString *urlstring = [[NSMutableString alloc] init];
    [urlstring appendString:@"http://127.0.0.1:5984/benapp/"];
    [urlstring appendString:ID];
    [urlstring appendString:@"?rev="];
    [urlstring appendString:revNumber];
    
    NSURL *url = [NSURL URLWithString:urlstring];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    BOOL isFalse = NO;
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M/d/yyyy/h/mm/ss/a"];
    
    NSMutableDictionary *stringAsJson = [[NSMutableDictionary alloc] init];
    stringAsJson[@"assignmentDescription"] = [currentSession valueForKey:@"assignmentDescription"];
    stringAsJson[@"endTime"] = [currentSession valueForKeyPath:@"endTime"];
    stringAsJson[@"startTime"] = [currentSession valueForKey:@"startTime"];
    stringAsJson[@"elapsedTime"] = [currentSession valueForKeyPath:@"elapsedTime"];
    stringAsJson[@"isCurrent"] = @(isFalse);
    stringAsJson[@"tags"] = [currentSession valueForKeyPath:@"tags"];
    
    NSData *putData = [NSJSONSerialization dataWithJSONObject:stringAsJson options:NSJSONWritingPrettyPrinted error:nil];
    
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:putData];
    
    NSURLResponse *resp;
    NSError *err;
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&err];
    
    if (!err) {
        NSLog(@"Successfully updated current session in DB");
    }
    /*[couch getCurrentSessionWithCompletionHandler:^(NSArray *response) {
        for (int i = 0; i < [response count]; i++) {
            
            NSString *ID = [[response objectAtIndex:i] valueForKeyPath:@"_id"];
            NSString *revisionNumber = [[response objectAtIndex:i] valueForKeyPath:@"_rev"];
            
            NSMutableString *urlstring2 = [[NSMutableString alloc] init];
            [urlstring2 appendString:@"http://127.0.0.1:5984/benapp/"];
            [urlstring2 appendString:ID];
            [urlstring2 appendString:@"?rev="];
            [urlstring2 appendString:revisionNumber];
            
            NSURL *url = [NSURL URLWithString:urlstring2];
            NSMutableURLRequest *request2 = [[NSMutableURLRequest alloc]initWithURL:url];
            
            BOOL isFalse = NO;
            
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM-dd hh-mm-ss"];
            NSDate *endDate = [NSDate date];
            NSString *endDateString = [dateFormatter stringFromDate:endDate];
            
            NSMutableDictionary *stringAsJson = [[NSMutableDictionary alloc] init];
            stringAsJson[@"startTime"] = [[response objectAtIndex:i] valueForKeyPath:@"startTime"];
            stringAsJson[@"endTime"] = endDateString;
            stringAsJson[@"assignmentDescription"] = [[response objectAtIndex:i] valueForKeyPath:@"assignmentDescription"];
            stringAsJson[@"elapsedTime"] = [[response objectAtIndex:i] valueForKeyPath:@"elapsedTime"];
            stringAsJson[@"isCurrent"] = @(isFalse);
            
            NSData *responseAsJSON = [NSJSONSerialization dataWithJSONObject:stringAsJson options:NSJSONWritingPrettyPrinted error:nil];
            
            [request2 setHTTPMethod:@"PUT"];
            [request2 setValue:@"application/json" forHTTPHeaderField:@"content-type"];
            [request2 setHTTPBody:responseAsJSON];
            
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            
            [NSURLConnection sendAsynchronousRequest:request2 queue:queue completionHandler:^(NSURLResponse *resp, NSData *data, NSError *error) {

            }];
        }
        

    }];*/
}

- (void) updateSession: (Session *) session
{
    Couch *couch = [[Couch alloc] init];
    NSMutableDictionary *currentSession = [couch getCurrentSession];
    
    NSString *ID = [currentSession valueForKey:@"_id"];
    NSString *revNumber = [currentSession valueForKey:@"_rev"];
    
    NSMutableString *urlstring = [[NSMutableString alloc] init];
    [urlstring appendString:@"http://127.0.0.1:5984/benapp/"];
    [urlstring appendString:ID];
    [urlstring appendString:@"?rev="];
    [urlstring appendString:revNumber];
    
    NSURL *url = [NSURL URLWithString:urlstring];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M/d/yyyy/h/mm/ss/a"];
    NSDate *endDate = [NSDate date];
    
    NSString *endDateString = [dateFormatter stringFromDate:endDate];
    
    NSMutableDictionary *stringAsJson = [[NSMutableDictionary alloc] init];
    stringAsJson[@"assignmentDescription"] = [currentSession valueForKey:@"assignmentDescription"];
    stringAsJson[@"endTime"] = endDateString;
    stringAsJson[@"startTime"] = [currentSession valueForKey:@"startTime"];
    stringAsJson[@"elapsedTime"] = [currentSession valueForKeyPath:@"elapsedTime"];
    stringAsJson[@"isCurrent"] = [currentSession valueForKeyPath:@"isCurrent"];
    stringAsJson[@"tags"] = [currentSession valueForKeyPath:@"tags"];
    
    NSData *putData = [NSJSONSerialization dataWithJSONObject:stringAsJson options:NSJSONWritingPrettyPrinted error:nil];
    
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:putData];
    
    NSURLResponse *resp;
    NSError *err;
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&err];
    
    if (!err) {
        NSLog(@"Successfully updated current session in DB");
    }
}

- (NSMutableArray *) getAllSessions;
{
    NSURL *url = [NSURL URLWithString:@"http://localhost:5984/benapp/_design/benapp/_list/getvalues/all"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSURLResponse *resp = [[NSURLResponse alloc] init];
    NSError *error = [[NSError alloc] init];
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&error];
    
    id responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
    NSMutableArray *sessions = [[NSMutableArray alloc] init];

    for (int i = 0; i < [responseData count]; i++) {
        [sessions addObject:[self jsonToSession:[responseData objectAtIndex:i]]];
    }
    
    return sessions;

}

- (Session *) jsonToSession: (NSMutableDictionary *) sessionAsDictionary
{
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M/d/yyyy/h/mm/ss/a"];
    
    NSDate *startDate = [dateFormatter dateFromString:[sessionAsDictionary valueForKey:@"startTime"]];
    NSDate *endDate = [dateFormatter dateFromString:[sessionAsDictionary valueForKey:@"endTime"]];
    
    Session *session = [[Session alloc] init];
    session.assignmentDescription = [sessionAsDictionary valueForKeyPath:@"assignmentDescription"];
    session.startTime = startDate;
    session.endTime = endDate;
    session.elapsedTime = [sessionAsDictionary valueForKeyPath:@"elapsedTime"];
    session.isCurrent = [[sessionAsDictionary valueForKeyPath:@"isCurrent"] boolValue];
    session.tags = [sessionAsDictionary valueForKeyPath:@"tags"];
    
    return session;
}


/*- (NSMutableDictionary *) getCurrentSessionFromFile
{
    NSString *currentSessionAsString = []
}*/
@end
