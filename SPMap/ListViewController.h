//
//  ListViewController.h
//  SP Map
//
//  Created by Wei Guang on 4/14/11.
//  Copyright 2011 Singapore Polytechnic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListViewController : UITableViewController {
    
    NSString *places;
    NSMutableArray *locations;
    NSMutableArray *locationsincategory;
    NSMutableArray *selectedLocations;
}

@property (nonatomic, retain) NSString *places;
@property (nonatomic, retain) NSMutableArray *locations;
@property (nonatomic, retain) NSMutableArray *selectedLocations;

- (void)showAll;

@end
