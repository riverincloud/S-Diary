//
//  AttendeeListController.m
//  S Diary
//
//  Created by Di Zhang on 11/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


#import "AttendeeListController.h"


static NSString * AttendeeChangedNotification = @"Attendee Changed Notification"; //AttendeeChangedNotification's name


@interface AttendeeListController ()
{
    NSSortDescriptor* nameSortDescriptor; //A private sort descriptor for sorting the list by name.
}

@end


@implementation AttendeeListController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* contactDescription = [NSEntityDescription entityForName:@"Attendee" inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:contactDescription];
    [fetchRequest setSortDescriptors:@[nameSortDescriptor]];
    
    NSError* error;
    
    NSMutableArray* fetchResults = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    if(fetchResults != nil)
    {
        self.attendeesList = fetchResults;
    }
    else
    {
        NSLog(@"Core Data Fetch Error: %@", [error description]);
        [self displayError:error];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    //When the view disappears, save all the changes made so far.
    NSError* error;
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Core Data Error: %@", error.description);
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
    return [self.attendeesList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AttendeeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Attendee* attendeeToDisplay = [self.attendeesList objectAtIndex:indexPath.row];
    cell.textLabel.text = attendeeToDisplay.name;
    
    //Check if this Attendee object is inside the (NSSet) attendees of the current event.
    if([self.eventToEdit.attendees containsObject:attendeeToDisplay])
    {
        //If yes, display check mark to indicate this status.
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        //if not, no check mark.
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //Deleting an Attendee
        NSManagedObject* objectToDelete = [self.attendeesList objectAtIndex:indexPath.row];
        [self.managedObjectContext deleteObject:objectToDelete];
        [self.attendeesList removeObject:objectToDelete];
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
        
        //Post notification.
        [[NSNotificationCenter defaultCenter] postNotificationName:AttendeeChangedNotification object:nil];
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    //Find the selected Attendee object.
    Attendee* selectedAttendee = [self.attendeesList objectAtIndex:indexPath.row];
    
    //If this attendee is already in the event to edit, remove it from the event.
    if([self.eventToEdit.attendees containsObject:selectedAttendee])
    {
        [self.eventToEdit removeAttendeesObject:selectedAttendee];
    }
    //Otherwise, add it to the event.
    else
    {
        [self.eventToEdit addAttendeesObject:selectedAttendee];
    }
    //Update the table view to show the appearance or disappearance of the check mark.
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    //Post notification.
    [[NSNotificationCenter defaultCenter] postNotificationName:AttendeeChangedNotification object:nil];
}


/**
 The methods below would present the user interface of the Contacts List from the Address Book, 
 allowing user to select a Person as an attendee.
 A new Attendee object will then be created with the name of the Person.
 */

/**
 Present the ABPeoplePickerNavigationController object in modal mode.
 */
- (IBAction)showPicker:(id)sender
{
    ABPeoplePickerNavigationController *picker =
    [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
    
}


#pragma mark - ABPeoplePickerNavigationController delegate

- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker
{
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    //Call this method to create a new Attendee object with the person picked from Address Book.
    [self createAttendee:person];
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    return NO;
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}


/**
 Method for creating a new Attendee object and add it to attendee list.
 */
- (void)createAttendee:(ABRecordRef)person
{
    NSString* firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person,
                                                                    kABPersonFirstNameProperty);
    NSString* lastName = (__bridge_transfer NSString*)ABRecordCopyValue(person,
                                                                         kABPersonLastNameProperty);
    
    Attendee* attendee = [NSEntityDescription insertNewObjectForEntityForName:@"Attendee" inManagedObjectContext:self.managedObjectContext];
    attendee.name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    /*
     Save the managed object context.
     */
    NSError* error;
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Core Data Error: %@", error.description);
        [self displayError:error];
    }
    
    [self.attendeesList addObject:attendee];
    [self.attendeesList sortUsingDescriptors:@[nameSortDescriptor]];
    [self.tableView reloadData];
    
    //Post notification.
    [[NSNotificationCenter defaultCenter] postNotificationName:AttendeeChangedNotification object:nil];
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
