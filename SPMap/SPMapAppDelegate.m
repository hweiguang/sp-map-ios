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
#import "TBXML.h"
#import "Location.h"
#import "Constants.h"
#import "Reachability.h"

@implementation SPMapAppDelegate
@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize locations;
@synthesize categories;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    XMLLoaded = NO;
    
	locations = [[NSMutableArray alloc] init];//Array for storing all locations from XML
    categories = [[NSMutableSet alloc] init];//Set for storing all categories from XML used in CategoriesVC
    identities = [[NSMutableArray alloc] init];//Array for storing all the identity used in ListVC and URL Scheme
    
    //Reachability
    [self checkNetwork];
    
    //Download XML file from server and save it to document directory
    [NSThread detachNewThreadSelector:@selector(downloadXML) toTarget:self withObject:nil];
    
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
    
    //Makes sure it is lower case
    passedLocation = [passedLocation lowercaseString];
    //Retain the string
    apassedLocation = [passedLocation copy];
    
    //If XML is loaded proceed to process URL, else wait till XML is loaded
    if (XMLLoaded == YES)
        [self processURL:passedLocation];
    else {
        //Listen for notification from parseXML method
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
    
    // Search the identity array for passLocation
    for(NSString *myStr in identities) {
        NSRange range = [passedLocation rangeOfString : myStr];        
        if (range.location != NSNotFound && [passedLocation isEqualToString:myStr]) {
            [array addObject:myStr];
            mapViewController.selectedLocations = myStr;
        }
        
    }
    // If there is only one result. Successful!
    if ([array count] == 1) {
        [mapViewController checkMapStatus];
        [array release];
        return;
    }
    // If there is no result. More checking required
    if ([array count] == 0) {
        mapViewController.selectedLocations = nil;
        
        // Grab the last two char of the string that is passed in
        NSString *lasttwochar = [passedLocation substringFromIndex:[passedLocation length] -2];
        // Check if it contains any punctuation, example T1845/6
        NSRange range = [lasttwochar rangeOfCharacterFromSet:[NSCharacterSet punctuationCharacterSet] 
                                                     options:NSCaseInsensitiveSearch];
        if(range.location != NSNotFound ) { //if any punctuation is found remove it, example T1845/6 -> T1845
            passedLocation = [passedLocation substringToIndex:[passedLocation length] -2];
        }
        
        //If string length is 4, example T1845 remove last 2 digits and we get T18
        if ([passedLocation length] == 4) {
            mapViewController.selectedLocations = [passedLocation substringToIndex:[passedLocation length] -2];
        }
        //If string length is more then 4,check the last char.
        if ([passedLocation length] > 4) {
            NSString *lastChar = [passedLocation substringFromIndex:[passedLocation length] -1];
            
            NSRange range = [lastChar rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet] 
                                                      options:NSCaseInsensitiveSearch];
            //If a letter is found remove it, and remove 2 more digits example T1A23A -> T1A
            //Another example T12A401, in this case it remains the same
            if(range.location != NSNotFound ) {
                passedLocation = [passedLocation substringToIndex:[passedLocation length] -3];
            }
            //If letter not found just remove 2,example T1A23 -> T1A
            //T12A401 is now T12A4
            if (range.location == NSNotFound) {
                passedLocation = [passedLocation substringToIndex:[passedLocation length] -2];
            }
            //T12A4 length is still more then 4 remove the last char and we get T12A
            if ([passedLocation length] > 4) {
                passedLocation = [passedLocation substringToIndex:[passedLocation length] -1];
            }
            
            mapViewController.selectedLocations = passedLocation;
        }
        //If the string is less than 4, no problem
        if ([passedLocation length] < 4) {
            mapViewController.selectedLocations = passedLocation;
        }
        //If string length is 4 check the last char first.
        if ([mapViewController.selectedLocations length] == 4) {
            
            NSString *lastChar = [mapViewController.selectedLocations substringFromIndex:[mapViewController.selectedLocations length] -1];
            
            NSRange range = [lastChar rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet] 
                                                      options:NSCaseInsensitiveSearch];
            //If the last char is not a letter remove the last char example T223 -> T22
            if(range.location == NSNotFound ) {
                passedLocation = [passedLocation substringToIndex:[passedLocation length] -1];
            }
            mapViewController.selectedLocations = passedLocation;
        }
        //Now we have gone through all the checking check the map status,when ready we will load the callouts
        [mapViewController checkMapStatus];
    }
    [array release];
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

- (void)downloadXML {  
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSURL *url = [NSURL URLWithString:kLocationsDatabaseURL];
    
    //Create a request to download XML file from kLocationsDatabaseURL
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    //Getting the documentdirectory string
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString *XMLPath = [cachesDirectory stringByAppendingPathComponent:@"Location.xml"];
    
    [request setDownloadDestinationPath:XMLPath]; //Set to save the file to documents directory
    [request startSynchronous]; //Start request
    
    [self parseXML]; //Parse XML when done
    
    [pool release];
}

- (void)parseXML {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString *XMLPath = [cachesDirectory stringByAppendingPathComponent:@"Location.xml"];
    
    // Load and parse the Locations.xml file in document directory
    tbxml = [[TBXML tbxmlWithXMLData:[NSData dataWithContentsOfFile:XMLPath]] retain];
    
	// Obtain root element
	TBXMLElement * root = tbxml.rootXMLElement;
    
	// if root element is valid
	if (root) {
		// search for the first category element within the root element's children
		TBXMLElement * location = [TBXML childElementNamed:@"location" parentElement:root];
		// if an location element was found
		while (location) {
            // instantiate an location object
            Location * aLocation = [[Location alloc] init];
            
            //Extracting all the attribute in element location
            TBXMLElement *title = [TBXML childElementNamed:@"title" parentElement:location];
            if (title)
                aLocation.title = [TBXML textForElement:title];
            else
                aLocation.title = nil;
            
            TBXMLElement *subtitle = [TBXML childElementNamed:@"subtitle" parentElement:location];
            if (subtitle)
                aLocation.subtitle = [TBXML textForElement:subtitle];
            else
                aLocation.subtitle = nil;
            
            TBXMLElement *photos = [TBXML childElementNamed:@"photos" parentElement:location];
            if (photos)
                aLocation.photos = [TBXML textForElement:photos];
            else
                aLocation.photos = nil;
            
            TBXMLElement *identity = [TBXML childElementNamed:@"identity" parentElement:location];
            if (identity)
                aLocation.identity = [TBXML textForElement:identity];
            else
                aLocation.identity = nil;
            
            TBXMLElement * category = [TBXML childElementNamed:@"category" parentElement:location];
            if (category)
                aLocation.category = [TBXML textForElement:category];
            else
                aLocation.category = nil;
            
            TBXMLElement *livecam = [TBXML childElementNamed:@"livecam" parentElement:location];
            if (livecam)
                aLocation.livecam = [TBXML textForElement:livecam];
            else
                aLocation.livecam = nil;
            
            TBXMLElement *video = [TBXML childElementNamed:@"video" parentElement:location];
            if (video)
                aLocation.video = [TBXML textForElement:video];
            else
                aLocation.video = nil;
            
            TBXMLElement *panorama = [TBXML childElementNamed:@"panorama" parentElement:location];
            if (panorama)
                aLocation.panorama = [TBXML textForElement:panorama];
            else
                aLocation.panorama = nil;
            
            TBXMLElement *description = [TBXML childElementNamed:@"description" parentElement:location];
            if (description)
                aLocation.description = [TBXML textForElement:description];
            else
                aLocation.description = nil;
            
            TBXMLElement *lat = [TBXML childElementNamed:@"lat" parentElement:location];
            NSString * latstring = [TBXML textForElement:lat];
            aLocation.lat = [NSNumber numberWithFloat:[latstring floatValue]];
            
            TBXMLElement *lon = [TBXML childElementNamed:@"lon" parentElement:location];
            NSString * lonstring = [TBXML textForElement:lon];
            aLocation.lon = [NSNumber numberWithFloat:[lonstring floatValue]];
            
            // add our location object to the locations array and release the resource
			[locations addObject:aLocation];
            [identities addObject:aLocation.identity];
            [categories addObject:aLocation.category];
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
    [locations release];
    [categories release];
    [identities release];
    [super dealloc];
}

@end
