//
//  LocationDetailsController.m
//  S Diary
//
//  Created by Dallas Keith Matheson on 21/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


#import "LocationDetailsController.h"


static NSString * LocationCreatedNotification = @"Location Created Notification"; //LocationCreatedNotification's name


@interface LocationDetailsController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *endLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@end


@implementation LocationDetailsController


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.text = self.eventToEdit.title;
    self.startLabel.text = [NSString stringWithFormat:@"%@", [self.dateFormatter stringFromDate:self.eventToEdit.start]];
     self.endLabel.text = [NSString stringWithFormat:@"%@", [self.dateFormatter stringFromDate:self.eventToEdit.end]];
    self.addressLabel.text = [NSString stringWithFormat:@"%@ %@, %@, %@", self.selectedMapItem.placemark.subThoroughfare, self.selectedMapItem.placemark.thoroughfare, self.selectedMapItem.placemark.locality, self.selectedMapItem.placemark.administrativeArea];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 Provide directions - will open the Maps app.
 */
- (IBAction)provideDirection:(id)sender
{
    NSLog(@"Direction to map item: %@", self.selectedMapItem);
    [self.selectedMapItem openInMapsWithLaunchOptions: [NSDictionary dictionaryWithObjectsAndKeys: MKLaunchOptionsDirectionsModeWalking, MKLaunchOptionsDirectionsModeKey,nil]];
}


- (IBAction)assignLocation:(id)sender
{
    // Create a new location object.
    Location *location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    
    // Set the location.
	location.latitude = self.selectedMapItem.placemark.coordinate.latitude;
    location.longitude = self.selectedMapItem.placemark.coordinate.longitude;
    location.name = [NSString stringWithFormat:@"%@ %@, %@, %@", self.selectedMapItem.placemark.subThoroughfare, self.selectedMapItem.placemark.thoroughfare, self.selectedMapItem.placemark.locality, self.selectedMapItem.placemark.administrativeArea];
    
    NSLog(@"Location to post: %@", location);
    //Post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:LocationCreatedNotification object:nil userInfo:[NSDictionary dictionaryWithObject:location forKey:@"Location"]];
    
    self.titleLabel.text = @"Location saved";
    [self.tableView reloadData];
}

- (IBAction)bookmarkLocation:(id)sender
{
    Bookmark *bookmark = [NSEntityDescription insertNewObjectForEntityForName:@"Bookmark" inManagedObjectContext:self.managedObjectContext];
    
    bookmark.latitude = self.selectedMapItem.placemark.coordinate.latitude;
    bookmark.longitude = self.selectedMapItem.placemark.coordinate.longitude;
    bookmark.name = [NSString stringWithFormat:@"%@ %@, %@, %@", self.selectedMapItem.placemark.subThoroughfare, self.selectedMapItem.placemark.thoroughfare, self.selectedMapItem.placemark.locality, self.selectedMapItem.placemark.administrativeArea];
    
    /*
     Save the managed object context.
     */
    NSError* error;
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Core Data Error: %@", error.description);
        [self displayError:error];
    }
    
    self.titleLabel.text = @"Bookmark saved";
    [self.tableView reloadData];
}


#pragma mark - Error handling

/**
 Display a given NSError in an UIAlertView.
 */
- (void)displayError:(NSError *)error
{
    NSString *message = [[error userInfo] valueForKey:NSLocalizedDescriptionKey];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Database access error"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
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
