//
//  MapViewController.m
//  SPMap
//
//  Created by Wei Guang on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "CategoriesViewController.h"
#import "DetailViewController.h"
#import "AboutViewController.h"
#import "Constants.h"
#import "OverlayViewController.h"
#import "ListViewController.h"

@implementation MapViewController

@synthesize mapView = _mapView;
@synthesize graphicsLayer = _graphicsLayer;
@synthesize CalloutTemplate = _CalloutTemplate;
@synthesize selectedPoint;
@synthesize searchResults;
@synthesize searchBar;
@synthesize toolBar;
@synthesize lat;
@synthesize lon;

- (void) checkMapStatus {
    //Check map status first before loading point
    if(mapLoaded)
        [self loadSinglePoint];
    else {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(loadSinglePoint) 
                                                     name:@"mapLoaded" object:nil];
    }
}

- (void)loadSinglePoint {
    //Hide all callout and remove existing points
    self.mapView.callout.hidden = YES;
    [self.graphicsLayer removeAllGraphics];
    
    //create the callout template, used when the user displays the callout
    self.CalloutTemplate = [[[AGSCalloutTemplate alloc]init] autorelease];
    
    double ptlat = [selectedPoint.lat doubleValue];
    double ptlon = [selectedPoint.lon doubleValue];
    
    NSString *callouticonImage = [selectedPoint.category stringByAppendingString:@".jpg"];
    callouticonImage = [callouticonImage lowercaseString];
    callouticonImage = [callouticonImage stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.mapView.callout.image = [UIImage imageNamed:callouticonImage];
    
    //Creating the point to add to map
    AGSPoint *pt = [AGSPoint pointWithX:ptlon y:ptlat spatialReference:self.mapView.spatialReference];
    
    //create a marker symbol to use in our graphic
    AGSPictureMarkerSymbol *marker = [AGSPictureMarkerSymbol 
                                      pictureMarkerSymbolWithImageNamed:@"MapMarker.png"];
    marker.hotspot = CGPointMake(-9,18);
    
    //set the title and subtitle of the callout
    self.CalloutTemplate.titleTemplate = @"${title}";
    self.CalloutTemplate.detailTemplate = @"${subtitle}";
    
    //Attribs for point
    NSMutableDictionary *attribs = [NSMutableDictionary dictionaryWithObject:selectedPoint.title forKey:@"title"];
    [attribs setValue:selectedPoint.subtitle forKey:@"subtitle"];
    [attribs setValue:selectedPoint.detaildescription forKey:@"description"];
    [attribs setValue:selectedPoint.photos forKey:@"photos"];
    [attribs setValue:selectedPoint.panorama forKey:@"panorama"];
    [attribs setValue:selectedPoint.livecam forKey:@"livecam"];
    [attribs setValue:selectedPoint.video forKey:@"video"];
    
    //Creating the graphic
    AGSGraphic *graphic = [[AGSGraphic alloc] initWithGeometry:pt
                                                        symbol:marker
                                                    attributes:attribs
                                          infoTemplateDelegate:self.CalloutTemplate];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self.mapView centerAtPoint:pt animated:YES];
    else
        [self.mapView centerAtPoint:pt animated:NO];
    
    [self.mapView showCalloutAtPoint:pt forGraphic:graphic animated:YES];
    
    //add the graphic to the graphics layer
    [self.graphicsLayer addGraphic:graphic];
    [graphic release];
}

- (void) loadCategoryPoints:(NSArray*)category {
    //Hide all callout and remove existing points
    [self.graphicsLayer removeAllGraphics];
    self.mapView.callout.hidden = YES;
    
    //Variables for calculating the map extent to be displayed
    double xmin = DBL_MAX;
    double ymin = DBL_MAX;
    double xmax = -DBL_MAX;
    double ymax = -DBL_MAX;
    
    //create the callout template, used when the user displays the callout
    self.CalloutTemplate = [[[AGSCalloutTemplate alloc]init] autorelease];
    
    //loop through the array that is passed and add point to graphics layer
    for (int i=0; i<[category count]; i++)
    {
        Location *aLocation = [category objectAtIndex:i];
        
        //Setting the lat and lon from Location class
        double ptlat = [aLocation.lat doubleValue];
        double ptlon = [aLocation.lon doubleValue];
        
        //Adding coordinates to the point
        AGSPoint *pt = [AGSPoint pointWithX:ptlon y:ptlat spatialReference:self.mapView.spatialReference];
        
        //accumulate the min/max, calculating the new map extent
        if (pt.x < xmin)
            xmin = pt.x;
        
        if (pt.x > xmax)
            xmax = pt.x;
        
        if (pt.y < ymin)
            ymin = pt.y;
        
        if (pt.y > ymax)
            ymax = pt.y;
        
        //create a marker symbol to use in our graphic
        AGSPictureMarkerSymbol *marker = [AGSPictureMarkerSymbol 
                                          pictureMarkerSymbolWithImageNamed:@"MapMarker.png"];
        marker.hotspot = CGPointMake(-9,18);
        
        //creating an attribute for the callOuts
        NSMutableDictionary *attribs = [NSMutableDictionary dictionaryWithObject:aLocation.title forKey:@"title"];
        [attribs setValue:aLocation.subtitle forKey:@"subtitle"];
        [attribs setValue:aLocation.detaildescription forKey:@"description"];
        [attribs setValue:aLocation.photos forKey:@"photos"];
        [attribs setValue:aLocation.panorama forKey:@"panorama"];
        [attribs setValue:aLocation.livecam forKey:@"livecam"];
        [attribs setValue:aLocation.video forKey:@"video"];
        
        //set the title and subtitle of the callout
        self.CalloutTemplate.titleTemplate = @"${title}";
        self.CalloutTemplate.detailTemplate = @"${subtitle}";
        
        //Setting the icon image for the callout
        NSString *callouticonImage = [aLocation.category stringByAppendingString:@".jpg"];
        callouticonImage = [callouticonImage lowercaseString];
        callouticonImage = [callouticonImage stringByReplacingOccurrencesOfString:@" " withString:@""];
        self.mapView.callout.image = [UIImage imageNamed:callouticonImage];
        
        //create the graphic
        AGSGraphic *graphic = [[AGSGraphic alloc] initWithGeometry:pt
                                                            symbol:marker
                                                        attributes:attribs
                                              infoTemplateDelegate:self.CalloutTemplate];
        
        //add the graphic to the graphics layer
        [self.graphicsLayer addGraphic:graphic];
        [graphic release];
    }
    //Reload graphic
    [self.graphicsLayer dataChanged];
    
    AGSMutableEnvelope *extent = [AGSMutableEnvelope envelopeWithXmin:xmin
                                                                 ymin:ymin
                                                                 xmax:xmax
                                                                 ymax:ymax
                                                     spatialReference:self.mapView.spatialReference];
    //Calculated extent and zoom out. If value is 1 all pins will be at the corners.
    [extent expandByFactor:3.5];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self.mapView zoomToEnvelope:extent animated:YES];
    else
        [self.mapView zoomToEnvelope:extent animated:NO];
}

//iPad only. This method will only be called when user makes a selection in ListVC
- (void)hidePopover {                                                                                          
    [popOver dismissPopoverAnimated:YES];       
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.mapView.gps start];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    //Start checking the accuracy of GPS
    [locationManager startUpdatingLocation];
    //Star updating user heading
    [locationManager startUpdatingHeading];
    visible = YES;
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.mapView.gps stop];
    //Stop rotating map and rotate map back to normal position
    _mapView.transform = CGAffineTransformMakeRotation(0);
    rotateMap = NO;
    if (rotateMapButtonItem.selected == YES)
        rotateMapButtonItem.selected = NO;
    visible = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //Start listening from ListViewController for user selection
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(hidePopover)
                                                     name:@"hidePopover" 
                                                   object:nil];
    }
    
    [self addtoolBar];
    [self addsearchBar];
    [self setupLocationManager];
    
    //set map view delegate
    self.mapView.layerDelegate = self;
    self.mapView.calloutDelegate = self;
    
    //create and add a base layer to map
	AGSTiledMapServiceLayer *tiledLayer = [[AGSTiledMapServiceLayer alloc]
										   initWithURL:[NSURL URLWithString:kMapServiceURL]];
	[self.mapView addMapLayer:tiledLayer withName:@"SP Map"];
    [tiledLayer release];
    
    //create and add graphics layer to map
	self.graphicsLayer = [AGSGraphicsLayer graphicsLayer];
	[self.mapView addMapLayer:self.graphicsLayer withName:@"Graphics Layer"];
    
    // Adding esriLogo watermark
    UIImageView *watermarkIV;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        watermarkIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 935, 43, 25)];
    else
        watermarkIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 391, 43, 25)];
    watermarkIV.image = [UIImage imageNamed:@"esriLogo.png"];
    [self.view addSubview:watermarkIV];
    [watermarkIV release];
}

- (void) addtoolBar {
    toolBar = [UIToolbar new];
    toolBar.barStyle = UIBarStyleBlack;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) // if user device is an iPhone set the following frame
        toolBar.frame = CGRectMake(0, 416, 320, 44);
    else
        toolBar.frame = CGRectMake(0, 960, 768, 44); //else set the following frame for iPad
    
    [self.view addSubview:toolBar];
    
    //Array for storing all the buttons
    NSMutableArray *items = [[NSMutableArray alloc]init];
    
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil action:nil];
    
    UIBarButtonItem *centerUserLocationButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Location.png"]
                                                                                     style:UIBarButtonItemStylePlain
                                                                                    target:self
                                                                                    action:@selector(centerUserLocation:)];
    
    UIBarButtonItem *showCategoriesButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Category.png"]
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(showCategories:)];
    
    UIBarButtonItem *showAboutButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"About.png"]
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(showAbout:)];
    [items addObject:showCategoriesButtonItem];
    [showCategoriesButtonItem release];
    
    [items addObject:flexItem];
    
    [items addObject:centerUserLocationButtonItem];
    [centerUserLocationButtonItem release];
    
    [items addObject:flexItem];
    
    //Allocate Heading button only when Compass is available
    if ([CLLocationManager headingAvailable] == YES) {
        //load the Heading icon for UIBarButtonItem rotateMapBarButtonItem
        UIImage *HeadingOffImage = [UIImage imageNamed:@"HeadingOff.png"];
        UIImage *HeadingOnImage = [UIImage imageNamed:@"HeadingOn.png"];
        
        rotateMapButtonItem = [UIButton buttonWithType:UIButtonTypeCustom];
        [rotateMapButtonItem setImage:HeadingOffImage forState:!UIControlStateSelected];
        [rotateMapButtonItem setImage:HeadingOnImage forState:UIControlStateSelected];
        rotateMapButtonItem.frame = CGRectMake(0, 0, HeadingOffImage.size.width, HeadingOffImage.size.height);
        [rotateMapButtonItem addTarget:self action:@selector(rotateMap:) forControlEvents:UIControlEventTouchUpInside];
        //creating a UIBarButtonItem with the rotateMapButtonItem as a custom view
        UIBarButtonItem *rotateMapBarButtonItem = [[UIBarButtonItem alloc]init];
        rotateMapBarButtonItem.customView = rotateMapButtonItem;
        
        [items addObject:rotateMapBarButtonItem];
        [items addObject:flexItem];
        
        [rotateMapBarButtonItem release];
    } 
    [items addObject:showAboutButtonItem];
    [showAboutButtonItem release];
    
    [flexItem release];
    
    [self.toolBar setItems:items animated:NO];
    [items release];
}

- (void) addsearchBar {
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0,0,320,44)];
    [searchBar sizeToFit];
    searchBar.barStyle = UIBarStyleBlack;
    searchBar.showsCancelButton = YES;
    searchBar.placeholder = @"Search SP Map";
    searchBar.delegate = self;
    [self.view addSubview:searchBar];
}

#pragma mark - Locations Services
- (void)setupLocationManager {
    locationManager =[[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.distanceFilter =  kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
}

- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation {
    // Getting the location coordinate
    lat = newLocation.coordinate.latitude;
    lon = newLocation.coordinate.longitude;
    
    //When mapVC is not visible or when invalid user location coordinates do not reload distance in ListVC
    if ((visible == NO) && (lat != 0 || lon != 0)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadDistance" object:nil];
    }
}

- (void)locationManager:(CLLocationManager*)manager didUpdateHeading:(CLHeading*)newHeading { 
    //If heading is available and selected by user, start rotating map according to the heading
    if (newHeading.headingAccuracy > 0 && rotateMap == YES) {
        CLLocationDirection trueHeading = newHeading.trueHeading;        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1.0];
        //Formula used to calculate the degree for rotating
        CGAffineTransform transform = CGAffineTransformMakeRotation(trueHeading * M_PI / -180.0);
        _mapView.transform = transform;
        [UIView commitAnimations];	
    }
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
    if (rotateMap)
        return YES;
    else
        return NO;
}

- (void)mapViewDidLoad:(AGSMapView *)mapView {
    //Default extent when the map first load point to MRT area
    AGSEnvelope *defaultextent = [AGSEnvelope envelopeWithXmin:103.773815
                                                          ymin:1.304122
                                                          xmax:103.782655
                                                          ymax:1.316343
                                              spatialReference:self.mapView.spatialReference];
    [self.mapView zoomToEnvelope:defaultextent animated:NO];
    mapLoaded = YES;
    [self.mapView.gps start];
    // Notification to alert map is ready
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mapLoaded" object:nil]; 
}

- (void) centerUserLocation:(id)sender {
    //If map is not loaded due to Internet connectivity return and do not do anything.
    if (mapLoaded == NO)
        return;
    //If location is unavailable
    if (lat == 0 || lon == 0) {
        MBProgressHUD *error = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.85, 115)];
        error.center = self.view.center;
        [self.view addSubview:error];
        error.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Error.png"]]autorelease];
        error.mode = MBProgressHUDModeCustomView;
        error.opacity = 0.5;
        error.labelText = @"Location Unavailable";
        error.detailsLabelText = @"Please ensure your location services is enabled.";
        [error show:YES];
        [error hide:YES afterDelay:1.5];
        [error release];
    }
    else {
        //Center at user point
        AGSPoint *pt = [AGSPoint pointWithX:lon y:lat spatialReference:self.mapView.spatialReference];
        [self.mapView centerAtPoint:pt animated:YES];
    }
}

- (void) rotateMap:(id)sender {  
    //If map is not loaded due to Internet connectivity return and do not do anything.
    if (!mapLoaded)
        return;
    
    //if map is rotating, stop rotating
    if (rotateMap == YES) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1.0];
        CGAffineTransform transform = CGAffineTransformMakeRotation(0);
        _mapView.transform = transform;
        [UIView commitAnimations];	
        rotateMap = NO;
        rotateMapButtonItem.selected = NO;
    }
    else {
        [self centerUserLocation:(id)sender];
        rotateMap = YES;
        rotateMapButtonItem.selected = YES;
    }
}

- (void)mapView:(AGSMapView *) mapView didClickCalloutAccessoryButtonForGraphic:(AGSGraphic *) graphic {
    //Getting the attributes from NSMutableDictionary *attribs in loadCallout
    NSDictionary *graphicAttributes =[NSDictionary dictionaryWithDictionary:graphic.attributes];
    
    //Extracting the key panorama from dictionary
    NSString *panorama = [graphicAttributes valueForKey:@"panorama"];
    NSString *livecam = [graphicAttributes valueForKey:@"livecam"];
    NSString *video = [graphicAttributes valueForKey:@"video"];
    
    DetailViewController *detailViewController;
    
    // Check if panorama or livecam is available or not
    if (panorama == nil && livecam == nil && video == nil) {
        detailViewController = [[DetailViewController alloc]
                                initWithNibName:@"DetailViewController" bundle:nil];
    }
    else {
        detailViewController = [[DetailViewController alloc]
                                initWithNibName:@"TBDetailViewController" bundle:nil];
    }
    
    UIBarButtonItem *backbutton = [[UIBarButtonItem alloc] init];
    backbutton.title = @"Back";
    self.navigationItem.backBarButtonItem = backbutton;
    [backbutton release];
    
    //Transferring graphic.attributes to detailViewController
    detailViewController.details = [NSDictionary dictionaryWithDictionary:graphic.attributes];
    
    // Push the next view
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    
    //Stop location services
    [locationManager stopUpdatingLocation];
    [locationManager stopUpdatingHeading];
}

#pragma mark - Navigating to other views
- (void) showCategories:(id)sender {
    
    CategoriesViewController *categoriesViewController = [[CategoriesViewController alloc]
                                                          initWithNibName:@"CategoriesViewController" 
                                                          bundle:nil];
    categoriesViewController.title = @"Categories";
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {//if user device is an iPad, display a pop over instead of moving to a new view
        if (popOver == nil) {
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:categoriesViewController];
            //Creating a popover with categoriesVC as RootVC
            popOver = [[UIPopoverController alloc] initWithContentViewController:navController];
            [navController release];
        }
        [popOver presentPopoverFromBarButtonItem:sender 
                        permittedArrowDirections:UIPopoverArrowDirectionAny 
                                        animated:YES];
    }
    else {
        UIBarButtonItem *backbutton = [[UIBarButtonItem alloc] init];
        backbutton.title = @"Back";
        self.navigationItem.backBarButtonItem = backbutton;
        [backbutton release];
        [self.navigationController pushViewController:categoriesViewController animated:YES];
    }
    [categoriesViewController release];
}

- (void) showAbout:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { 
        //If the category popover is presented dismiss it first before moving to the about page
        if (popOver != nil)
            [popOver dismissPopoverAnimated:NO];
    }
    
    AboutViewController *aboutViewController = [[AboutViewController alloc]initWithNibName:@"AboutViewController"
                                                                                    bundle:nil];
    aboutViewController.title = @"About";
    
    UIBarButtonItem *backbutton = [[UIBarButtonItem alloc] init];
    backbutton.title = @"Back";
    self.navigationItem.backBarButtonItem = backbutton;
    [backbutton release];
    
    [self.navigationController pushViewController:aboutViewController animated:YES];
    [aboutViewController release];
    
    //Stop location services
    [locationManager stopUpdatingLocation];
    [locationManager stopUpdatingHeading];
}

#pragma mark - Search
- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    if (!overlayViewController)
        overlayViewController = [[OverlayViewController alloc] initWithNibName:@"OverlayViewController"
                                                                        bundle:nil];
	
	CGFloat yaxis = self.navigationController.navigationBar.frame.size.height;
	CGFloat width = self.view.frame.size.width;
    CGFloat height;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        height = (self.view.frame.size.height) - 260;
    else
        height = (self.view.frame.size.height) - 308;
    
    CGRect frame = CGRectMake(0, yaxis, width, height);
    
	overlayViewController.view.frame = frame;	
    
	overlayViewController.mapViewController = self;
	
	[self.view insertSubview:overlayViewController.view aboveSubview:self.mapView];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)theSearchBar {
    [searchBar resignFirstResponder];
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //Search only when there is text
	if([searchText length] > 0) {
        //Remove all objects first.
        [searchResults removeAllObjects];
		[self searchLocations];
    }
}

- (void) searchBarTextDidEndEditing:(UISearchBar *)theSearchBar {
    //Clear searchBar text
    searchBar.text = @"";
    //Remove overlay
	[overlayViewController.view removeFromSuperview];
}

- (void) searchLocations {
    
    SPMapAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSArray *locations = appDelegate.locations;
    
    if (searchResults == nil)
        searchResults = [[NSMutableArray alloc] init];
    
    //Get text from searchBar
    NSString *searchText = searchBar.text;
    
    //Searching
    for (Location *aLocations in locations)
    {    
        //Search condition base on location category and title
        NSRange categoryResultsRange = [aLocations.category rangeOfString:searchText options:NSCaseInsensitiveSearch];
        NSRange titleResultsRange = [aLocations.title rangeOfString:searchText options:NSCaseInsensitiveSearch];
        
        if (categoryResultsRange.length > 0 || titleResultsRange.length > 0)
            [searchResults addObject:aLocations];
    }
    //Inform overlay that results is updated.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadsearchResults" object:nil];
}

#pragma mark - Memory and Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    self.mapView = nil;
    self.graphicsLayer = nil;
    self.CalloutTemplate = nil;
    [overlayViewController release];
    [toolBar release];
    [searchBar release];
    [selectedPoint release];
    selectedPoint = nil;
    [locationManager release];
    [searchResults release];
    [popOver release];
    [rotateMapButtonItem release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
