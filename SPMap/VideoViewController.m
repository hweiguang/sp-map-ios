//
//  VideoViewController.m
//  SP Map
//
//  Created by Wei Guang on 6/8/11.
//  Copyright 2011 Singapore Polytechnic. All rights reserved.
//

#import "VideoViewController.h"
#import "Constants.h"

@implementation VideoViewController

@synthesize webView,selectedvideo;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // Getting Video Link
    NSString *videoLink = [videoHostname stringByAppendingString:selectedvideo];
    
    webView.delegate = self;
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:videoLink]]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
}

- (void)viewDidDisappear:(BOOL)animated {
    if ([webView isLoading])
        [webView stopLoading];
}

- (void)dealloc
{
    [webView release];
    [selectedvideo release];
    [super dealloc];
}

@end
