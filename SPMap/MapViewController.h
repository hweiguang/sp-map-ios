//
//  MapViewController.h
//  SPMap
//
//  Created by Wei Guang on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArcGIS.h"

@interface MapViewController : UIViewController <AGSMapViewDelegate,CLLocationManagerDelegate> {
    AGSMapView *_mapView;
    AGSGraphicsLayer *_graphicsLayer;
	AGSCalloutTemplate *_CalloutTemplate;
    NSMutableArray *locations; //Array for storing all locations from XML
    NSString *selectedLocations; //selectedLocations from ListView
    
    //Doubles for calculating the map extent to be displayed
    double xmin;
    double ymin;
    double xmax;
    double ymax;
    
    //Integer used to count the number of points to be displayed 
    int ptcount;
    
    //Location Manager used to check the accuracy of the GPS signal and getting the location coordinate
    CLLocationManager *locationManager;
    double accuracy;
    double lat;
    double lon;
    
    //Toolbar on iPhone only
    UIToolbar *toolbar;
}

@property (nonatomic, retain) IBOutlet AGSMapView *mapView;
@property (nonatomic, retain) AGSGraphicsLayer *graphicsLayer;
@property (nonatomic, retain) AGSCalloutTemplate *CalloutTemplate;
@property (nonatomic, retain) NSString *selectedLocations;
@property (nonatomic, retain) UIToolbar *toolbar;

- (void) showCategories:(id)sender;
- (void) showAbout:(id)sender;
- (void) centerUserLocation:(id)sender;
- (void) loadCallout;
- (void) setMapExtent;
- (void) loadToolbar;

@end
