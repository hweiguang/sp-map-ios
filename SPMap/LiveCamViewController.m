//
//  LiveCamViewController.m
//  SP Map
//
//  Created by Wei Guang on 6/2/11.
//  Copyright 2011 Singapore Polytechnic. All rights reserved.
//

#import "LiveCamViewController.h"
#import "ASIHTTPRequest.h"
#import "Constants.h"

@implementation LiveCamViewController
@synthesize textView,activity,selectedLiveCam;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if (!operationQueue)
        operationQueue = [[NSOperationQueue alloc] init];
    
    [self grabImageInTheBackground];
    
    self.contentSizeForViewInPopover = CGSizeMake(320, 400); //For iPad only
}

- (IBAction)refresh:(id)sender {
    [request clearDelegatesAndCancel];
    [request release];
    [self grabImageInTheBackground];
}

- (void)grabImageInTheBackground {
    NSString *livecamimagename = selectedLiveCam;
    
    if (livecamimagename != nil) {
        [activity startAnimating];
        NSString *imglink = [livecamHostname stringByAppendingString:livecamimagename];
        
        NSURL *url = [NSURL URLWithString:imglink];
        request = [[ASIHTTPRequest alloc] initWithURL:url];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(requestDone:)];
        [request setDidFailSelector:@selector(requestWentWrong:)];
        [operationQueue addOperation:request];  // request is an NSOperationQueue
    }
    //  no photo defined, use default image not found
    else {
        imageView.image = [UIImage imageNamed:@"UnavailableImage.png"];        
        [activity stopAnimating];
    }
}

//  connected
- (void)requestDone:(ASIHTTPRequest *)theRequest
{
    NSData *responseData = [theRequest responseData];
    int statusCode = [theRequest responseStatusCode];
    
    //  file not found
    if (statusCode == 404) {
        imageView.image = [UIImage imageNamed:@"UnavailableImage.png"];
    }
    //  image is nil
    else if (responseData == nil)
        imageView.image = [UIImage imageNamed:@"UnavailableImage.png"];
    //  image found
    else
        imageView.image = [UIImage imageWithData:responseData];
    [activity stopAnimating];    
}

//  unable to connect, image not found; i.e use default image not found
- (void)requestWentWrong:(ASIHTTPRequest *)theRequest {
    //  set image not found
    imageView.image = [UIImage imageNamed:@"UnavailableImage.png"];        
    [activity stopAnimating];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [imageView release];
	[activity release];
    [textView release];
    [details release];
    [selectedLiveCam release];
    [activity stopAnimating];
    [request clearDelegatesAndCancel];
    [request release];
    [operationQueue cancelAllOperations];
    [operationQueue release];
    [super dealloc];
}

@end
