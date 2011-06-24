//
//  SPMapAppDelegate.h
//  SPMap
//
//  Created by Wei Guang on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"

@class ASIHTTPRequest;
@class TBXML;

@interface SPMapAppDelegate : NSObject <UIApplicationDelegate> {
    ASIHTTPRequest *request;
    TBXML *tbxml;
    NSMutableArray *locations; //Array for storing all locations from XML
    NSMutableSet *categories; //Set for storing all categories from XML
    NSMutableArray *identity; //Array for storing all the identity
    BOOL XMLLoaded; //XML status. YES for loaded, NO when not loaded
    NSString *apassedLocation;//String that is passed in from URL
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) NSMutableArray *locations;
@property (nonatomic, retain) NSMutableSet *categories;

- (void)checkNetwork;
- (void)downloadXML;
- (void)parseXML;
- (void)processURL:(NSString*)passedLocation;
- (void)passedLocation;

@end
