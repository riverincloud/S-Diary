//
//  Attendee.h
//  S Diary
//
//  Created by Di Zhang on 31/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


@class Event;


@interface Attendee : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * costAvg;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDecimalNumber * rateAvg;
@property (nonatomic, retain) NSSet *events;

@end


@interface Attendee (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

@end
