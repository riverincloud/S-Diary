//
//  Event.h
//  S Diary
//
//  Created by Di Zhang on 31/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


@class Attendee, Location, Photo;


@interface Event : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * cost;
@property (nonatomic, retain) NSDate * end;
@property (nonatomic, retain) NSDecimalNumber * rate;
@property (nonatomic, retain) NSDate * start;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *attendees;
@property (nonatomic, retain) Location *location;
@property (nonatomic, retain) NSSet *photos;

@end


@interface Event (CoreDataGeneratedAccessors)

- (void)addAttendeesObject:(Attendee *)value;
- (void)removeAttendeesObject:(Attendee *)value;
- (void)addAttendees:(NSSet *)values;
- (void)removeAttendees:(NSSet *)values;

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
