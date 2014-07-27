//
//  PhotoCollectionController.h
//  S Diary
//
//  Created by Di Zhang on 19/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


#import "Event.h"
#import "Photo.h"
#import "PhotoCell.h"
#import "PhotoViewController.h"


@interface PhotoCollectionController : UICollectionViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, PhotoViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray* photoList; //Stores the Photo objects in the app's memory. Used as a data source for the collection view.
@property (strong, nonatomic) Event* eventToEdit;
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;

- (IBAction)openCamera:(id)sender;

@end