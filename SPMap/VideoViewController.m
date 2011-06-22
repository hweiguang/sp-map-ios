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
    
    // Getting Video Link
    NSString *videoLink = [videoHostname stringByAppendingString:selectedvideo];
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:videoLink]]];
    
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
    [selectedvideo release];
    [super dealloc];
}

@end
