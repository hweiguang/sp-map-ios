//
//  CategoriesViewController.h
//  SPMap
//
//  Created by Wei Guang on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CategoriesViewController : UITableViewController {
    NSMutableArray *category;
    NSMutableSet *selectedCategories;
    
}
//@property (nonatomic, retain) NSMutableArray *category;
@property (nonatomic, retain) NSMutableSet *selectedCategories;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withCategories:(NSMutableSet*)theSet;

@end
