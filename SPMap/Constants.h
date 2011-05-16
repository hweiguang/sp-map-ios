//
//  Constants.h
//  SPMap
//
//  Created by Richard Yip on 4/10/11.
//  Copyright 2011 Singapore Polytechnic. All rights reserved.
//
/*
 Development Server URLs
 #define kLocationsDatabaseURL   @"http://164.78.205.62/spmap/database/Locations.xml"
 #define imageHostname           @"http://164.78.205.62/spmap/photos/"
 #define panoramaHostname        @"http://164.78.205.62/spmap/panoramas/"
 */
#define kLocationsDatabaseURL   @"http://mobileapp.sp.edu.sg/spmap/database/Locations.xml"
#define kMapServiceURL          @"http://www.whereto.sg/WMGIS01/rest/services/WhereTo/Island_Base/MapServer"
#define imageHostname           @"http://mobileapp.sp.edu.sg/spmap/photos/"
#define panoramaHostname        @"http://mobileapp.sp.edu.sg/spmap/panoramas/"
#define kReachabilityHostname   @"mobileapp.sp.edu.sg"

//Codes for implementing navigation controller in a pop over
/*
UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:categoriesViewController];


popOver = [[UIPopoverController alloc] initWithContentViewController:navController];

[popOver presentPopoverFromBarButtonItem:sender 
                permittedArrowDirections:UIPopoverArrowDirectionAny 
                                animated:YES];
*/
