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
    
    NSURL *url = [NSURL URLWithString:panoramalink];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [webView loadRequest:request];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:(1.0/2.0)
                                             target:self 
                                           selector:@selector(loading) 
                                           userInfo:nil 
                                            repeats:YES];
}

- (void) loading {
	if (!webView.loading)
		[activity stopAnimating];
	else
		[activity startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self release];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self release];
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
