//
//  LocationBookmarksController.m
//  S Diary
//
//  Created by Di Zhang on 19/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


#import "LocationBookmarksController.h"


static NSString * BookmarkSelectedNotification = @"Bookmark Selected for Map to Display Notification"; //BookmarkSelectedNotification's name


@interface LocationBookmarksController ()
{    
    NSSortDescriptor* nameSortDescriptor; //A private sort descriptor for sorting the list by name.
}

@end


@implementation LocationBookmarksController


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* contactDescription = [NSEntityDescription entityForName:@"Bookmark" inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:contactDescription];
    [fetchRequest setSortDescriptors:@[nameSortDescriptor]];
    
    NSError* error;
    
    NSMutableArray* fetchResults = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    if(fetchResults != nil)
    {
        self.bookmarkList = fetchResults;
    }
    else
    {
        NSLog(@"Core Data Fetch Error: %@", [error description]);
        [self displayError:error];
    }
}
/*
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.bookmarkList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BookmarkCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Bookmark* bookmark = [self.bookmarkList objectAtIndex:indexPath.row];
    cell.textLabel.text = bookmark.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //Deleting a bookmark
        NSManagedObject* objectToDelete = [self.bookmarkList objectAtIndex:indexPath.row];
        [self.managedObjectContext deleteObject:objectToDelete];
        [self.bookmarkList removeObject:objectToDelete];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        NSError* error;
        if(![self.managedObjectContext save:&error])
        {
            NSLog(@"Core Data Error: %@", error.description);
            [self displayError:error];
        }
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Bookmark* bookmark = [self.bookmarkList objectAtIndex:indexPath.row];
    
    //Post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:BookmarkSelectedNotification object:nil userInfo:[NSDictionary dictionaryWithObject:bookmark forKey:@"Bookmark"]];
    
    [self.navigationController popViewControllerAnimated:YES];
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
