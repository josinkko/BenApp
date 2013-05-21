//
//  MainViewController.h
//  BenApp3
//
//  Created by Johanna Sinkkonen on 5/10/13.
//  Copyright (c) 2013 Johanna Sinkkonen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MainViewController : NSObject <NSTableViewDataSource>
{
    IBOutlet NSTextField *assignmentTextField;
    IBOutlet NSTableView *tableView;
    NSMutableArray *sessions;
    
}
@end
