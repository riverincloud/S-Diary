//
//  EventDetailsController.m
//  S Diary
//
//  Created by Di Zhang on 11/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


#import "EventDetailsController.h"


static NSString * LocationCreatedNotification = @"Location Created Notification"; //LocationCreatedNotification's name
static NSString * EventChangedNotification = @"Event Changed Notification"; //EventChangedNotification's name


@interface EventDetailsController ()
{
    BOOL editMode; //A private boolean that defines whether creating or editing an event.
}

@property (weak, nonatomic) IBOutlet UITextField *titleText;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *endLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UITextField *costText;
@property (weak, nonatomic) IBOutlet UISlider *rateSlider;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;

@end


@implementation EventDetailsController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Register with a notification center to receive notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationCreated:) name:LocationCreatedNotification object:nil];
    
    //Set up the text field delegates so can dismiss the keyboard
    self.titleText.delegate = self;
    self.costText.delegate = self;
    
    if(self.eventToEdit != nil)
    {
        //In edit mode
        editMode = YES;
        
        //Populate the text fields
        self.titleText.text = self.eventToEdit.title;
        
        //Prevent field text to display "NaN (not a number)".
        if (self.eventToEdit.rate == [NSDecimalNumber notANumber]) {
            self.rateLabel.text = @"";
        } else {
            self.rateLabel.text = [NSString stringWithFormat:@"%@", self.eventToEdit.rate];
        }
        if (self.eventToEdit.cost == [NSDecimalNumber notANumber]) {
            self.costText.text = @"";
        } else {
            self.costText.text = [NSString stringWithFormat:@"%@", self.eventToEdit.cost];
        }
        
        //Set up the rate slider.
        [self.rateSlider setValue:[self.eventToEdit.rate floatValue] animated:NO];
        
        //Set the text on the startLabel and endLabel to the formatted date.
        self.startLabel.text = [self.dateFormatter stringFromDate:self.eventToEdit.start];
        self.endLabel.text = [self.dateFormatter stringFromDate:self.eventToEdit.end];
        
        //Set the text on the locationLabel.
        self.locationLabel.text = self.eventToEdit.location.name;
    }
    else
    {
        //In create mode - create a new Event object
        editMode = NO;
        self.eventToEdit = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Update the text on startLabel and endLabel.
    self.startLabel.text = [self.dateFormatter stringFromDate:self.eventToEdit.start];
    self.endLabel.text = [self.dateFormatter stringFromDate:self.eventToEdit.end];
    //Update the text on locationLabel.
    self.locationLabel.text = self.eventToEdit.location.name;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //This method tells the text fields to resign the first responder status when the return button in pressed.
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"EditStart"])
    {
        DateViewController *controller = (DateViewController *)[segue destinationViewController];
        //Pass the current event object.
        controller.editedObject = self.eventToEdit;
        //Set the edited field key property of controller.
        controller.editedFieldKey = @"start";
        controller.editedFieldName = NSLocalizedString(@"Start Time", @"display name for start");
    }
    
    if ([[segue identifier] isEqualToString:@"EditEnd"])
    {
        DateViewController *controller = (DateViewController *)[segue destinationViewController];
        controller.editedObject = self.eventToEdit;
        controller.editedFieldKey = @"end";
        controller.editedFieldName = NSLocalizedString(@"End Time", @"display name for end");
    }
    
    if([segue.identifier isEqualToString:@"EditLocation"])
    {
        MapViewController* controller = (MapViewController *)[segue destinationViewController];
        //Pass the managed object context.
        controller.managedObjectContext = self.managedObjectContext;
        controller.eventToEdit = self.eventToEdit;
        controller.mapMode = @"DisplayOne";
    }

    if([segue.identifier isEqualToString:@"EditAttendees"])
    {
        AttendeeListController* controller = (AttendeeListController *)[segue destinationViewController];
        controller.managedObjectContext = self.managedObjectContext;
        controller.eventToEdit = self.eventToEdit;
    }
    
    if([segue.identifier isEqualToString:@"EditPhotos"])
    {
        PhotoCollectionController* controller = (PhotoCollectionController *)[segue destinationViewController];
        controller.managedObjectContext = self.managedObjectContext;
        controller.eventToEdit = self.eventToEdit;
    }
}


#pragma mark - Cancel and Save operation

- (IBAction)cancel:(id)sender
{
    //Dismiss view controller without saving any changes.
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)save:(id)sender
{
    //Input validation
    BOOL validated = YES;
    if([self.titleText.text isEqualToString:@""])
    {
        //Sets the border of the text field to red if there is no content.
        self.titleText.layer.cornerRadius=8.0f;
        self.titleText.layer.masksToBounds=YES;
        self.titleText.layer.borderColor=[[UIColor redColor]CGColor];
        self.titleText.layer.borderWidth= 1.5f;
        validated = NO;
    }
    if ([self.eventToEdit.end timeIntervalSinceDate:self.eventToEdit.start] < 0)
    {
        self.endLabel.layer.cornerRadius=8.0f;
        self.endLabel.layer.masksToBounds=YES;
        self.endLabel.layer.borderColor=[[UIColor redColor]CGColor];
        self.endLabel.layer.borderWidth= 1.5f;
        validated = NO;
    }
        
    //If the validation passed
    if(validated)
    {
        //Update the event to edit with the new values
        self.eventToEdit.title = self.titleText.text;
        self.eventToEdit.rate = [NSDecimalNumber decimalNumberWithString:self.rateLabel.text];
        NSLog(@"Event rate: %@", self.eventToEdit.rate);
        self.eventToEdit.cost = [NSDecimalNumber decimalNumberWithString:self.costText.text];
        NSLog(@"Event cost: %@", self.eventToEdit.cost);
        
        //If in edit mode, call the saving method on delegate; Otherwise, call the creating method on delegate.
        if(editMode)
            [self.delegate eventDetailsController:self didSaveEvent:self.eventToEdit];
        else
            [self.delegate eventDetailsController:self didCreateEvent:self.eventToEdit];
        
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
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        //If the validation failed, show an alert.
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Input Error"
                                                        message:@"Invalid inputs for the highlighted fields."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)updateRateLabel:(id)sender
{
    //Convert the slider value into numeric string (1, 2, ... 10).
    self.rateLabel.text = [NSString stringWithFormat:@"%1.0f", self.rateSlider.value];
}


#pragma mark Notifications handlers

- (void)locationCreated:(NSNotification *)notification
{
    Location *location = [notification.userInfo objectForKey:@"Location"];
    self.eventToEdit.location = location;
    
    /*
     Save the managed object context.
     */
    NSError* error;
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Core Data Error: %@", error.description);
        [self displayError:error];
    }
    
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

@end
