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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    XMLLoaded = NO;
    
	locations = [[NSMutableArray alloc] init];
    categories = [[NSMutableSet alloc] init];
    identity = [[NSMutableArray alloc] init];
    
    //Reachability
    [self checkNetwork];
    
    //Download XML file from server and parse. if unavailable parse local copy
    [NSThread detachNewThreadSelector:@selector(loadData) toTarget:self withObject:nil];
    
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {    
    // Makes sure the user is presented with the MapView
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    //Getting the URL that is passed in from another application
    NSString *URLString = [url absoluteString];
    //Remove spmap:// from the string
    NSString *passedLocation = [URLString substringFromIndex:8];
    if (passedLocation == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                        message:@"Location not found." 
                                                       delegate:self 
                                              cancelButtonTitle:nil 
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
        return NO;
    }
    
    //Makes sure it is lower case
    passedLocation = [passedLocation lowercaseString];
    
    apassedLocation = [passedLocation copy];
    
    //If XMLLoaded process URL else wait till XML is loaded
    if (XMLLoaded == YES)
        [self processURL:passedLocation];
    else {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(passedLocation) 
                                                     name:@"XMLLoaded" object:nil];
    }
    return YES;
}

- (void)passedLocation {
    NSString *passedLocation = apassedLocation;
    [self processURL:passedLocation];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)processURL:(NSString*)passedLocation {
    MapViewController *mapViewController = (MapViewController*)[self.navigationController.viewControllers objectAtIndex:0];
    
    if (mapViewController.selectedLocations != nil)
        mapViewController.selectedLocations = nil; //Making sure selectedLocations in MapVC is nil
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    // Grab the last two char of the string that is passed in
    NSString *lasttwochar = [passedLocation substringFromIndex:[passedLocation length] -2];
    // Check if it contains any punctuation, example T1845/6
    NSRange range = [lasttwochar rangeOfCharacterFromSet:[NSCharacterSet punctuationCharacterSet] 
                                                 options:NSCaseInsensitiveSearch];
    if(range.location != NSNotFound ) { //if any punctuation is found remove it, example /6
        passedLocation = [passedLocation substringToIndex:[passedLocation length] -2];
    }
    // Search the identity array for passLocation and store all possible results in array
    for(NSString *myStr in identity) {
        NSRange range = [passedLocation rangeOfString : myStr];
        if (range.location != NSNotFound) {
            [array addObject:myStr];
            mapViewController.selectedLocations = myStr;
        }
    }
    // If there is only one result. Sucessful!
    if ([array count] == 1) {
        [mapViewController checkMapStatus];
        return;
    }
    // If there is more then one result. More checking required
    if ([array count] > 1) {
        mapViewController.selectedLocations = nil;
        
        if ([passedLocation length] == 4) {
            mapViewController.selectedLocations = [passedLocation substringToIndex:[passedLocation length] -2];
        }
        
        if ([passedLocation length] > 4) {
            NSString *lastChar = [passedLocation substringFromIndex:[passedLocation length] -1];
            
            NSRange range = [lastChar rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet] 
                                                      options:NSCaseInsensitiveSearch];
            if(range.location != NSNotFound ) {
                passedLocation = [passedLocation substringToIndex:[passedLocation length] -3];
            }
            if (range.location == NSNotFound) {
                passedLocation = [passedLocation substringToIndex:[passedLocation length] -2];
            }
            
            if ([passedLocation length] > 4) {
                passedLocation = [passedLocation substringToIndex:[passedLocation length] -1];
            }
            
            mapViewController.selectedLocations = passedLocation;
        }
        if ([passedLocation length] < 4) {
            mapViewController.selectedLocations = passedLocation;
        }
        
        if ([mapViewController.selectedLocations length] == 4) {
            
            NSString *lastChar = [mapViewController.selectedLocations substringFromIndex:[mapViewController.selectedLocations length] -1];
            
            NSCharacterSet *alphaSet = [NSCharacterSet letterCharacterSet];
            
            NSRange range = [lastChar rangeOfCharacterFromSet:alphaSet options:NSCaseInsensitiveSearch];
            if(range.location == NSNotFound ) {
                passedLocation = [passedLocation substringToIndex:[passedLocation length] -1];
            }
            mapViewController.selectedLocations = passedLocation;
        }
        [mapViewController checkMapStatus];
        [array release];
    }
    // If no results at all, return error.
    else {
        [mapViewController.graphicsLayer removeAllGraphics];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                        message:@"Location not found." 
                                                       delegate:self 
                                              cancelButtonTitle:nil 
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
    }
}

- (void)checkNetwork {
    Reachability* wifiReach = [[Reachability reachabilityWithHostName:kReachabilityHostname] retain];
    NetworkStatus netStatus = [wifiReach currentReachabilityStatus];
    
    switch (netStatus) {
        case kNotReachable: {
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

- (void)loadData {    
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
- (void)requestDone:(ASIHTTPRequest *)theRequest {
    NSData *responseData = [theRequest responseData];
    int statusCode = [theRequest responseStatusCode];
    
    //  file not found
    if (statusCode == 404) {
        BOOL hasServerCopy = NO;
        [self loadXML:hasServerCopy];
    }
    //  file is nil
    else if (responseData == nil) {
        BOOL hasServerCopy = NO;
        [self loadXML:hasServerCopy];
    }
    //  file is found
    else {
        BOOL hasServerCopy = YES;
        //Set hasServerCopy to NO here to test Local XML file
        //BOOL hasServerCopy = NO;
        [self loadXML:hasServerCopy];
    }
}

//  unable to connect
- (void)requestWentWrong:(ASIHTTPRequest *)theRequest {
    BOOL hasServerCopy = NO;
    [self loadXML:hasServerCopy];
}

- (void)loadXML:(BOOL)hasServerCopy {
    if (hasServerCopy == NO) {
        // Load and parse the local Locations.xml file
        tbxml = [[TBXML tbxmlWithXMLFile:@"Locations.xml"] retain];
    }
    
    if (hasServerCopy == YES) {
        NSString *filePath = [downloadCache pathToStoreCachedResponseDataForRequest:request];
        // Load and parse the server Locations.xml file
        tbxml = [[TBXML tbxmlWithXMLData:[NSData dataWithContentsOfFile:filePath]] retain];
    } 
    
	// Obtain root element
	TBXMLElement * root = tbxml.rootXMLElement;
	
	// if root element is valid
	if (root) {
		// search for the first category element within the root element's children
		TBXMLElement * location = [TBXML childElementNamed:@"location" parentElement:root];
		
		// if an location element was found
		while (location != nil) {
            // instantiate an location object
            Location * aLocation = [[Location alloc] init];
            
			//Extracting all the attribute in element location
			aLocation.title = [TBXML valueOfAttributeNamed:@"title" forElement:location];
			aLocation.subtitle = [TBXML valueOfAttributeNamed:@"subtitle" forElement:location];
            aLocation.description = [TBXML valueOfAttributeNamed:@"description" forElement:location];
            aLocation.photos = [TBXML valueOfAttributeNamed:@"photos" forElement:location];
            aLocation.panorama = [TBXML valueOfAttributeNamed:@"panorama" forElement:location];
            aLocation.identity = [TBXML valueOfAttributeNamed:@"id" forElement:location];
            aLocation.livecam = [TBXML valueOfAttributeNamed:@"livecam" forElement:location];
            aLocation.video = [TBXML valueOfAttributeNamed:@"videos" forElement:location];
            
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
            [identity addObject:aLocation.identity];
            [aLocation release];
            
			// find the next sibling element named "location"
			location = [TBXML nextSiblingNamed:@"location" searchFromElement:location];
        }
        // release resources
        [tbxml release];
    }
    // Notification to alert Database is ready
    [[NSNotificationCenter defaultCenter] postNotificationName:@"XMLLoaded" object:nil]; 
    XMLLoaded = YES;
}

- (void)dealloc {
    [_window release];
    [_navigationController release];
    [request clearDelegatesAndCancel];
    [request release];
    [operationQueue cancelAllOperations];
    [operationQueue release];
    [downloadCache release];
    [locations release];
    [categories release];
    [identity release];
    [super dealloc];
}

@end
