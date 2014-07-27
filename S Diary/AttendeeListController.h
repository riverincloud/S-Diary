//
//  AttendeeListController.h
//  S Diary
//
//  Created by Di Zhang on 11/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


#import "Event.h"
#import "Attendee.h"


@interface AttendeeListController : UITableViewController <ABPeoplePickerNavigationControllerDelegate>

@property (strong, nonatomic) NSMutableArray* attendeesList;
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) Event* eventToEdit;

- (IBAction)showPicker:(id)sender;

@end
