//
//  Photo.h
//  S Diary
//
//  Created by Dallas Keith Matheson on 21/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


@class Event;


@interface Photo : NSManagedObject

@property (nonatomic, retain) UIImage* image;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) Event *event;

@end
