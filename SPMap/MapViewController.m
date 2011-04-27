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
#import "SPMapAppDelegate.h"
#import "Constants.h"

@implementation MapViewController

@synthesize mapView = _mapView;
@synthesize graphicsLayer = _graphicsLayer;
@synthesize CalloutTemplate = _CalloutTemplate;
@synthesize selectedLocations;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showCallout];
    
    self.navigationItem.title = @"SP Map";
    self.navigationItem.hidesBackButton = YES;
    DebugLog(@"Title %@",self.navigationItem.title);
    
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
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SPMapAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    
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
    UIImageView *watermarkIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 345, 43, 25)];
	watermarkIV.image = [UIImage imageNamed:@"esriLogo.png"];
	watermarkIV.userInteractionEnabled = NO;
	[self.view addSubview:watermarkIV];
    [watermarkIV release];
}

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
        [self.mapView.gps stop];
    }
}

- (void)mapViewDidLoad:(AGSMapView *)mapView {
    
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
    
    AGSMutableEnvelope *extent = [AGSMutableEnvelope envelopeWithXmin:xmin
                                                                 ymin:ymin
                                                                 xmax:xmax
                                                                 ymax:ymax
                                                     spatialReference:self.mapView.spatialReference];
    
    if (ptcount > 1) {
        [extent expandByFactor:1.5];
    }
    
    [self.mapView zoomToEnvelope:extent animated:NO];
    
    if (accuracy <= 100) {
        //display location if accuracy is less then 100 metres
        [self.mapView.gps start];
    }
}

- (IBAction) showCategories {
    
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

- (IBAction) showAbout {
    
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

- (void) showCallout
{
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
        Location *myLocation = [locations objectAtIndex:i];
        if ([selectedLocations isEqualToString:myLocation.category] ||
            [selectedLocations isEqualToString:myLocation.title])
        {
            //Setting the lat and lon from Location class
            double latitude = [[myLocation lat] doubleValue];
            double longitude = [[myLocation lon] doubleValue];
            
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
            NSMutableDictionary *attribs = [NSMutableDictionary dictionaryWithObject:myLocation.title forKey:@"title"];
            [attribs setValue:myLocation.subtitle forKey:@"subtitle"];
            [attribs setValue:myLocation.description forKey:@"description"];
            [attribs setValue:myLocation.photos forKey:@"photos"];
            [attribs setValue:myLocation.panorama forKey:@"panorama"];
            
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
}

- (void)mapView:(AGSMapView *) mapView didClickCalloutAccessoryButtonForGraphic:(AGSGraphic *) graphic
{
    NSDictionary *graphicAttributes =[NSDictionary dictionaryWithDictionary:graphic.attributes];
    
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    self.mapView = nil;
    self.graphicsLayer = nil;
	self.CalloutTemplate = nil;
    [locations release];
    [selectedLocations release];
    [locationManager release];
    [super dealloc];
}

@end
