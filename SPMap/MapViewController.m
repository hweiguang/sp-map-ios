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

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    self.title = @"SP Map";
    self.navigationItem.hidesBackButton = YES;
    self.mapView.callout.hidden = YES;
    [self showCallout];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SPMapAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    
    DebugLog(@"selectedLocations%@",selectedLocations);
    
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
    UIImageView *watermarkIV = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 345, 43, 25)] autorelease];
	watermarkIV.image = [UIImage imageNamed:@"esriLogo.png"];
	watermarkIV.userInteractionEnabled = NO;
	[self.view addSubview:watermarkIV];
}

- (void)mapViewDidLoad:(AGSMapView *)mapView {
    
	//create extent to be used as default
	AGSEnvelope *envelope = [AGSEnvelope envelopeWithXmin:103.777302
													 ymin:1.308708 
													 xmax:103.780270 
													 ymax:1.312159 
										 spatialReference:self.mapView.spatialReference];
    
	[self.mapView zoomToEnvelope:envelope animated:NO];
	//Start locating
	[self.mapView.gps start];
}

- (IBAction) showCategories {
    
    CategoriesViewController *categoriesViewController = [[CategoriesViewController alloc]initWithNibName:@"CategoriesViewController" bundle:nil];
	categoriesViewController.title = @"Categories";
	[self.navigationController pushViewController:categoriesViewController animated:YES];
	[categoriesViewController release];
}

- (IBAction) showAbout {
    
    AboutViewController *aboutViewController = [[AboutViewController alloc]init];
    aboutViewController.title = @"About";
    [self.navigationController pushViewController:aboutViewController animated:YES];
	[aboutViewController release];    
}

- (void) showCallout
{
    // Remove all graphics if some are created earlier
    [self.graphicsLayer removeAllGraphics];
    self.mapView.callout.hidden = YES;
    
    //use these to calculate extent of results
    double xmin = DBL_MAX;
    double ymin = DBL_MAX;
    double xmax = -DBL_MAX;
    double ymax = -DBL_MAX;
    
    //create the callout template, used when the user displays the callout
    self.CalloutTemplate = [[[AGSCalloutTemplate alloc]init] autorelease];
    
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
            AGSGraphic *graphic = [[AGSGraphic alloc] initWithGeometry: pt
                                                                symbol:marker
                                                            attributes:attribs
                                                  infoTemplateDelegate:self.CalloutTemplate];
            
            //add the graphic to the graphics layer
            [self.graphicsLayer addGraphic:graphic];
            /*
            if (numberofpins == 1)
            {
                //we have one result, center at that point
                [self.mapView centerAtPoint:pt animated:NO];
            }*/
            
            //release the graphic
            [graphic release];            
        }
        
    }/*
    //if we have more than one result, zoom to the extent of all callOuts
    if (numberofpins > 1)
    {         
        AGSMutableEnvelope *extent = [AGSMutableEnvelope envelopeWithXmin:xmin ymin:ymin xmax:xmax ymax:ymax spatialReference:self.mapView.spatialReference];
        [extent expandByFactor:1.5];
        [self.mapView zoomToEnvelope:extent animated:YES];
    }*/
    //since we've added graphics, make sure to redraw
    [self.graphicsLayer dataChanged];
}

- (void)mapView:(AGSMapView *) mapView didClickCalloutAccessoryButtonForGraphic:(AGSGraphic *) graphic
{
    NSDictionary *graphicAttributes =[NSDictionary dictionaryWithDictionary:graphic.attributes];
    
    NSString *panorama = [graphicAttributes valueForKey:@"panorama"];
    
    DetailViewController *detailViewController;
    
    if (panorama == nil) {
        detailViewController = [[DetailViewController alloc]
                                initWithNibName:@"DetailViewController" bundle:nil];
    }
    else {
        detailViewController = [[DetailViewController alloc]
                                initWithNibName:@"TBDetailViewController" bundle:nil];
    }
    
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
    [super dealloc];
}

@end
