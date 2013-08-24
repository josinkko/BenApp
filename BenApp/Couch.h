//
//  Couch.h
//  BenApp3
//
//  Created by Johanna Sinkkonen on 5/10/13.
//  Copyright (c) 2013 Johanna Sinkkonen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Session.h"

@interface Couch : NSObject

- (void) postSessionToDB: (Session *) session;
- (NSMutableDictionary *) getCurrentSession;
- (void) getPreviousSessionsWithCompletionHandler:(void(^)(NSArray *response)) response;
- (void) updateCurrentSession;
- (NSMutableArray *) getAllSessions;
- (Session *) jsonToSession: (NSMutableDictionary *) sessionAsDictionary;
- (void) updateSession: (Session *) session;


// ---------- OFFLINE-SAVING-CODE ---------
//- (NSMutableDictionary *) getCurrentSessionFromFile;
@end
