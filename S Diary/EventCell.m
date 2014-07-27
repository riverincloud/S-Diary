//
//  EventCell.m
//  S Diary
//
//  Created by Di Zhang on 11/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


#import "EventCell.h"


@implementation EventCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
