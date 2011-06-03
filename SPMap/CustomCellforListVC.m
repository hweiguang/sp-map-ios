//
//  CustomCellforListVC.m
//  SP Map
//
//  Created by Wei Guang on 6/1/11.
//  Copyright 2011 Singapore Polytechnic. All rights reserved.
//

#import "CustomCellforListVC.h"

@implementation CustomCellforListVC

@synthesize primaryLabel,secondaryLabel,distanceLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
        primaryLabel = [[UILabel alloc]initWithFrame:CGRectMake(10,0,265,25)];
        primaryLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
        
        secondaryLabel = [[UILabel alloc]initWithFrame:CGRectMake(10,25,265,15)];
        secondaryLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        
        distanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(275,14.5,40,15)];
        distanceLabel.textAlignment = UITextAlignmentCenter;
        distanceLabel.adjustsFontSizeToFitWidth = YES;
        
        [self.contentView addSubview:primaryLabel];
        [self.contentView addSubview:secondaryLabel];
        [self.contentView addSubview:distanceLabel]; 
    }
    return self;
}

- (void)dealloc {
    [primaryLabel release];
    [secondaryLabel release];
    [distanceLabel release];
    [super dealloc];
}

@end
