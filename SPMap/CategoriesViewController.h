//
//  CategoriesViewController.h
//  SPMap
//
//  Created by Wei Guang on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface CategoriesViewController : UITableViewController {
    NSMutableArray *category;
    MBProgressHUD *loading;
}

@end
