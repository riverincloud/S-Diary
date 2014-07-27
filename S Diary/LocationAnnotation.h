//
//  LocationAnnotation.h
//  S Diary
//
//  Created by Di Zhang on 19/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


@interface LocationAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;

@property (nonatomic, strong) MKMapItem *mapItem;

@end