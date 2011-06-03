//
//  Location.h
//  SP Map
//
//  Created by Wei Guang on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Location : NSObject {
	NSString *title; //Title for callout
	NSString *subtitle; //Subtitle for callout
	NSNumber *lat; //Latitude for callout
	NSNumber *lon; //Longitude for callout
    NSString *category; //Category of the callout
    NSString *description; //Description to be display in detail view
    NSString *photos; //Photo to be display in detail view
    NSString *panorama; //Link to panorama
    NSString *identity; //id for the points
    NSString *livecam;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) NSNumber *lat;
@property (nonatomic, retain) NSNumber *lon;
@property (nonatomic, retain) NSString *category;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *photos;
@property (nonatomic, retain) NSString *panorama;
@property (nonatomic, retain) NSString *identity;
@property (nonatomic, retain) NSString *livecam;

@end
