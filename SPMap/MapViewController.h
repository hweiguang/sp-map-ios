//
//  MapViewController.h
//  SPMap
//
//  Created by Wei Guang on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArcGIS.h"
#import "SPMapAppDelegate.h"

@class OverlayViewController;

@interface MapViewController : UIViewController <AGSMapViewDelegate,CLLocationManagerDelegate,UISearchBarDelegate> {
    AGSMapView *_mapView;
    AGSGraphicsLayer *_graphicsLayer;
	AGSCalloutTemplate *_CalloutTemplate;
    NSMutableArray *locations; //Array for storing all locations from XML
    NSString *selectedLocations; //selectedLocations from other Views
    
    //Variables for calculating the map extent to be displayed
    double xmin;
    double ymin;
    double xmax;
    double ymax;
    
    int ptcount; //Integer used to count the number of points to be displayed
    double ptlat; //point latitude
    double ptlon; //point longitude
    
    //Location Manager used to check the accuracy of the GPS signal and getting the location coordinate
    CLLocationManager *locationManager;
    double accuracy;
    double lat;
    double lon;
    
    //UI Components
    UIToolbar *toolBar;
    UISearchBar *searchBar;
    UIPopoverController *popOver; //Popover for iPad only
    UIButton *rotateMapButtonItem; //Custom UIButton for rotateMapButton
    
    //Overlay for Search Results
    OverlayViewController *overlayViewController;
    //Array for storing search results
    NSMutableArray *searchResults;
    
    BOOL rotateMap; //if YES map will be rotated according to user heading
    BOOL visible;
}

@property (nonatomic, retain) IBOutlet AGSMapView *mapView;
@property (nonatomic, retain) AGSGraphicsLayer *graphicsLayer;
@property (nonatomic, retain) AGSCalloutTemplate *CalloutTemplate;
@property (nonatomic, retain) NSString *selectedLocations;
@property (nonatomic, retain) UIToolbar *toolBar;
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) NSMutableArray *searchResults;
@property double lat;
@property double lon;

- (void) showCategories:(id)sender;
- (void) showAbout:(id)sender;
- (void) centerUserLocation:(id)sender;
- (void) loadCallout;
- (void) setMapExtent;
- (void) addtoolBar;
- (void) addsearchBar;
- (void) searchLocations;
- (void) setupLocationManager;
- (void) rotateMap:(id)sender;

@end
