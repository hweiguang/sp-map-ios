//
//  Constants.h
//  SPMap
//
//  Created by Richard Yip on 4/10/11.
//  Copyright 2011 Singapore Polytechnic. All rights reserved.
//
/*
#define kLocationsDatabaseURL   @"http://164.78.205.62/spmap/database/Locations.xml"
#define kMapServiceURL          @"http://www.whereto.sg/WMGIS01/rest/services/WhereTo/Island_Base/MapServer"
#define imageHostname           @"http://164.78.205.62/spmap/photos/"
#define panoramaHostname        @"http://164.78.205.62/spmap/panoramas/"
#define kReachabilityHostname   @"mobileapp.sp.edu.sg"
*/
#define kLocationsDatabaseURL   @"http://mobileapp.sp.edu.sg/spmap/database/Locations.xml"
#define kMapServiceURL          @"http://www.whereto.sg/WMGIS01/rest/services/WhereTo/Island_Base/MapServer"
#define imageHostname           @"http://mobileapp.sp.edu.sg/spmap/photos/"
#define panoramaHostname        @"http://mobileapp.sp.edu.sg/spmap/panoramas/"
#define kReachabilityHostname   @"mobileapp.sp.edu.sg"

/*
 All the view controllers are to be tagged.  The Navigation Controller contains the tagged view controllers when they
 are added. This is ensured that no duplicate or extra view controllers are added or created.
 The reason due to the workflow of the application.  The flow is as follows:
 
    (104)     (101)      (102)           (103)            
 About VC <-> Map VC <-> Category VC <-> List VC
                X
                |
                X
            Detail VC (105,106) <-> Panorama VC (107)
 
 
 The first and last Map VC in the flow is the same VC.  There is a need to navigate between the parent / child vc using
 the back button or selecting an option.
 
 Detail VC (105) is for details without additional panorama view
 Detail VC (106) is for details with panorama view
 
 Therefore, check if such VC exists within the Navigation Controller before adding the VC to the Navigation Controller
 */

