//
//  PanoramaViewController.h
//  SPMap
//
//  Created by Wei Guang on 4/8/11.
//  Copyright 2011 Singapore Polytechnic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PanoramaViewController : UIViewController {
	IBOutlet UIWebView *webView;
	IBOutlet UIActivityIndicatorView *activity;
	NSTimer *timer;
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIActivityIndicatorView *activity;
@property (nonatomic, retain) NSString *selectedPanorama;

@end
