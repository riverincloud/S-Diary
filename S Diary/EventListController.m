//
//  EventListController.m
//  S Diary
//
//  Created by Di Zhang on 11/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


#import "EventListController.h"


static NSString * EventChangedNotification = @"Event Changed Notification"; //EventChangedNotification's name


@interface EventListController ()
{
    NSSortDescriptor* dateSortDescriptor; //A private sort descriptor for sorting the list by start date.
}
@end


@implementation EventListController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Create the sort descriptor.
    dateSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:YES];
    
    //Create a fetch request to get initial data from the Model
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    //Tells the fetch request the type of objects after
    NSEntityDescription* contactDescription = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    
    //Set the Entity and Sort Descriptors for the fetch request
    [fetchRequest setEntity:contactDescription];
    [fetchRequest setSortDescriptors:@[dateSortDescriptor]];
    
    //Error object in case the fetch fails
    NSError* error;
    
    //Returns an NSArray of results, use the mutable copy method to get an NSMutableArray.
    NSMutableArray* fetchResults = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    //If the fetch fails the results will be nil.
    if(fetchResults != nil)
    {
        self.eventList = fetchResults;
    }
    else
    {
        NSLog(@"Core Data Fetch Error: %@", [error description]);
        [self displayError:error];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.eventList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Custom cell - create an object of the EventCell class
    static NSString *CellIdentifier = @"EventCell";
    EventCell *cell = (EventCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //Get the correct event object for a row to display.
    Event* eventToDisplay = [self.eventList objectAtIndex:indexPath.row];
    
    //Configure the cell
    cell.titleLabel.text = eventToDisplay.title;
    cell.dateLocationLabel.text = [NSString stringWithFormat:@"%@ - %@", [self.dateFormatter stringFromDate:eventToDisplay.start], eventToDisplay.location.name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //This method supports editing of the table, this includes rearranging and deleting. In this case, only deleting.
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //Select the object to delete
        NSManagedObject* objectToDelete = [self.eventList objectAtIndex:indexPath.row];
        
        //Delete it from the managed object context
        [self.managedObjectContext deleteObject:objectToDelete];
        //Then the event array
        [self.eventList removeObject:objectToDelete];
        //Then the table
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        /*
         Save the managed object context.
         */
        NSError* error;
        if(![self.managedObjectContext save:&error])
        {
            NSLog(@"Core Data Error: %@", error.description);
            [self displayError:error];
        }
        
        //Post notification for the change of event.
        [[NSNotificationCenter defaultCenter] postNotificationName:EventChangedNotification object:nil];
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
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    return dateFormatter;
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{    
    if([segue.identifier isEqualToString:@"NewEvent"])
    {
        //For iPhone, this segues leads to the EventDetailsController directly.
        EventDetailsController *controller = segue.destinationViewController;
        //Set the delegate and pass managed object context
        controller.delegate = self;
        controller.managedObjectContext = self.managedObjectContext;
        //If it's a new event, change the title of the view and set event to edit to nil
        controller.title = @"New Event";
        controller.eventToEdit = nil;
    }
    
    if([segue.identifier isEqualToString:@"NewEventPad"])
    {
        //For iPad, this segues leads to the UINavigationController.
        UINavigationController* navigationController = segue.destinationViewController;
        EventDetailsController *controller = (EventDetailsController*) [navigationController.viewControllers objectAtIndex:0];
        //Set the delegate and pass managed object context
        controller.delegate = self;
        controller.managedObjectContext = self.managedObjectContext;
        //If it's a new event, change the title of the view and set event to edit to nil
        controller.title = @"New Event";
        controller.eventToEdit = nil;
    }
    
    if([segue.identifier isEqualToString:@"EditEvent"])
    {
        //For iPhone, this segues leads to the EventDetailsController directly.
        EventDetailsController *controller = segue.destinationViewController;
        //Set the delegate and pass managed object context
        controller.delegate = self;
        controller.managedObjectContext = self.managedObjectContext;
        //If editing, find the event to edit.
        NSIndexPath* indexPath = [self.tableView indexPathForCell:sender];
        //Set the view title and the event to edit.
        controller.title = @"Edit Event";
        controller.eventToEdit = [self.eventList objectAtIndex:indexPath.row];
    }
    
    if([segue.identifier isEqualToString:@"EditEventPad"])
    {
        //For iPad, this segues leads to the UINavigationController.
        UINavigationController* navigationController = segue.destinationViewController;
        EventDetailsController *controller = (EventDetailsController*) [navigationController.viewControllers objectAtIndex:0];
        //Set the delegate and pass managed object context
        controller.delegate = self;
        controller.managedObjectContext = self.managedObjectContext;
        //If editing, find the event to edit.
        NSIndexPath* indexPath = [self.tableView indexPathForCell:sender];
        //Set the view title and the event to edit.
        controller.title = @"Edit Event";
        controller.eventToEdit = [self.eventList objectAtIndex:indexPath.row];
    }
    
    if([segue.identifier isEqualToString:@"MapEvents"])
    {
        //This segues lead to the EventDetailsController.
        MapViewController *controller = segue.destinationViewController;
        //Set the view title
        controller.eventList = self.eventList;
        controller.mapMode = @"DisplayAll";
    }
}


#pragma mark - Event Details Controller Delegate

-(void)eventDetailsController:(EventDetailsController *)controller didCreateEvent:(Event *)event
{
    //This method is called when the EventDetailsController creates a new event object.
    //The new Event is added to the eventList and the event list is sorted.
    [self.eventList addObject:event];
    [self.eventList sortUsingDescriptors:@[dateSortDescriptor]];
    
    //Update the table view
    [self.tableView reloadData];
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(void)eventDetailsController:(EventDetailsController *)controller didSaveEvent:(Event *)event
{
    //This method is called when the EventDetailsController updates an existing event object.
    //The array is sorted again.
    [self.eventList sortUsingDescriptors:@[dateSortDescriptor]];
    
    //Update the table view
    [self.tableView reloadData];
    
    [controller dismissViewControllerAnimated:YES completion:nil];
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

@end
