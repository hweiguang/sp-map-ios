//
//  LiveCamViewController.h
//  SP Map
//
//  Created by Wei Guang on 6/2/11.
//  Copyright 2011 Singapore Polytechnic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@interface LiveCamViewController : UIViewController {
    IBOutlet UIImageView *imageView;
	IBOutlet UIActivityIndicatorView *activity;
    IBOutlet UITextView * textView;
    NSDictionary *details;
    ASIHTTPRequest *request; 
    NSOperationQueue *operationQueue;
}

@property (nonatomic, retain) UIActivityIndicatorView *activity;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) NSString *selectedLiveCam;

- (void)grabImageInTheBackground;
- (IBAction)refresh:(id)sender;

@end
