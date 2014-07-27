//
//  ReportViewController.m
//  S Diary
//
//  Created by Di Zhang on 23/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


#import "ReportViewController.h"


static NSString * EventChangedNotification = @"Event Changed Notification"; //EventChangedNotification's name
static NSString * AttendeeChangedNotification = @"Attendee Changed Notification"; //AttendeeChangedNotification's name


@interface ReportViewController ()
{
    //A private sort descriptor for sorting the list by values of property selected by user (name, costTotal or rateTotal).
    NSSortDescriptor* customSortDescriptor;
}

@end


@implementation ReportViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Register with a notification center to receive notifications, so the report could update itself following the changes of event and/or attendee.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportChanged:) name:EventChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportChanged:) name:AttendeeChangedNotification object:nil];
    
    [self resetView];
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.attendeeList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Custom cell - create a ReportCell object.
    static NSString *CellIdentifier = @"ReportCell";
    ReportCell *cell = (ReportCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Attendee* attendeeToDisplay = [self.attendeeList objectAtIndex:indexPath.row];
    
    //We then configure our cell
    cell.attendeeLabel.text = attendeeToDisplay.name;
    cell.costLabel.text = [NSString stringWithFormat:@"%@ %@", attendeeToDisplay.costAvg, @"AUD"];
    cell.rateLabel.text = [NSString stringWithFormat:@"%@ %@", attendeeToDisplay.rateAvg, @"Stars"];
    
    return cell;
}


#pragma mark - Notifications handlers

- (void)reportChanged:(NSNotification *)notification
{
    NSLog(@"Notification received");
    [self resetView];
}


- (void)resetView
{
    //Create a default sort descripter for sorting the list by name.
    NSSortDescriptor * defaultSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
    //If the custome sort descriptor is nil, set it with the default sort descriptor.
    if (customSortDescriptor == nil)
    {
        customSortDescriptor = defaultSortDescriptor;
    }
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* contactDescription = [NSEntityDescription entityForName:@"Attendee" inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:contactDescription];
    [fetchRequest setSortDescriptors:@[customSortDescriptor]];
    
    NSError* error;
    
    NSMutableArray* fetchResults = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    if(fetchResults != nil)
    {
        self.attendeeList = fetchResults;
    }
    else
    {
        NSLog(@"Core Data Fetch Error: %@", [error description]);
        [self displayError:error];
    }
    
    /**
     Calculate methods
     */
    for (Attendee * attendee in self.attendeeList)
    {
        NSDecimalNumber *rateTotal = [NSDecimalNumber zero];
        NSDecimalNumber *costTotal = [NSDecimalNumber zero];
        NSDecimalNumber *rateCount = [NSDecimalNumber zero];
        NSDecimalNumber *costCount = [NSDecimalNumber zero];;
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
        
        NSMutableArray *eventList = [[NSMutableArray alloc] initWithArray:[attendee.events allObjects]];
        [eventList sortUsingDescriptors:sortDescriptors];
        
        for (Event * event in eventList)
        {
            NSDecimalNumber * rate = event.rate;
            NSDecimalNumber * cost = event.cost;
            
            if (rate != [NSDecimalNumber notANumber]) {
                rateTotal = [rateTotal decimalNumberByAdding:rate];
                rateCount = [rateCount decimalNumberByAdding:[NSDecimalNumber one]];
            }
            
            if (cost != [NSDecimalNumber notANumber]) {
                costTotal = [costTotal decimalNumberByAdding:cost];
                costCount = [costCount decimalNumberByAdding:[NSDecimalNumber one]];
            }
        }
        if (rateCount != [NSDecimalNumber zero]) {
            attendee.rateAvg = [rateTotal decimalNumberByDividingBy:rateCount];
        }
        if (costCount != [NSDecimalNumber zero]) {
        attendee.costAvg = [costTotal decimalNumberByDividingBy:costCount];
        }
    }
    
    NSLog(@"Attendee list: %@", self.attendeeList);
    
    [self.tableView reloadData];
}


/**
 Set the custom sort descriptor according to user's choice.
 */
- (IBAction)setSortDescriptor:(UISegmentedControl*)sender
{
    switch(sender.selectedSegmentIndex)
    {
        case 0:
            customSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
            [self resetView];
            break;
        case 1:
            customSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"costAvg" ascending:NO];
            [self resetView];
            break;
        case 2:
            customSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rateAvg" ascending:NO];
            [self resetView];
            break;
    }
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
