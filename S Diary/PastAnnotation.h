//
//  PastAnnotation.h
//  S Diary
//
//  Created by Di Zhang on 30/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


#import "LocationAnnotation.h"


@interface PastAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;

@property (nonatomic, strong) MKMapItem *mapItem;

@end
