//
//  WebBrowserViewController.h
//  BlocBrowser
//
//  Created by Stephen Palley on 12/15/14.
//  Copyright (c) 2014 Steve Palley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebBrowserViewController : UIViewController

/**
 Replaces the web view with a fresh one, erasing all history. Also updates the URL field and toolbar buttons appropriately.
 */
- (void) resetWebView;




@end

