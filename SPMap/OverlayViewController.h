//
//  OverlayViewController.h
//  SP Map
//
//  Created by Wei Guang on 5/9/11.
//  Copyright 2011 Singapore Polytechnic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MapViewController;

@interface OverlayViewController : UITableViewController {
    NSMutableArray *searchResults;
    MapViewController *mapViewController;
}

@property (nonatomic, retain) MapViewController *mapViewController;

- (void) reloadsearchResults;

@end
