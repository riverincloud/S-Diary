//
//  EventListController.h
//  S Diary
//
//  Created by Di Zhang on 11/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


#import "EventDetailsController.h"
#import "EventCell.h"


@interface EventListController : UITableViewController <EventDetailsControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) NSMutableArray* eventList;

@end