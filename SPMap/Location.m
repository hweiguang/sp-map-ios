//
//  Location.m
//  SP Map
//
//  Created by Wei Guang on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Location.h"

@implementation Location

@synthesize title;
@synthesize subtitle;
@synthesize lat;
@synthesize lon;
@synthesize category;
@synthesize detaildescription;
@synthesize photos;
@synthesize panorama;
@synthesize identity;
@synthesize livecam;
@synthesize video;

- (id)init
{
    self = [super init];
    if (self) {
        title = [[NSString alloc] init];
        subtitle = [[NSString alloc] init];
        lat = [[NSNumber alloc] initWithDouble:0];
        lon = [[NSNumber alloc] initWithDouble:0];
        category = [[NSString alloc] init];
        detaildescription = [[NSString alloc] init];
        photos = [[NSString alloc] init];
        panorama = [[NSString alloc] init];
        identity = [[NSString alloc] init];
        livecam = [[NSString alloc] init];
        video = [[NSString alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [title release];
	[subtitle release];
	[lat release];
	[lon release];
    [category release];
    [detaildescription release];
    [photos release];
    [panorama release];
    [identity release];
    [livecam release];
    [video release];
    [super dealloc];
}

@end
