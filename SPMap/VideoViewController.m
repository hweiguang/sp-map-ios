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

@synthesize webView,activity,selectedvideo;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // Getting video Link
    NSString *videolink = [videoHostname stringByAppendingString:selectedvideo];
    
    NSURL *url = [NSURL URLWithString:videolink];
    
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
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"aboutData" ofType:@"html"];
	NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
	[webView loadHTMLString:htmlString baseURL:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [webView release];
    [activity release];
    [super dealloc];
}

@end
