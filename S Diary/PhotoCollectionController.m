//
//  PhotoCollectionController.m
//  S Diary
//
//  Created by Di Zhang on 19/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


#import "PhotoCollectionController.h"


@interface PhotoCollectionController ()
{
    NSSortDescriptor* timeSortDescriptor; //A private sort descriptor for sorting the list by timestamp.
}

@property (retain, readwrite) UIPopoverController *popover;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;

@end


@implementation PhotoCollectionController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&timeSortDescriptor count:1];
    
    NSMutableArray *sortedPhotos = [[NSMutableArray alloc] initWithArray:[self.eventToEdit.photos allObjects]];
	[sortedPhotos sortUsingDescriptors:sortDescriptors];
	self.photoList = sortedPhotos;
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


#pragma mark - Collection view data source

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.photoList count];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //Custome cell - create a PhotoCell object
    static NSString *CellIdentifier = @"PhotoCell";
    PhotoCell* cell = (PhotoCell*)[self.collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Photo *photo = [self.photoList objectAtIndex:indexPath.row];
    UIImage *image = photo.image;
    cell.photoView.image = image;
    
    return cell;
}


- (IBAction)openCamera:(id)sender
{    
    //If a popover is already showing, dismiss it.
    if(self.popover)
    {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
        return;
    }
    
    //UIImagePickerController allow user to choose an image.
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    //Decide open camera or photo library.
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
    }
    else
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //On iPad we need to present the photo library browser in a popover.
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            //If a popover is already showing, dismiss it before presenting a new one.
            if(self.popover)
            {
                [self.popover dismissPopoverAnimated:YES];
                self.popover = nil;
                return;
            }
            
            UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            popoverController.delegate = self;
            self.popover = popoverController;
            [popoverController presentPopoverFromBarButtonItem:self.cameraButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else
        {
            [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
        }
    }
}


#pragma mark - UIImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    //Save the new image to the Camera Roll (optional)
    //UIImageWriteToSavedPhotosAlbum (image, nil, nil , nil);
    
    //Create a new Photo object.
    Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
    
    //Set the image and timestamp properties for the new photo.
	[photo setValue:image forKey:@"image"];
    [photo setTimestamp:[NSDate date]];
    
    //Associate the new Photo object with the current event to edit.
    [self.eventToEdit addPhotosObject:photo];
        
    /*
     Save the managed object context.
     */
    NSError* error;
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Core Data Error: %@", error.description);
        [self displayError:error];
    }
    
    //Add to photo list and update view.
    [self.photoList addObject:photo];
    [self.photoList sortUsingDescriptors:@[timeSortDescriptor]];
    [self.collectionView reloadData];
    
    //Dismiss the image picker.
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ViewPhoto"])
    {
        PhotoViewController* controller = segue.destinationViewController;
        //Find the selected photo.
        NSIndexPath* indexPath = [self.collectionView indexPathForCell:sender];
        controller.indexPath = indexPath;
        Photo *photo = [self.photoList objectAtIndex:indexPath.row];
        controller.imageToView = photo.image;
        controller.delegate = self;
    }
}


#pragma mark - PhotoViewController delegate

-(void)photoViewController:(PhotoViewController*)controller didDeletePhoto:(NSIndexPath*)indexPath
{
    //Select the object to delete
    NSManagedObject* objectToDelete = [self.photoList objectAtIndex:indexPath.row];
    NSLog(@"Photo to delete: %@", objectToDelete);
    
    //Delete it from the managed object context
    [self.managedObjectContext deleteObject:objectToDelete];
    //Then the photo array
    [self.photoList removeObject:objectToDelete];
    //Then the collection
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    
    /*
     Save the managed object context.
     */
    NSError* error;
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Core Data Error: %@", error.description);
        [self displayError:error];
    }
    
    //Update view to show the change.
    [self.collectionView reloadData];
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