//
//  LocationBookmarksController.h
//  S Diary
//
//  Created by Di Zhang on 19/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


#import "Bookmark.h"


@interface LocationBookmarksController : UITableViewController

@property (strong, nonatomic) NSMutableArray* bookmarkList; //Stores the bookmark objects in the app's memory. Used as a data source for the table view.
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;

@end