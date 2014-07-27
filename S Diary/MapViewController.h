//
//  MapViewController.h
//  S Diary
//
//  Created by Di Zhang on 22/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


#import "Event.h"
#import "Location.h"
#import "Bookmark.h"
#import "LocationSearchController.h"
#import "LocationBookmarksController.h"
#import "LocationDetailsController.h"
#import "LocationAnnotation.h"
#import "UpcomingAnnotation.h"
#import "PastAnnotation.h"


@interface MapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UIPopoverControllerDelegate, LocationSearchControllerDelegate>

@property (strong, nonatomic) NSMutableArray* eventList; //Stores the event objects to display on map (regarding event list passed from EventListController).
@property (strong, nonatomic) Event* eventToEdit; //The event being edited, nil for new event (regarding a particular event passed from EventDetailsController).
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;

@property (nonatomic, strong) MKMapItem* mapItem;
@property (nonatomic, strong) NSString* mapMode; //Defines whether showing all events' locations or one event's location or a search result.

- (IBAction)filterAnnotations:(UISegmentedControl *)sender;

@end