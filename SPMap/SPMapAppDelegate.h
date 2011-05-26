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

@interface SPMapAppDelegate : NSObject <UIApplicationDelegate> {
    NSOperationQueue *operationQueue;
    ASIHTTPRequest *request;
    id <ASICacheDelegate> downloadCache;
    TBXML *tbxml;
    NSMutableArray *locations; //Array for storing all locations from XML
    NSMutableSet *categories; //Set for storing all categories from XML
    NSMutableArray *identity;
    BOOL XMLLoaded; //XML status. YES for loaded, NO when not loaded
    NSString *aPassedLocation;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) NSMutableArray *locations;
@property (nonatomic, retain) NSMutableSet *categories;
@property (nonatomic, retain) id <ASICacheDelegate> downloadCache;

- (void)checkNetwork;
- (void)loadData;
- (void)loadXML:(BOOL)hasServerCopy;
- (void)processURL:(NSString*)passedLocation;
- (void)passedLocation;

@end
