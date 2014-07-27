//
//  Location.h
//  S Diary
//
//  Created by Di Zhang on 21/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


@class Event;


@interface Location : NSManagedObject

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Event *event;

@end
