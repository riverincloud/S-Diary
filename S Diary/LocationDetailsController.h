//
//  LocationDetailsController.h
//  S Diary
//
//  Created by Dallas Keith Matheson on 21/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


#import "Event.h"
#import "Location.h"
#import "Bookmark.h"
#import "LocationAnnotation.h"


@interface LocationDetailsController : UITableViewController

@property (strong, nonatomic) MKMapItem* selectedMapItem; //The MKMapItem object selected on map view.
@property (strong, nonatomic) Event* eventToEdit;
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;

- (IBAction)provideDirection:(id)sender; //Will open the Maps app.
- (IBAction)assignLocation:(id)sender;
- (IBAction)bookmarkLocation:(id)sender;

@end