//
//  PhotoViewController.m
//  S Diary
//
//  Created by Di Zhang on 19/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


#import "PhotoViewController.h"


@interface PhotoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) UIActionSheet *actionSheet;

@end


@implementation PhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.image = self.imageToView;
}


#pragma mark - Action Sheet

#define ACTION @"Delete Photo"
#define ACTION_CANCEL @"Cancel"
#define ACTION_DELETE @"Delete"

- (IBAction)deletePhoto:(id)sender
{
    if (!self.actionSheet)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:ACTION
                                                                 delegate:self
                                                        cancelButtonTitle:ACTION_CANCEL
                                                   destructiveButtonTitle:ACTION_DELETE
                                                        otherButtonTitles:nil];
        [actionSheet showFromBarButtonItem:sender animated:YES];
        self.actionSheet = actionSheet;
    }
}

/**
 UIActionSheet delegate method called when the user chooses something
 */
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex)
    {
        //Call this method on delegate to delete the photo.
        [self.delegate photoViewController:self didDeletePhoto:self.indexPath];
        NSLog(@"Index for delete: %@", self.indexPath);
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end