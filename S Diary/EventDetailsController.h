//
//  EventDetailsController.h
//  S Diary
//
//  Created by Di Zhang on 11/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


#import "Event.h"
#import "DateViewController.h"
#import "MapViewController.h"
#import "AttendeeListController.h"
#import "PhotoCollectionController.h"
#import "LocationDetailsController.h"


@class EventDetailsController;

@protocol EventDetailsControllerDelegate <NSObject>

//Call this method on delegate object when a new event created.
- (void)eventDetailsController:(EventDetailsController*)controller didCreateEvent:(Event*)event;
//Call this method on delegate object when an existing event updated.
- (void)eventDetailsController:(EventDetailsController*)controller didSaveEvent:(Event*)event;

@end


@interface EventDetailsController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, weak) id <EventDetailsControllerDelegate> delegate; //A delegate property.
@property (nonatomic, strong) Event* eventToEdit; //The event being edited, nil for new event.
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext; //The managed object context

- (IBAction)updateRateLabel:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end