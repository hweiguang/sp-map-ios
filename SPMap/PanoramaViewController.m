//
//  PanoramaViewController.m
//  SPMap
//
//  Created by Wei Guang on 4/8/11.
//  Copyright 2011 Singapore Polytechnic. All rights reserved.
//

#import "PanoramaViewController.h"
#import "Constants.h"

@implementation PanoramaViewController

@synthesize webView,activity,selectedPanorama;

- (void)viewDidLoad {
	
	UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                        target:self
                                                                                        action:@selector(Refresh)];
	self.navigationItem.rightBarButtonItem = rightBarButtonItem;
	[rightBarButtonItem release];
    
    // Getting Panorama Link
    NSString *panoramalink = [panoramaHostname stringByAppendingString:selectedPanorama];
    
    NSURL *url = [NSURL URLWithString:panoramalink];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [webView loadRequest:request];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:(1.0/2.0) target:self selector:@selector(loading) userInfo:nil repeats:YES];
	
    [super viewDidLoad];
}

- (void) loading {
	
	if (!webView.loading)
		[activity stopAnimating];
	else
		[activity startAnimating];
	
}

- (void) Refresh {
	
	[webView reload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return YES;
}

- (void)dealloc {
    [webView release];
    [activity release];
    [selectedPanorama release];
    [super dealloc];
}


@end
