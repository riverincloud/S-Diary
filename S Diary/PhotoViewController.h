//
//  PhotoViewController.h
//  S Diary
//
//  Created by Di Zhang on 19/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


@class Photo;


@class PhotoViewController;

@protocol PhotoViewControllerDelegate <NSObject>

//Call this method on delegate object when a Photo object is to be deleted.
-(void)photoViewController:(PhotoViewController*)controller didDeletePhoto:(NSIndexPath*)indexPath;

@end


@interface PhotoViewController : UIViewController <UIActionSheetDelegate, UIPopoverControllerDelegate>

@property (weak, nonatomic) id<PhotoViewControllerDelegate> delegate; //A delegate object.

@property (strong, nonatomic) NSIndexPath* indexPath;
@property (strong, nonatomic) UIImage* imageToView;

- (IBAction)deletePhoto:(id)sender;

@end