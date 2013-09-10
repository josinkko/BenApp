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

@synthesize hr, min, sec, currentAssignmentTextField;

- (id) init
{
    self = [super init];
    if (self) {
        
        sessions = [[NSMutableArray alloc] init];
        allTags = [[NSMutableArray alloc] init];
    }
    return self;
}

// ----- NSTIMER INTERFACEUPDATE-METHOD

-(void) updateLabel
{
    Couch *couch = [[Couch alloc] init];
    NSMutableDictionary *currentSessionInJson = [couch getCurrentSession];
    
    Session *currentSession = [couch jsonToSession:currentSessionInJson];
    NSDate *now = [NSDate date];
    double timePassed = [now timeIntervalSinceDate:currentSession.startTime];
    
    int hours = timePassed / (60 * 60);
    int minutes = (int)timePassed % (60 * 60) / 60;
    int seconds = (((int)timePassed % (60 * 60)) % 60);
    
    [[self hr] setStringValue:[NSString stringWithFormat:@"%d :", hours]];
    [[self min] setStringValue:[NSString stringWithFormat:@"%d :", minutes]];
    [[self sec] setStringValue:[NSString stringWithFormat:@"%d", seconds]];
    
}

- (void) resetElapsedTime
{
    starttime = [NSDate timeIntervalSinceReferenceDate];
    [self updateElapsedTimeBetweenDates];
}

-(void)updateElapsedTimeBetweenDates
{
    [self willChangeValueForKey:@"elapsedTimeBetweenDates"];
    elapsedTimeBetweenDates = [NSDate timeIntervalSinceReferenceDate] - starttime;
    [self didChangeValueForKey:@"elapsedTimeBetweenDates"];
}
// ---------- NSTIMER END ---------

// --------- TABLEVIEW DATASOURCE-CODE ---------

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    
    return [sessions count];
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    Session *s = [sessions objectAtIndex:row];
    
    NSDictionary *sessionAsDictionary = [s sessionToDictionary];
    NSString *identifier = [tableColumn identifier];
    return [sessionAsDictionary valueForKey:identifier];
}

// ---------- TABLEVIEW-CODE END ---------

- (IBAction)addSession:(id)sender {
    
    // ---------- NSTIMER-CODE ----------
    
    [self resetElapsedTime];
    
    if (myTimer == nil) {
        NSLog(@"starting");
        myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateLabel) userInfo:nil repeats:YES];
    } 
    
    // ---------- SESSION CODE ----------
    Couch *couch = [[Couch alloc] init];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M/d/yyyy/h/mm/ss/a"];
    
    NSMutableDictionary *currentSessionInJson = [couch getCurrentSession];
    
    Session *currentSession = [couch jsonToSession:currentSessionInJson];
    
    NSDate *now = [NSDate date];
    
    if (currentSession.endTime == currentSession.startTime) {
        currentSession.endTime = now;
        
        double timePassed = [[currentSession endTime] timeIntervalSinceDate:currentSession.startTime];
        
        int hours = timePassed / (60 * 60);
        int minutes = (int)timePassed % (60 * 60) / 60;
        int seconds = (((int)timePassed % (60 * 60)) % 60);
        
        NSString *timeString = [NSString stringWithFormat:@"%d h: %d min: %d sec", hours, minutes, seconds];
        currentSession.elapsedTime = timeString;
    }
    
    double timePassed = [[currentSession endTime] timeIntervalSinceDate:currentSession.startTime];
        
    int hours = timePassed / (60 * 60);
    int minutes = (int)timePassed % (60 * 60) / 60;
    int seconds = (((int)timePassed % (60 * 60)) % 60);
        
    NSString *timeString = [NSString stringWithFormat:@"%d h: %d min: %d sec", hours, minutes, seconds];
    currentSession.elapsedTime = timeString;
    
    [sessions insertObject:currentSession atIndex:0];
    [tableView reloadData];
    
    NSString *assignmentText = [assignmentTextField stringValue];
    
    Session *session = [[Session alloc] initWithAssignmentDescription:assignmentText];
    NSString *tagsAsString = [tagTextField stringValue];
    NSArray *tags = [tagsAsString componentsSeparatedByString:@" "];
    for (int i = 0; i < [[session tags] count]; i++) {
        [[session tags] addObject:[tags objectAtIndex:i]];
        [allTags addObject:[tags objectAtIndex:i]];
    }
    
    [[self currentAssignmentTextField] setStringValue:assignmentText];
    [assignmentTextField setStringValue:@""];
    [tagTextField setStringValue:@""];
    [couch updateCurrentSession];
    [couch postSessionToDB:session];
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


-(IBAction)stopGo:(id)sender
{
    [self resetElapsedTime];
     
     if (myTimer == nil) {
         NSLog(@"starting timer");
         myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateLabel) userInfo:nil repeats:YES];
     } else {
         NSLog(@"stopping timer");
         [myTimer invalidate];
         myTimer = nil;
         Couch *couch = [[Couch alloc] init];
         NSMutableDictionary *currentSessionInJson = [couch getCurrentSession];
         Session *currentSession = [couch jsonToSession:currentSessionInJson];
         NSDate *now = [NSDate date];
         currentSession.endTime = now;
         
         double timePassed = [[currentSession endTime] timeIntervalSinceDate:currentSession.startTime];
         
         int hours = timePassed / (60 * 60);
         int minutes = (int)timePassed % (60 * 60) / 60;
         int seconds = (((int)timePassed % (60 * 60)) % 60);
         
         NSString *timeString = [NSString stringWithFormat:@"%d h: %d min: %d sec", hours, minutes, seconds];
         currentSession.elapsedTime = timeString;
         [sessions insertObject:currentSession atIndex:0];
         [tableView reloadData];
         
         [couch updateSession:currentSession];
         
         [[self hr] setStringValue:@"0"];
         [[self min] setStringValue:@"0"];
         [[self sec] setStringValue:@"0"];
         [currentAssignmentTextField setStringValue:@" "];

     }
}


@end











