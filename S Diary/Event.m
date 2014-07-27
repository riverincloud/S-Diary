//
//  Event.m
//  S Diary
//
//  Created by Di Zhang on 31/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


#import "Event.h"
#import "Attendee.h"
#import "Location.h"
#import "Photo.h"
#import "ImageToDataTransformer.h"


@implementation Event

@dynamic cost;
@dynamic end;
@dynamic rate;
@dynamic start;
@dynamic title;
@dynamic attendees;
@dynamic location;
@dynamic photos;

+ (void)initialize
{
	if (self == [Event class])
    {
		ImageToDataTransformer *transformer = [[ImageToDataTransformer alloc] init];
		[NSValueTransformer setValueTransformer:transformer forName:@"ImageToDataTransformer"];
	}
}

@end
