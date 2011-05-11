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

@implementation MapViewController

@synthesize mapView = _mapView;
@synthesize graphicsLayer = _graphicsLayer;
@synthesize CalloutTemplate = _CalloutTemplate;
@synthesize selectedLocations;
@synthesize toolBar;
@synthesize searchResults;
@synthesize searchBar;

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //If user makes a selection in the listView reload the Callouts and reset the mapExtent
    if (selectedLocations != nil) {
        [self loadCallout];
    }
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    //Start checking the accuracy of GPS
    locationManager =[[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.distanceFilter =  kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [locationManager startUpdatingLocation];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    
    //Stop location services
    [locationManager stopUpdatingLocation];
    [self.mapView.gps stop];
    
    //Set selectedLocations to nil, if user makes a selection in the listView selectedLocations will be reassigned
    selectedLocations = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = [UIApplication sharedApplication].delegate;
    
	searchResults = [[NSMutableArray alloc] init];
    
    [self addtoolBar];
    [self addsearchBar];
    
    // Getting locations array from appDelegate
    locations = appDelegate.locations;
    
    //set map view delegate
	self.mapView.mapViewDelegate = self;
    
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
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        watermarkIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 935, 43, 25)];
    }
    else {
        watermarkIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 391, 43, 25)];
    }
    watermarkIV.image = [UIImage imageNamed:@"esriLogo.png"];
    [self.view addSubview:watermarkIV];
    [watermarkIV release];
}

- (void) addtoolBar {
    
    toolBar = [UIToolbar new];
    toolBar.barStyle = UIBarStyleBlack;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        toolBar.frame = CGRectMake(0, 416, 320, 44);
    }
    else
        toolBar.frame = CGRectMake(0, 960, 768, 44);
    
    [self.view addSubview:toolBar];
    
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil action:nil];
    
    UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                               target:nil action:nil];
    fixedItem.width = 35; //Setting the width of the spacer
    
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
    
    NSArray *items = [NSArray arrayWithObjects:
                      centerUserLocationButtonItem,
                      fixedItem,
                      showCategoriesButtonItem,
                      flexItem,
                      showAboutButtonItem,
                      nil];
    
    [self.toolBar setItems:items animated:NO];
    [centerUserLocationButtonItem release];
    [fixedItem release];
    [showCategoriesButtonItem release];
    [flexItem release];
    [showAboutButtonItem release];
}

- (void) addsearchBar {
    
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0,0,320,44)];
    searchBar.barStyle = UIBarStyleBlack;
    searchBar.showsCancelButton = YES;
    searchBar.placeholder = @"Search SP Map";
    searchBar.delegate = self;
    [searchBar sizeToFit];
    [self.view addSubview:searchBar];
}

#pragma mark - Locations Services

- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation
{
    //Checking the accuracy of GPS. display location if accuracy is less then 100 metres
    accuracy = newLocation.horizontalAccuracy;
    
    if (accuracy <= 100) {
        //Start locating
        [self.mapView.gps start];
    } else {
        //Stop locating
        [self.mapView.gps stop];
    }
    
    // Getting the location coordinate
    lat = newLocation.coordinate.latitude;
    lon = newLocation.coordinate.longitude;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    //User denied location service
    if (status == kCLAuthorizationStatusDenied) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Unavailable" 
                                                        message:@"Please ensure your location service is turned ON in settings." 
                                                       delegate:self 
                                              cancelButtonTitle:nil 
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
        
        return;
    }
}

- (void)mapViewDidLoad:(AGSMapView *)mapView {
    
    //Default extent when the map first load
    AGSEnvelope *defaultextent = [AGSEnvelope envelopeWithXmin:103.777302
                                                          ymin:1.308708
                                                          xmax:103.780270
                                                          ymax:1.312159
                                              spatialReference:self.mapView.spatialReference];
    
    [self.mapView zoomToEnvelope:defaultextent animated:NO];
}

- (void) centerUserLocation:(id)sender {
    //Accuracy is more then 100m or no location available
    if (accuracy > 100 || lat == 0 || lon == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Unavailable" 
                                                        message:@"Your location cannot be determined at this moment. Please try again later." 
                                                       delegate:self 
                                              cancelButtonTitle:nil 
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
    }
    else
    {
        //Center at user point
        AGSPoint *pt = [AGSPoint pointWithX:lon y:lat spatialReference:self.mapView.spatialReference];
        [self.mapView centerAtPoint:pt animated:YES];
    }
}

- (void)mapView:(AGSMapView *) mapView didClickCalloutAccessoryButtonForGraphic:(AGSGraphic *) graphic
{
    //Getting the attributes from NSMutableDictionary *attribs in loadCallout
    NSDictionary *graphicAttributes =[NSDictionary dictionaryWithDictionary:graphic.attributes];
    
    //Extracting the key panorama from dictionary
    NSString *panorama = [graphicAttributes valueForKey:@"panorama"];
    
    DetailViewController *detailViewController;
    
    // Check if panorama is available or not
    if (panorama == nil) {
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
}

#pragma mark - Navigating to other views

- (void) showCategories:(id)sender {
    
    CategoriesViewController *categoriesViewController = [[CategoriesViewController alloc]initWithNibName:@"CategoriesViewController" 
                                                                                                   bundle:nil];
    categoriesViewController.title = @"Categories";
    
    UIBarButtonItem *backbutton = [[UIBarButtonItem alloc] init];
    backbutton.title = @"Back";
    self.navigationItem.backBarButtonItem = backbutton;
    [backbutton release];
    
    [self.navigationController pushViewController:categoriesViewController animated:YES];
    [categoriesViewController release];
}

- (void) showAbout:(id)sender {
    
    AboutViewController *aboutViewController = [[AboutViewController alloc]initWithNibName:@"AboutViewController"
                                                                                    bundle:nil];
    aboutViewController.title = @"About";
    
    UIBarButtonItem *backbutton = [[UIBarButtonItem alloc] init];
    backbutton.title = @"Back";
    self.navigationItem.backBarButtonItem = backbutton;
    [backbutton release];
    
    [self.navigationController pushViewController:aboutViewController animated:YES];
    [aboutViewController release];
}

#pragma mark - Setting MapView and CallOuts

- (void) setMapExtent {
    
    // Setting the extend to be used depending on the number of pins to be displayed
    if (ptcount == 0) {
        xmin = 103.777302;
        ymin = 1.308708;
        xmax = 103.780270;
        ymax = 1.312159;
    }
    if (ptcount == 1) {
        xmin = 103.774022;
        ymin = 1.305069;
        xmax = 103.782409;
        ymax = 1.314819;
    }
    //If ptcount is more then 1 the values will be taken from loadCallout
    AGSMutableEnvelope *extent = [AGSMutableEnvelope envelopeWithXmin:xmin
                                                                 ymin:ymin
                                                                 xmax:xmax
                                                                 ymax:ymax
                                                     spatialReference:self.mapView.spatialReference];
    if (ptcount > 1) {
        [extent expandByFactor:1.5];
    }
    
    [self.mapView zoomToEnvelope:extent animated:YES];
}

- (void) loadCallout
{
    DebugLog(@"I'm Called");
    // Remove all graphics if some are created earlier
    [self.graphicsLayer removeAllGraphics];
    // Hide callout
    self.mapView.callout.hidden = YES;
    
    //use these to calculate extent of results
    xmin = DBL_MAX;
    ymin = DBL_MAX;
    xmax = -DBL_MAX;
    ymax = -DBL_MAX;
    
    //create the callout template, used when the user displays the callout
    self.CalloutTemplate = [[[AGSCalloutTemplate alloc]init] autorelease];
    
    // variable used to count the number of pins to be display
    ptcount = 0;
    
    //loop through all locations and add to graphics layer
    for (int i=0; i<[locations count]; i++)
    {
        Location *location = [locations objectAtIndex:i];
        if ([selectedLocations isEqualToString:location.category] || 
            [selectedLocations isEqualToString:location.title])
        {
            //Setting the lat and lon from Location class
            double latitude = [[location lat] doubleValue];
            double longitude = [[location lon] doubleValue];
            
            //Adding coordinates to the point
            AGSPoint *pt = [AGSPoint pointWithX:longitude y:latitude spatialReference:self.mapView.spatialReference];
            
            ptcount++;
            
            //accumulate the min/max
            if (pt.x  < xmin)
                xmin = pt.x;
            
            if (pt.x > xmax)
                xmax = pt.x;
            
            if (pt.y < ymin)
                ymin = pt.y;
            
            if (pt.y > ymax)
                ymax = pt.y;
            
            //create a marker symbol to use in our graphic
            AGSPictureMarkerSymbol *marker = [AGSPictureMarkerSymbol 
                                              pictureMarkerSymbolWithImageNamed:@"BluePushpin.png"];
            marker.xoffset = 9;
            marker.yoffset = -16;
            marker.hotspot = CGPointMake(-9, -11);
            
            //creating an attribute for the callOuts
            NSMutableDictionary *attribs = [NSMutableDictionary dictionaryWithObject:location.title forKey:@"title"];
            [attribs setValue:location.subtitle forKey:@"subtitle"];
            [attribs setValue:location.description forKey:@"description"];
            [attribs setValue:location.photos forKey:@"photos"];
            [attribs setValue:location.panorama forKey:@"panorama"];
            
            //set the title and subtitle of the callout
            self.CalloutTemplate.titleTemplate = @"${title}";
            self.CalloutTemplate.detailTemplate = @"${subtitle}";
            
            //create the graphic
            AGSGraphic *graphic = [[AGSGraphic alloc] initWithGeometry:pt
                                                                symbol:marker
                                                            attributes:attribs
                                                  infoTemplateDelegate:self.CalloutTemplate];
            
            //add the graphic to the graphics layer
            [self.graphicsLayer addGraphic:graphic];
            
            //release the graphic
            [graphic release];            
        }
    }
    //since we've added graphics, make sure to redraw
    [self.graphicsLayer dataChanged];
    //Reload the MapExtent
    [self setMapExtent];
}

#pragma mark - Search

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    
    overlayViewController = [[OverlayViewController alloc] initWithNibName:@"OverlayViewController"
                                                                    bundle:nil];
	
	CGFloat yaxis = self.navigationController.navigationBar.frame.size.height;
	CGFloat width = self.view.frame.size.width;
    CGFloat height;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        height = (self.view.frame.size.height) - 260;
    }
    else {
        height = (self.view.frame.size.height) - 308;
    }
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
	[overlayViewController release];
	overlayViewController = nil;
}

- (void) searchLocations {
    
    appDelegate = [UIApplication sharedApplication].delegate;
    
    //Get text from searchBar
    NSString *searchText = searchBar.text;
    //Get array to be searched
    NSMutableArray *searchArray = [[NSMutableArray alloc] initWithArray:appDelegate.searchArray];
	
    //Search and add to searchResults array
	for (NSString *sTemp in searchArray)
	{
		NSRange titleResultsRange = [sTemp rangeOfString:searchText options:NSCaseInsensitiveSearch];
		
		if (titleResultsRange.length > 0)
			[searchResults addObject:sTemp];
	}
	
	[searchArray release];
	searchArray = nil;
    
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
    [selectedLocations release];
    [locationManager release];
    [searchResults release];
    [super dealloc];
}

@end
