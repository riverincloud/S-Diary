//
//  ReportViewController.h
//  S Diary
//
//  Created by Di Zhang on 23/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


#import "Event.h"
#import "Attendee.h"
#import "ReportCell.h"


@interface ReportViewController : UITableViewController

@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) NSMutableArray* attendeeList;

- (IBAction)setSortDescriptor:(id)sender;

@end