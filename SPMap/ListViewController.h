//
//  ListViewController.h
//  SP Map
//
//  Created by Wei Guang on 4/14/11.
//  Copyright 2011 Singapore Polytechnic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListViewController : UITableViewController {
    NSString *selectedCategory;
    NSMutableArray *locations;
    NSMutableArray *locationsincategory;
}

@property (nonatomic, retain) NSString *selectedCategory;

- (void)showAll;

@end
