//
//  LocationSearchController.h
//  S Diary
//
//  Created by Di Zhang on 28/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


@class LocationSearchController;

@protocol LocationSearchControllerDelegate <NSObject>

- (void)locationSearchController:(LocationSearchController*)controller didSelectItem:(MKMapItem*)item;
- (void)dismissLocationSearchController:(LocationSearchController *)controller;

@end


@interface LocationSearchController : UITableViewController <UISearchBarDelegate>

@property (nonatomic, strong) NSArray *places; //Stores the MKMapItem objects in the app's memory. Used as a data source for the table view for the search results.

@property (weak, nonatomic) id<LocationSearchControllerDelegate> delegate;

- (IBAction)cancel:(id)sender;

@end