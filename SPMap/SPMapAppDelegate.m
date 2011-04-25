//
//  SPMapAppDelegate.m
//  SPMap
//
//  Created by Wei Guang on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SPMapAppDelegate.h"
#import "MapViewController.h"
#import "CategoriesViewController.h"
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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    // instantiate an array to hold location objects
	locations = [[NSMutableArray alloc] init];
    // instantiate a set to hold category objects
    categories = [[NSMutableSet alloc] init];
    [self checkNetwork];
    [NSThread detachNewThreadSelector:@selector(loadData) toTarget:self withObject:nil];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)checkNetwork {
    
    Reachability* wifiReach = [[Reachability reachabilityWithHostName:kReachabilityHostname] retain];
    NetworkStatus netStatus = [wifiReach currentReachabilityStatus];
    
    UIAlertView *alert; 
    
    switch (netStatus)
    {
        case kNotReachable:
            alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" 
                                               message:@"Please make sure you are connected to the Internet before using SP Map." 
                                              delegate:self 
                                     cancelButtonTitle:nil 
                                     otherButtonTitles:@"OK", nil];
            [alert show];
            [alert release];
            break;
            
        case kReachableViaWWAN:
            alert = [[UIAlertView alloc] initWithTitle:@"Slow Network Detected" 
                                               message:@"You may experience slow loading time when using SP Map" 
                                              delegate:self 
                                     cancelButtonTitle:nil 
                                     otherButtonTitles:@"OK", nil];
            [alert show];
            [alert release];
            break;
            
        case kReachableViaWiFi:
            DebugLog(@"Reachable via WIFI");
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
        DebugLog(@"Local XML");
    }
    
    if (hasServerCopy == YES) 
    {
        NSString *filePath = [downloadCache pathToStoreCachedResponseDataForRequest:request];
        // Load and parse the Locations.xml file
        tbxml = [[TBXML tbxmlWithXMLData:[NSData dataWithContentsOfFile:filePath]] retain];
        DebugLog(@"Server XML");
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
            [aLocation release];
            
			// find the next sibling element named "location"
			location = [TBXML nextSiblingNamed:@"location" searchFromElement:location];
        }
        
        // release resources
        [tbxml release];
    }
    DebugLog(@"categories is %@", [categories description]);
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
    [super dealloc];
}

@end
