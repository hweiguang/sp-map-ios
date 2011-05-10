//
//  DetailViewController.m
//  SPMap
//
//  Created by Wei Guang on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//  see http://allseeing-i.com/ASIHTTPRequest/How-to-use
//

#import "DetailViewController.h"
#import "ASIHTTPRequest.h"
#import "PanoramaViewController.h"
#import "Constants.h"

@implementation DetailViewController
@synthesize textView,details,activity,toolbar;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if (!operationQueue) {
        operationQueue = [[NSOperationQueue alloc] init];
    }
    //Set the title of the View to the name of the selected pin
    NSString *title = [details valueForKey:@"title"];
    self.title = title;
    //Set the description of the place
    NSString *description = [details valueForKey:@"description"];
    [self.textView setText:description];
    
    [self grabImageInTheBackground];
    
    NSString *panorama = [details valueForKey:@"panorama"];
    
    if (panorama != nil) {
        
        toolbar = [UIToolbar new];
        toolbar.barStyle = UIBarStyleBlack;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            toolbar.frame = CGRectMake(0, 372, 320, 44);
        else
            toolbar.frame = CGRectMake(0, 916, 768, 44);
        
        [self.view addSubview:toolbar];
        
        UIBarButtonItem *showPanoramaButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Panorama.png"]
                                                                                   style:UIBarButtonItemStylePlain
                                                                                  target:self
                                                                                  action:@selector(showPanorama:)];
        
        NSArray *items = [NSArray arrayWithObjects:showPanoramaButtonItem,nil];
        [self.toolbar setItems:items animated:NO];
    }
}

- (void)showPanorama:(id)sender
{
    PanoramaViewController *panoramaViewController = [[PanoramaViewController alloc]
                                                      initWithNibName:@"PanoramaViewController" bundle:nil];
    
    panoramaViewController.selectedPanorama = [details valueForKey:@"panorama"];
    
    UIBarButtonItem *backbutton = [[UIBarButtonItem alloc] initWithTitle:@"Back" 
                                                                   style:UIBarButtonItemStylePlain 
                                                                  target:nil action:nil];
	self.navigationItem.backBarButtonItem = backbutton;
    [backbutton release];
    
    panoramaViewController.title = @"Panorama";
    [self.navigationController pushViewController:panoramaViewController animated:YES];
	[panoramaViewController release];
    
}

- (void)grabImageInTheBackground
{
    NSString *imagename = [details valueForKey:@"photos"];
    
    if (imagename != nil) {
        [activity startAnimating];
        NSString *imglink = [imageHostname stringByAppendingString:imagename];
        
        NSURL *url = [NSURL URLWithString:imglink];
        request = [[ASIHTTPRequest alloc] initWithURL:url];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(requestDone:)];
        [request setDidFailSelector:@selector(requestWentWrong:)];
        [operationQueue addOperation:request];  // request is an NSOperationQueue
    }
    
    //  no photo defined, use default image not found
    else
    {
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
- (void)requestWentWrong:(ASIHTTPRequest *)theRequest
{
    //  set image not found
    imageView.image = [UIImage imageNamed:@"UnavailableImage.png"];        
    [activity stopAnimating];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [imageView release];
	[activity release];
    [textView release];
    [details release];
    [activity stopAnimating];
    [request clearDelegatesAndCancel];
    [request release];
    [operationQueue cancelAllOperations];
    [operationQueue release];
    [toolbar release];
    [super dealloc];
}

@end
