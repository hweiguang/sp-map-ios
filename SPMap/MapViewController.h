//
//  MapViewController.h
//  SPMap
//
//  Created by Wei Guang on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArcGIS.h"
#import "Location.h"

@interface MapViewController : UIViewController <AGSMapViewDelegate> {
    AGSMapView *_mapView;
    AGSGraphicsLayer *_graphicsLayer;
	AGSCalloutTemplate *_CalloutTemplate;
    
    NSMutableArray *locations; //Array for storing all locations from XML
    NSString *selectedLocations; //selectedLocations from ListView
}

@property (nonatomic, retain) IBOutlet AGSMapView *mapView;
@property (nonatomic, retain) AGSGraphicsLayer *graphicsLayer;
@property (nonatomic, retain) AGSCalloutTemplate *CalloutTemplate;
@property (nonatomic, retain) NSString *selectedLocations;

- (IBAction) showCategories;
- (IBAction) showAbout;
- (void) showCallout;

@end
