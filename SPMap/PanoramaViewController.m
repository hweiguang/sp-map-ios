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
    
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // Getting Panorama Link
    NSString *panoramalink = [panoramaHostname stringByAppendingString:selectedPanorama];
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:panoramalink]]];
    
    //Timer to to check the status of webView
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                             target:self 
                                           selector:@selector(loading) 
                                           userInfo:nil 
                                            repeats:YES];
}

- (void) loading {
	if (!webView.loading){
		[activity stopAnimating];
        [timer invalidate];
    }
	else
		[activity startAnimating];
}

- (void)viewDidDisappear:(BOOL)animated {
    if ([webView isLoading])
        [webView stopLoading];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [webView release];
    [activity release];
    [selectedPanorama release];
    [super dealloc];
}

@end
