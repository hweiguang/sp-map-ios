//
//  DetailViewController.h
//  SPMap
//
//  Created by Wei Guang on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@interface DetailViewController : UIViewController {
    IBOutlet UIImageView *imageView;
	IBOutlet UIActivityIndicatorView *activity;
    IBOutlet UITextView * textView;
    NSDictionary *details;
    ASIHTTPRequest *request; 
    NSOperationQueue *operationQueue;
}

@property (nonatomic, retain) UIActivityIndicatorView *activity;
@property (nonatomic, retain) IBOutlet UITextView * textView;
@property (nonatomic, retain) NSDictionary *details;

- (void)grabImageInTheBackground;
- (IBAction)panoramaButtonAction;

@end
