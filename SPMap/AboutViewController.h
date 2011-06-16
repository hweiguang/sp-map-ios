//
//  AboutViewController.h
//  SPMap
//
//  Created by Wei Guang on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *webView;
}

@property(nonatomic, retain) IBOutlet UIWebView *webView;

@end
