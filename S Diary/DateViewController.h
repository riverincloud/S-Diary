//
//  DateViewController.h
//  S Diary
//
//  Created by Di Zhang on 19/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


@interface DateViewController : UIViewController

@property (nonatomic, strong) NSManagedObject *editedObject;
@property (nonatomic, strong) NSString *editedFieldKey;
@property (nonatomic, strong) NSString *editedFieldName;

@end