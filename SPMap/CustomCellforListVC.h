//
//  CustomCellforListVC.h
//  SP Map
//
//  Created by Wei Guang on 6/1/11.
//  Copyright 2011 Singapore Polytechnic. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomCellforListVC : UITableViewCell {
    UILabel *primaryLabel;
    UILabel *secondaryLabel;
    UILabel *distanceLabel;
}
@property(nonatomic,retain) UILabel *primaryLabel;
@property(nonatomic,retain) UILabel *secondaryLabel;
@property(nonatomic,retain) UILabel *distanceLabel;

@end
