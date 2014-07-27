//
//  DateViewController.m
//  S Diary
//
//  Created by Di Zhang on 19/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


#import "DateViewController.h"


@interface DateViewController ()

@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;

@end


@implementation DateViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    // Set the title to the user-visible name of the field.
    self.title = self.editedFieldName;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Configure the view.
    NSDate *date = [self.editedObject valueForKey:self.editedFieldKey];
    if (date == nil)
    {
        date = [NSDate date];
    }
    self.datePicker.date = date;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Save and cancel operations

- (IBAction)save:(id)sender
{
    // Pass current value to the edited object.
    [self.editedObject setValue:self.datePicker.date forKey:self.editedFieldKey];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender
{
    // Don't pass current value to the edited object, just pop.
    [self.navigationController popViewControllerAnimated:YES];
}

@end