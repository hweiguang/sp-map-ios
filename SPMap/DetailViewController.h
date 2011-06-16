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
    UIToolbar *toolbar;
    UIPopoverController *popOver;
}

@property (nonatomic, retain) UIActivityIndicatorView *activity;
@property (nonatomic, retain) IBOutlet UITextView * textView;
@property (nonatomic, retain) NSDictionary *details;
@property (nonatomic, retain) UIToolbar *toolbar;

- (void)grabImageInTheBackground;
- (void)showPanorama:(id)sender;
- (void)showLiveCam:(id)sender;
- (void)showVideo:(id)sender;

@end
