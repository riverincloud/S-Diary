//
//  LocationSearchController.m
//  S Diary
//
//  Created by Di Zhang on 28/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


#import "LocationSearchController.h"


@interface LocationSearchController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end


@implementation LocationSearchController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultCell" forIndexPath:indexPath];
    
    MKMapItem *mapItem = [self.places objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", mapItem.placemark.subThoroughfare, mapItem.placemark.thoroughfare];
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Pass the individual place to map view controller.
    NSIndexPath *selectedItem = [self.tableView indexPathForSelectedRow];
    MKMapItem* item = [self.places objectAtIndex:selectedItem.row];
    
    [self.delegate locationSearchController:self didSelectItem:item];
}


#pragma mark - Cancel operation

- (IBAction)cancel:(id)sender
{
    [self.delegate dismissLocationSearchController:self];
}


#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    //Check to see if Location Services is enabled, there are two state possibilities:
    // 1) disabled for entire device, 2) disabled just for this app
    
    NSString *causeStr = nil;
    
    //Check whether location services are enabled on the device
    if ([CLLocationManager locationServicesEnabled] == NO)
    {
        causeStr = @"device";
    }
    //Check the application’s explicit authorization status:
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        causeStr = @"app";
    }
    else
    {
        //Ready to go, start the search.
        NSLog(@"Geocode search ready");
        [self startSearch:searchBar.text];
    }
    
    if (causeStr != nil)
    {
        NSString *alertMessage = [NSString stringWithFormat:@"You currently have location services disabled for this %@. Please refer to \"Settings\" app to turn on Location Services.", causeStr];
        
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                                        message:alertMessage
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }
}


/**
 Search places with user input with CLGeocoder.
 */
- (void)startSearch:(NSString* )searchString
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:searchString completionHandler:^(NSArray *placemarks, NSError *error){
        
        if (error)
        {
            NSLog(@"Geocode failed with error: %@", error);
            [self displayError:error];
        }
        else{
            NSLog(@"Received placemarks: %@", placemarks);
            [self displayPlacemarks:placemarks];
        }
    }];
}

/**
 Display a given NSError in an UIAlertView.
 */
- (void)displayError:(NSError *)error
{
    NSString *message = [[error userInfo] valueForKey:NSLocalizedDescriptionKey];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not find places"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

/**
 Create mapItems with the placemarks and add them to places.
 */
- (void)displayPlacemarks:(NSArray*)placemarks
{
    NSMutableArray* mapItems = [[NSMutableArray alloc] init];
    
    for (CLPlacemark* placemark in placemarks)
    {
        MKPlacemark* mkplacemark = [[MKPlacemark alloc] initWithPlacemark:placemark];
        MKMapItem* mapItem = [[MKMapItem alloc] initWithPlacemark:mkplacemark];
        [mapItems addObject:mapItem];
        NSLog(@"Updated map items: %d", [mapItems count]);
    }
    self.places = mapItems;
    
    [self.tableView reloadData];
}

@end