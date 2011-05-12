//
//  SPMapAppDelegate.m
//  SPMap
//
//  Created by Wei Guang on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SPMapAppDelegate.h"
#import "MapViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "TBXML.h"
#import "Location.h"
#import "Constants.h"
#import "Reachability.h"

@implementation SPMapAppDelegate
@synthesize downloadCache;
@synthesize window=_window;
@synthesize navigationController=_navigationController;
@synthesize locations;
@synthesize categories;
@synthesize searchArray;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{        
    XMLLoaded = NO;
    
	locations = [[NSMutableArray alloc] init];
    categories = [[NSMutableSet alloc] init];
    searchArray = [[NSMutableArray alloc] init];
    
    //Reachability
    [self checkNetwork];
    
    //Download XML file from server and parse if unavailable parse local copy
    [NSThread detachNewThreadSelector:@selector(loadData) toTarget:self withObject:nil];
    
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url 
{    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    if (!url) {
        // The URL is nil. There's nothing more to do.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                        message:@"Invalid Location." 
                                                       delegate:self 
                                              cancelButtonTitle:nil 
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
        return NO;
    }
    
    NSString *URLString = [url absoluteString];
    
    if (!URLString) {
        // The URL's absoluteString is nil. There's nothing more to do.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                        message:@"Invalid Location." 
                                                       delegate:self 
                                              cancelButtonTitle:nil 
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
        return NO;
    }
    
    NSString *locationString = [URLString stringByReplacingOccurrencesOfString:@"spmap://" withString:@""];
    
    MapViewController *mapViewController = (MapViewController*)[self.navigationController.viewControllers objectAtIndex:0];
    
    mapViewController.selectedLocations = locationString;
    
    if (XMLLoaded == YES) {
        [mapViewController loadCallout];
    }
    else {
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(loadCallout) 
                                                     name:@"XMLLoaded" object:nil];  
    }
    return YES;
}

- (void) loadCallout {
    
    MapViewController *mapViewController = (MapViewController*)[self.navigationController.viewControllers objectAtIndex:0];
    
    [mapViewController loadCallout];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)checkNetwork {
    
    Reachability* wifiReach = [[Reachability reachabilityWithHostName:kReachabilityHostname] retain];
    NetworkStatus netStatus = [wifiReach currentReachabilityStatus];
    
    switch (netStatus)
    {
        case kNotReachable: 
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" 
                                                            message:@"Please ensure you are connected to the Internet." 
                                                           delegate:self 
                                                  cancelButtonTitle:nil 
                                                  otherButtonTitles:@"OK", nil];
            [alert show];
            [alert release];
        }
            break;
            
        case kReachableViaWWAN:
            break;
            
        case kReachableViaWiFi:
            break;
    }
    
    [wifiReach release];
}

-(void)loadData
{    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (!operationQueue) {
        operationQueue = [[NSOperationQueue alloc] init];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    ASIDownloadCache *cache = [[[ASIDownloadCache alloc] init] autorelease];
    [cache setStoragePath:documentsDirectory];
    
    // Don't forget - you are responsible for retaining your cache!
    [self setDownloadCache:cache];
    
    request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:kLocationsDatabaseURL]];
    [request setDelegate:self];
    [request setDownloadCache:[self downloadCache]];
    [request setCachePolicy:ASIAskServerIfModifiedCachePolicy|ASIFallbackToCacheIfLoadFailsCachePolicy];
    [request setDidFinishSelector:@selector(requestDone:)];
    [request setDidFailSelector:@selector(requestWentWrong:)];
    [operationQueue addOperation:request];  // request is an NSOperationQueue
    
    [pool release];
    
}

//  connected
- (void)requestDone:(ASIHTTPRequest *)theRequest
{
    NSData *responseData = [theRequest responseData];
    int statusCode = [theRequest responseStatusCode];
    
    //  file not found
    if (statusCode == 404)
    {
        BOOL hasServerCopy = NO;
        [self loadXML:hasServerCopy];
    }
    //  file is nil
    else if (responseData == nil)
    {
        BOOL hasServerCopy = NO;
        [self loadXML:hasServerCopy];
    }
    //  file is found
    else
    {
        BOOL hasServerCopy = YES;
        [self loadXML:hasServerCopy];
    }
}

//  unable to connect
- (void)requestWentWrong:(ASIHTTPRequest *)theRequest
{
    BOOL hasServerCopy = NO;
    [self loadXML:hasServerCopy];
}

- (void)loadXML:(BOOL)hasServerCopy {
    
    if (hasServerCopy == NO)
    {
        // Load and parse the Locations.xml file
        tbxml = [[TBXML tbxmlWithXMLFile:@"Locations.xml"] retain];
    }
    
    if (hasServerCopy == YES) 
    {
        NSString *filePath = [downloadCache pathToStoreCachedResponseDataForRequest:request];
        // Load and parse the Locations.xml file
        tbxml = [[TBXML tbxmlWithXMLData:[NSData dataWithContentsOfFile:filePath]] retain];
    } 
    
	// Obtain root element
	TBXMLElement * root = tbxml.rootXMLElement;
	
	// if root element is valid
	if (root) {
		// search for the first category element within the root element's children
		TBXMLElement * location = [TBXML childElementNamed:@"location" parentElement:root];
		
		// if an location element was found
		while (location != nil) 
        {
            // instantiate an location object
            Location * aLocation = [[Location alloc] init];
            
			//Extracting all the attribute in element location
			aLocation.title = [TBXML valueOfAttributeNamed:@"title" forElement:location];
			aLocation.subtitle = [TBXML valueOfAttributeNamed:@"subtitle" forElement:location];
            aLocation.description = [TBXML valueOfAttributeNamed:@"description" forElement:location];
            aLocation.photos = [TBXML valueOfAttributeNamed:@"photos" forElement:location];
            aLocation.panorama = [TBXML valueOfAttributeNamed:@"panorama" forElement:location];
            
            NSString * lat = [TBXML valueOfAttributeNamed:@"lat" forElement:location];
            aLocation.lat = [NSNumber numberWithFloat:[lat floatValue]];
            NSString * lon = [TBXML valueOfAttributeNamed:@"lon" forElement:location];
            aLocation.lon = [NSNumber numberWithFloat:[lon floatValue]];
            
            // search the location's child elements for a category element
			TBXMLElement * category = [TBXML childElementNamed:@"category" parentElement:location];
            
            // if we find a category
            while (category != nil) {
                
                // obtain the text from the category element
				NSString * aCategory = [TBXML textForElement:category];
                
                // add category object to categories set
                [categories addObject:aCategory];
                
                // find the next sibling element named "category"
                category = [TBXML nextSiblingNamed:@"category" searchFromElement:category];
                
                // Adding the text category to aLocation
                aLocation.category = aCategory;
            }
            
            // add our location object to the locations array and release the resource
			[locations addObject:aLocation];
            [searchArray addObject:aLocation.title];
            [aLocation release];
            
			// find the next sibling element named "location"
			location = [TBXML nextSiblingNamed:@"location" searchFromElement:location];
        }
        // release resources
        [tbxml release];
    }
    //Inform CategoriesVC categories array is ready
    [[NSNotificationCenter defaultCenter] postNotificationName:@"XMLLoaded" object:nil];
    XMLLoaded = YES;
}

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [request clearDelegatesAndCancel];
    [request release];
    [operationQueue cancelAllOperations];
    [operationQueue release];
    [downloadCache release];
    [locations release];
    [categories release];
    [searchArray release];
    [super dealloc];
}

@end
