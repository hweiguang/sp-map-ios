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

@synthesize webView,selectedPanorama;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    loading = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:loading];
    loading.mode = MBProgressHUDModeIndeterminate;
    loading.labelText = @"Loading...";
    
    // Getting Panorama Link
    NSString *panoramalink = [panoramaHostname stringByAppendingString:selectedPanorama];
    
    webView.delegate = self;
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:panoramalink]]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [loading show:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [loading hide:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    if ([webView isLoading])
        [webView stopLoading];
}

- (void)dealloc
{
    [webView release];
    [selectedPanorama release];
    [super dealloc];
}

@end
