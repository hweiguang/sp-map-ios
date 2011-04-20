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
    NSMutableSet *selectedCategories; //Set for keeping selectedCategory state
    NSMutableSet *lastSelectedCategories; //Keep track of selected categories
    
    BOOL isReturnView;
}

@property (nonatomic, retain) IBOutlet AGSMapView *mapView;
@property (nonatomic, retain) AGSGraphicsLayer *graphicsLayer;
@property (nonatomic, retain) AGSCalloutTemplate *CalloutTemplate;
@property (nonatomic, retain) NSMutableSet *selectedCategories;
@property (nonatomic, retain) NSMutableSet *lastSelectedCategories;

- (IBAction) showCategories;
- (IBAction) showAbout;
- (void) showCallout;

@end
