//
//  SPMapAppDelegate.h
//  SPMap
//
//  Created by Wei Guang on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASICacheDelegate.h"
#import "Location.h"

@class ASIHTTPRequest;
@class TBXML;
@class MapViewController;

@interface SPMapAppDelegate : NSObject <UIApplicationDelegate> {

    MapViewController *mapViewController;
    
    NSOperationQueue *operationQueue;
    ASIHTTPRequest *request;
    id <ASICacheDelegate> downloadCache;
    TBXML *tbxml;
    NSMutableArray *locations; //Array for storing all locations from XML
    NSMutableSet *categories; //Set for storing all categories from XML
}

@property (nonatomic, retain) MapViewController *mapViewController;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) NSMutableArray *locations;
@property (nonatomic, retain) NSMutableSet *categories;
@property (nonatomic, retain) id <ASICacheDelegate> downloadCache;

- (void)checkNetwork;
- (void)loadData;
- (void)loadXML:(BOOL)hasServerCopy;

@end
