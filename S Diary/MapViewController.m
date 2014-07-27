//
//  MapViewController.m
//  S Diary
//
//  Created by Di Zhang on 22/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


#import "MapViewController.h"


static NSString * BookmarkSelectedNotification = @"Bookmark Selected for Map to Display Notification"; //BookmarkSelectedNotification's name


@interface MapViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D userLocation;
@property (strong, nonatomic) LocationAnnotation * selectedAnnotation;

@property (retain, readwrite) UIPopoverController *popover;

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end


@implementation MapViewController


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Register with a notification center to receive notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookmarkSelected:) name:BookmarkSelectedNotification object:nil];
    
    // start by locating user's current position
	self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.distanceFilter = 10;
	self.locationManager.delegate = self;
	[self.locationManager startUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.mapMode == @"DisplayAll")
    {
        self.toolbar.hidden = TRUE;
        
        //Create a new annotation for each event in the event list and add it to map.
        NSMutableArray *annotations = [[NSMutableArray alloc] init];
        for (Event *event in self.eventList)
        {
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = event.location.latitude;
            coordinate.longitude = event.location.longitude;
            
            if ([event.start timeIntervalSinceNow] > 0)
            {
                UpcomingAnnotation *annotation = [[UpcomingAnnotation alloc] init];
                annotation.coordinate = coordinate;
                annotation.title = event.title;
                annotation.subtitle = [self.dateFormatter stringFromDate:event.start];
                [annotations addObject:annotation];
            }
            else
            {
                PastAnnotation *annotation = [[PastAnnotation alloc] init];
                annotation.coordinate = coordinate;
                annotation.title = event.title;
                annotation.subtitle = [self.dateFormatter stringFromDate:event.start];
                [annotations addObject:annotation];
            }
        }
        //Adjust the map to zoom/center to the annotations we want to show
        [self coverAllAnnotations:annotations];
        [self.mapView addAnnotations:annotations];
        
    }
    else
    {
        self.segmentedControl.hidden = TRUE;
        
        if (self.mapMode == @"DisplayOne")
        {
            //If current event has a location, reverse geocoding first; Otherwise, only display a map.
            if (self.eventToEdit.location != nil)
            {
                //Reverse geocoding
                CLGeocoder* geocoder = [[CLGeocoder alloc] init];
                CLLocation* location = [[CLLocation alloc] initWithLatitude:self.eventToEdit.location.latitude longitude:self.eventToEdit.location.longitude];
                
                [geocoder reverseGeocodeLocation:location completionHandler:
                 ^(NSArray* placemarks, NSError* error){
                     if (error){
                         NSLog(@"Geocode failed with error: %@", error);
                         [self displayError:error];
                         return;
                     }
                     NSLog(@"Received placemarks: %@", placemarks);
                     CLPlacemark* aplacemark = [placemarks objectAtIndex:0];
                     MKPlacemark* placemark = [[MKPlacemark alloc] initWithPlacemark:aplacemark];
                     self.mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
                     NSLog(@"Received map item: %@", self.mapItem);
                     
                     [self displayMapItem:self.mapItem];
                 }];
            }
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //Remove exsisting annotations from map view.
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    //Remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BookmarkSelectedNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 Display a given NSError in an UIAlertView.
 */
- (void)displayError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(),^ {
        
        NSString *message;
        switch ([error code])
        {
            case kCLErrorGeocodeFoundNoResult:
                message = @"kCLErrorGeocodeFoundNoResult";
                break;
            case kCLErrorGeocodeCanceled:
                message = @"kCLErrorGeocodeCanceled";
                break;
            case kCLErrorGeocodeFoundPartialResult:
                message = @"kCLErrorGeocodeFoundNoResult";
                break;
            default:
                message = [error description];
                break;
        }
        
        UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:@"An error occurred."
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];;
        [alert show];
    });
}


/**
 Create annotation based on mapitem and add to map view.
 */
- (void)displayMapItem:(MKMapItem*)mapItem
{
    self.title = mapItem.name;
    
    //Add the single annotation to map
    LocationAnnotation *annotation = [[LocationAnnotation alloc] init];
    annotation.coordinate = mapItem.placemark.location.coordinate;
    annotation.title = [NSString stringWithFormat:@"%@ %@", mapItem.placemark.subThoroughfare, mapItem.placemark.thoroughfare];
    annotation.subtitle = [NSString stringWithFormat:@"%@, %@",mapItem.placemark.locality, mapItem.placemark.administrativeArea];
    annotation.mapItem = mapItem;
    
    [self.mapView addAnnotation:annotation];
    
    //Center the region around this map item's coordinate
    [self goToAnnotation:annotation];
}


/**
 Set the region for map view.
 */
-(void)goToAnnotation:(LocationAnnotation*)annotation
{
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = annotation.coordinate.latitude;
    newRegion.center.longitude = annotation.coordinate.longitude;
    newRegion.span.latitudeDelta = 0.112872;
    newRegion.span.longitudeDelta = 0.109863;
    
    [self.mapView setRegion:newRegion animated:YES];
}

- (void)coverAllAnnotations:(NSMutableArray*)annotations
{
    if ([annotations count] > 0)
    {
        @try
        {
            //calculate new region to show on map
            LocationAnnotation *firstAnnotation = [annotations objectAtIndex:0];
            double max_lat = firstAnnotation.coordinate.latitude;
            double min_lat = firstAnnotation.coordinate.latitude;
            double max_long = firstAnnotation.coordinate.longitude;
            double min_long = firstAnnotation.coordinate.longitude;
            
            //find min and max values
            for (LocationAnnotation *annotation in annotations) {
                if (annotation.coordinate.latitude > max_lat)
                {
                    max_lat = annotation.coordinate.latitude;
                }
                if (annotation.coordinate.latitude < min_lat)
                {
                    min_lat = annotation.coordinate.latitude;
                }
                if (annotation.coordinate.longitude > max_long)
                {
                    max_long = annotation.coordinate.longitude;
                }
                if (annotation.coordinate.longitude < min_long)
                {
                    min_long = annotation.coordinate.longitude;
                }
            }
            
            //calculate center of map
            double center_long = (max_long + min_long) / 2;
            double center_lat = (max_lat + min_lat) / 2;
            
            //calculate delta
            double deltaLat = abs(max_lat - min_lat);
            double deltaLong = abs(max_long - min_long);
            
            //set minimal delta
            if (deltaLat < 1) {deltaLat = 1;}
            if (deltaLong < 1) {deltaLong = 1;}
            
            NSLog(@"center long: %f, center lat: %f", center_long, center_lat);
            NSLog(@"max_long: %f, min_long: %f, max_lat: %f, min_lat: %f", max_long, min_long, max_lat, min_lat);
            
            //create new region and set map
            MKCoordinateRegion newRegion;
            newRegion.center.latitude = center_lat;
            newRegion.center.longitude = center_long;
            newRegion.span.latitudeDelta = deltaLat;
            newRegion.span.longitudeDelta = deltaLong;
            
            [self.mapView setRegion:newRegion animated:YES];
        }
        @catch (NSException * e)
        {
            NSLog(@"Error calculating new map region: %@", e);
        }
    }
}


#pragma mark - Segues

/**
 Returns whether a particular segue should be allowed to fire (regarding popover segues for iPad).
 */
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"OpenBookmarksPad"] |
        [identifier isEqualToString:@"OpenSearchPad"] |
        [identifier isEqualToString:@"OpenDetailsPad"])
    {
        return (!self.popover.popoverVisible) ? YES : NO;
    }
    else
    {
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"OpenSearch"])
    {
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        LocationSearchController *controller = (LocationSearchController *)[navController topViewController];
        controller.delegate = self;
    }
    
    if([segue.identifier isEqualToString:@"OpenSearchPad"])
    {
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        LocationSearchController *controller = (LocationSearchController *)[navController topViewController];
        controller.delegate = self;
        
        //If a popover is already showing, dismiss it before presenting a new one.
        if(self.popover)
        {
            [self.popover dismissPopoverAnimated:YES];
            self.popover = nil;
        }
        //Set the popover property every time a new popover presented (or dismissed).
        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]])
        {
            self.popover = ((UIStoryboardPopoverSegue *)segue).popoverController;
            self.popover.delegate = self;
            NSLog(@"New popover: %@", self.popover);
        }
    }
    
    if ([[segue identifier] isEqualToString:@"OpenBookmarks"])
    {
        LocationBookmarksController *controller = segue.destinationViewController;
        controller.managedObjectContext = self.managedObjectContext;
    }
    
    if ([[segue identifier] isEqualToString:@"OpenBookmarksPad"])
    {
        LocationBookmarksController *controller = segue.destinationViewController;
        controller.managedObjectContext = self.managedObjectContext;
        
        if(self.popover)
        {
            [self.popover dismissPopoverAnimated:YES];
            self.popover = nil;
        }
        
        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]])
        {
            self.popover = ((UIStoryboardPopoverSegue *)segue).popoverController;
            self.popover.delegate = self;
            NSLog(@"New popover: %@", self.popover);
        }
    }
    
    if([segue.identifier isEqualToString:@"OpenDetails"])
    {
        LocationDetailsController* controller = segue.destinationViewController;
        controller.managedObjectContext = self.managedObjectContext;
        controller.eventToEdit = self.eventToEdit;
        controller.selectedMapItem = self.selectedAnnotation.mapItem;
    }
    
    if([segue.identifier isEqualToString:@"OpenDetailsPad"])
    {
        LocationDetailsController* controller = segue.destinationViewController;
        controller.managedObjectContext = self.managedObjectContext;
        controller.eventToEdit = self.eventToEdit;
        controller.selectedMapItem = self.selectedAnnotation.mapItem;
        
        if(self.popover)
        {
            [self.popover dismissPopoverAnimated:YES];
            self.popover = nil;
        }
        
        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]])
        {
            self.popover = ((UIStoryboardPopoverSegue *)segue).popoverController;
            self.popover.delegate = self;
            NSLog(@"New popover: %@", self.popover);
        }
    }
}


#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // remember for later the user's current location
    self.userLocation = newLocation.coordinate;
    
	[manager stopUpdatingLocation];
    
    manager.delegate = nil;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // report any errors returned back from Location Services
    NSLog(@"Location services error: %@", error);
}


#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	MKPinAnnotationView *pinView = nil;
	if ([annotation isKindOfClass:[LocationAnnotation class]])
	{
		pinView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
		if (pinView == nil)
		{
			// if an existing pin view was not available, create one
            MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc]
                                                  initWithAnnotation:annotation reuseIdentifier:@"Pin"];
            customPinView.pinColor = MKPinAnnotationColorGreen;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            
            //Add a detail disclosure button to the callout which will open a new view controller page
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            customPinView.rightCalloutAccessoryView = rightButton;
            
            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
	}
    /**
     The custom annotation views below are for annotations added for displaying all events on map.
     */
    if ([annotation isKindOfClass:[UpcomingAnnotation class]])
	{
		pinView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"UpcomingPin"];
		if (pinView == nil)
		{
            MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc]
                                                  initWithAnnotation:annotation reuseIdentifier:@"UpcomingPin"];
            customPinView.pinColor = MKPinAnnotationColorGreen;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            
            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
	}
    if ([annotation isKindOfClass:[PastAnnotation class]])
	{
		pinView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"PastPin"];
		if (pinView == nil)
		{
            MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc]
                                                  initWithAnnotation:annotation reuseIdentifier:@"PastPin"];
            customPinView.pinColor = MKPinAnnotationColorPurple;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            
            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
	}
    return nil;
}

/**
 When the detail disclosure button is tapped, respond via calloutAccessoryControlTapped delegate method.
 */
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    //Detect which annotation type was clicked on for its callout
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[LocationAnnotation class]])
    {
        NSLog(@"Clicked current annotation");
        self.selectedAnnotation = annotation;
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self performSegueWithIdentifier:@"OpenDetailsPad" sender:self];
    }
    else
    {
        [self performSegueWithIdentifier:@"OpenDetails" sender:self];
    }
}


#pragma mark - LocationSearchControllerDelegate methods

-(void)locationSearchController:(LocationSearchController*)controller didSelectItem:(MKMapItem*)item
{
    self.mapItem = item;
    self.mapMode = @"ShowSearchResult";
    [self displayMapItem:self.mapItem];
    
    //Check if popover for iPad.
    if (self.popover)
    {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
        return;
    }
    //For iPhone
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissLocationSearchController:(LocationSearchController *)controller
{
    if (self.popover)
    {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
        return;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Notifications handlers

- (void)bookmarkSelected:(NSNotification *)notification
{
    [self.mapView removeAnnotations:self.mapView.annotations];  // remove any annotations that exist
    
    Location *locationToDisplay = [notification.userInfo objectForKey:@"Bookmark"];
    NSLog(@"Location to display: %@", locationToDisplay);
    
    if (locationToDisplay != nil)
    {
        //Reverse geocoding
        CLGeocoder* geocoder = [[CLGeocoder alloc] init];
        CLLocation* location = [[CLLocation alloc] initWithLatitude:locationToDisplay.latitude longitude:locationToDisplay.longitude];
        
        [geocoder reverseGeocodeLocation:location completionHandler:
         ^(NSArray* placemarks, NSError* error){
             if (error){
                 NSLog(@"Geocode failed with error: %@", error);
                 [self displayError:error];
                 return;
             }
             NSLog(@"Received placemarks: %@", placemarks);
             CLPlacemark* aplacemark = [placemarks objectAtIndex:0];
             MKPlacemark* placemark = [[MKPlacemark alloc] initWithPlacemark:aplacemark];
             self.mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
             NSLog(@"Received map item: %@", self.mapItem);
             
             [self displayMapItem:self.mapItem];
             
             if(self.popover)
             {
                 [self.popover dismissPopoverAnimated:YES];
                 self.popover = nil;
             }
         }];
    }
}


/**
 Filter annotations according to event start time.
 */
- (IBAction)filterAnnotations:(UISegmentedControl *)sender
{
    switch(sender.selectedSegmentIndex)
    {
        case 0:
            for (id < MKAnnotation > annotation in self.mapView.annotations)
            {
                [[self.mapView viewForAnnotation:annotation] setHidden:NO];
            }
            break;
        case 1:
            for (id < MKAnnotation > annotation in self.mapView.annotations)
            {
                if ([annotation isKindOfClass:[PastAnnotation class]])
                {
                    NSLog(@"For past event: %@", annotation);
                    [[self.mapView viewForAnnotation:annotation] setHidden:YES];
                }
                else
                {
                    [[self.mapView viewForAnnotation:annotation] setHidden:NO];
                }
            }
            break;
        case 2:
            for (id < MKAnnotation > annotation in self.mapView.annotations)
            {
                if ([annotation isKindOfClass:[UpcomingAnnotation class]])
                {
                     NSLog(@"For upcoming event: %@", annotation);
                    [[self.mapView viewForAnnotation:annotation] setHidden:YES];
                }
                else
                {
                    [[self.mapView viewForAnnotation:annotation] setHidden:NO];
                }
            }
            break;
    }
}


/**
 Date formatter
 */
- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    }
    return dateFormatter;
}

@end
