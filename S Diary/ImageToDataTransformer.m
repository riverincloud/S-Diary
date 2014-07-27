//
//  ImageToDataTransformer.m
//  S Diary
//
//  Created by Di Zhang on 18/05/13.
//  Copyright (c) 2013 Di Zhang. All rights reserved.
//


#import "ImageToDataTransformer.h"


@implementation ImageToDataTransformer

+ (BOOL)allowsReverseTransformation
{
	return YES;
}

+ (Class)transformedValueClass
{
	return [NSData class];
}

- (id)transformedValue:(id)value
{
	return UIImagePNGRepresentation(value);
}

- (id)reverseTransformedValue:(id)value
{
	return [[UIImage alloc] initWithData:value];
}

@end
