//
//  PanoramaViewController.h
//  SPMap
//
//  Created by Wei Guang on 4/8/11.
//  Copyright 2011 Singapore Polytechnic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface PanoramaViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *webView;
    MBProgressHUD *loading;
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) NSString *selectedPanorama;

@end
