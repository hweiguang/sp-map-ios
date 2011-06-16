//
//  ContactsViewController.h
//  SP Map
//
//  Created by Wei Guang on 6/6/11.
//  Copyright 2011 Singapore Polytechnic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactsViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *webView;
}

@property(nonatomic, retain) IBOutlet UIWebView *webView;

@end
