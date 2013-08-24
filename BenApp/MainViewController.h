//
//  MainViewController.h
//  BenApp3
//
//  Created by Johanna Sinkkonen on 5/10/13.
//  Copyright (c) 2013 Johanna Sinkkonen. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Session.h"

@interface MainViewController : NSViewController <NSTableViewDataSource>
{
    IBOutlet NSTextField *assignmentTextField;
    IBOutlet NSTableView *tableView;
    IBOutlet NSTextField *tagTextField;
    
    NSTimer *myTimer;
    NSTimeInterval elapsedTimeBetweenDates;
    NSTimeInterval starttime;
    NSMutableArray *sessions;
    NSMutableArray *allTags;
    
}

@property (nonatomic, weak) IBOutlet NSTextField *hr;
@property (nonatomic, weak) IBOutlet NSTextField *min;
@property (nonatomic, weak) IBOutlet NSTextField *sec;
@property (nonatomic, weak) IBOutlet NSTextField *currentAssignmentTextField;

- (void) updateLabel;
- (void) updateElapsedTimeBetweenDates;
- (void) resetElapsedTime;
//- (IBAction)stopCurrentSession:(id)sender;


- (IBAction)stopGo:(id)sender;

@end
