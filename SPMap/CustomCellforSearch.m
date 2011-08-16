//
//  CustomCellforSearch.m
//  SP Map
//
//  Created by Wei Guang on 15/8/11.
//  Copyright 2011 Singapore Polytechnic. All rights reserved.
//

#import "CustomCellforSearch.h"

@implementation CustomCellforSearch

@synthesize text;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //UILabel for display the search results
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            text = [[UILabel alloc]initWithFrame:CGRectMake(5,5,310,25)]; //frame for iPhone
        else
            text = [[UILabel alloc]initWithFrame:CGRectMake(5,5,758,25)]; //frame for iPad
        text.numberOfLines = 0;
        text.font = [UIFont boldSystemFontOfSize:17.0];
        [self.contentView addSubview:text];
    }
    return self;
}

- (void)dealloc {
    [text release];
    [super dealloc];
}

@end
