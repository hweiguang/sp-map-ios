//
//  VideoViewController.h
//  SP Map
//
//  Created by Wei Guang on 6/8/11.
//  Copyright 2011 Singapore Polytechnic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoViewController : UIViewController {
	IBOutlet UIWebView *webView;
	IBOutlet UIActivityIndicatorView *activity;
	NSTimer *timer;
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIActivityIndicatorView *activity;
@property (nonatomic, retain) NSString *selectedvideo;

@end
