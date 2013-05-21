//
//  MainViewController.m
//  BenApp3
//
//  Created by Johanna Sinkkonen on 5/10/13.
//  Copyright (c) 2013 Johanna Sinkkonen. All rights reserved.
//

#import "MainViewController.h"
#import "Session.h"
#import "Couch.h"

@interface MainViewController () <NSTableViewDataSource>


- (id) init;
- (void) stopSession;
- (NSMutableArray *) populateSessionsArray;

@end

@implementation MainViewController


- (id) init
{
    self = [super init];
    if (self) {
        sessions = [[NSMutableArray alloc] init];

    }
    return self;
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{

    return [sessions count];
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    Session *s = [sessions objectAtIndex:row];



    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSUInteger unitFlags = NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *components = [gregorian components:unitFlags
                                                fromDate:s.startTime
                                                  toDate:s.endTime options:0];
    NSInteger minutes = [components minute];
    NSInteger seconds = [components second];
    
    NSString *timeString = [NSString stringWithFormat:@"%ld min: %ld sec", minutes, seconds];
    s.elapsedTime = timeString;

    NSDictionary *ss = [s sessionToDictionary];
    NSString *identifier = [tableColumn identifier];
    return [ss valueForKey:identifier];
}

- (IBAction)addSession:(id)sender {
    
    
    Couch *couch = [[Couch alloc] init];
    [couch getCurrentSessionWithCompletionHandler:^(NSArray *response) {
        //hämta den som är current och sätt dess endDate till nu.
        Session *currentSession = [couch jsonToSession:[response objectAtIndex:0]];
        currentSession.endTime = [NSDate date];
    }];
    
    Session *session = [[Session alloc] initWithAssignmentDescription:[assignmentTextField stringValue]];

    //sessions = [self populateSessionsArray];
    
    [sessions addObject:session];

    [tableView reloadData];

    [couch updateCurrentSession];
    
    [couch postSessionToDB:session];
    NSLog(@"added session");

    
        
    
}
- (void) stopSession
{
   // Couch *couch = [[Couch alloc] init];
   // [couch updateCurrentSession];
}

- (NSMutableArray *) populateSessionsArray
{
    NSMutableArray *sessionsArray = [[NSMutableArray alloc] init];
    
    Couch *couch = [[Couch alloc] init];
    sessionsArray = [couch getAllSessions];
    
        for (Session *s in sessions) {
            NSLog(@"%@", s.startTime);
        }
    
    return sessionsArray;
    
}



@end
