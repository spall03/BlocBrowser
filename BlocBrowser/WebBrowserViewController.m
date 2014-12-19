//
//  WebBrowserViewController.m
//  BlocBrowser
//
//  Created by Stephen Palley on 12/15/14.
//  Copyright (c) 2014 Steve Palley. All rights reserved.
//

#import "WebBrowserViewController.h"
#import "AwesomeFloatingToolbar.h"

#define kWebBrowserBackString NSLocalizedString(@"Back", @"Back command")
#define kWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward command")
#define kWebBrowserStopString NSLocalizedString(@"Stop", @"Stop command")
#define kWebBrowserRefreshString NSLocalizedString(@"Refresh", @"Reload command")

@interface WebBrowserViewController () <UIWebViewDelegate, UITextFieldDelegate, AwesomeFloatingToolbarDelegate>

@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) AwesomeFloatingToolbar *awesomeToolbar;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

 @property (nonatomic, assign) NSUInteger frameCount;

@end

@implementation WebBrowserViewController

#pragma mark - UIViewController

//clear and reset web history
- (void) resetWebView {
    [self.webview removeFromSuperview];
    
    UIWebView *newWebView = [[UIWebView alloc] init];
    newWebView.delegate = self;
    [self.view addSubview:newWebView];
    
    self.webview = newWebView; //new web browser
    
    self.textField.text = nil; //reset text field
    [self updateButtonsAndTitle];
}

- (void)loadView {
    UIView *mainView = [UIView new];
    
    self.webview = [[UIWebView alloc]init];
    self.webview.delegate = self;
    
    self.textField = [[UITextField alloc] init]; //setting up a textfield for user to add their own URL
    self.textField.keyboardType = UIKeyboardTypeURL;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.placeholder = NSLocalizedString(@"Website URL or Google search query", @"Placeholder text for web browser URL field");
    self.textField.backgroundColor = [UIColor colorWithWhite:220/255.0f alpha:1];
    self.textField.delegate = self;
    
    self.awesomeToolbar = [[AwesomeFloatingToolbar alloc] initWithFourTitles:@[kWebBrowserBackString, kWebBrowserForwardString, kWebBrowserStopString, kWebBrowserRefreshString]];
    self.awesomeToolbar.delegate = self;
    
    //adding subviews to main view
    for (UIView *viewToAdd in @[self.webview, self.textField, self.awesomeToolbar]) {
        [mainView addSubview:viewToAdd];
    }
    self.view = mainView;
    
   
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]; //instantiate a basic activity spinner
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator]; //stick it in the nav bar
    
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // First, calculate some dimensions.
    static const CGFloat itemHeight = 50; //we want the URL bar to be 50px high
    CGFloat width = CGRectGetWidth(self.view.bounds); //width of full window
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight; //we want browser to take up all space NOT taken up by URL bar
 
    
    // Now, assign the frames
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webview.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight); //put browser right underneath URL bar
    
    self.awesomeToolbar.frame = CGRectMake(40, 100, 280, 60);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BLCAwesomeFloatingToolbarDelegate

- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title {
    if ([title isEqual:kWebBrowserBackString]) {
        [self.webview goBack];
    } else if ([title isEqual:kWebBrowserForwardString]) {
        [self.webview goForward];
    } else if ([title isEqual:kWebBrowserStopString]) {
        [self.webview stopLoading];
    } else if ([title isEqual:kWebBrowserRefreshString]) {
        [self.webview reload];
    }
}

- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset {
    CGPoint startingPoint = toolbar.frame.origin;
    CGPoint newPoint = CGPointMake(startingPoint.x + offset.x, startingPoint.y + offset.y);
    
    CGRect potentialNewFrame = CGRectMake(newPoint.x, newPoint.y, CGRectGetWidth(toolbar.frame), CGRectGetHeight(toolbar.frame));
    
    if (CGRectContainsRect(self.view.bounds, potentialNewFrame)) { //the toolbar won't move off the screen
        toolbar.frame = potentialNewFrame;
    }
}

- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didPinchToolbar:(CGFloat)scale
{
    
    CGAffineTransform potentialTransform = CGAffineTransformMakeScale(scale, scale);
    
    CGRect potentialNewFrame = toolbar.frame;
    
    potentialNewFrame = CGRectApplyAffineTransform(potentialNewFrame, potentialTransform);
    
    if (CGRectContainsRect(self.view.bounds, potentialNewFrame)) {
        toolbar.transform = potentialTransform;
    }
                                                               
}

- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didFireLongPress:(CGPoint)location
{
    
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    NSString *userString = textField.text;
    NSURL *URL;
    
    //look for a space in user text entry
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@" " options:0 error:nil];
    NSInteger matches = [regex numberOfMatchesInString:userString options:0 range:NSMakeRange(0, [userString length])];
    
    if (matches > 0)//this is a google search
    {
        NSString *searchString = [userString stringByReplacingOccurrencesOfString:@" " withString:@"+"]; //reformat to match google search format
        NSString *googleSearchString = [NSString stringWithFormat:@"http://www.google.com/search?q=%@", searchString];
        URL = [NSURL URLWithString:googleSearchString];
    }
    else//this is a URL
    {
        URL = [NSURL URLWithString:userString];
    }
    
    if (!URL.scheme) {
        // The user didn't type http: or https:
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URL]]; //append it to the front of the URL
    }
    
    if (URL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webview loadRequest:request];
    }
   
    

    
    return NO;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.frameCount++;
    [self updateButtonsAndTitle];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.frameCount--;
    [self updateButtonsAndTitle];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (error.code != -999) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    [self updateButtonsAndTitle];
    self.frameCount--;
}

#pragma mark - Miscellaneous

- (void)updateButtonsAndTitle
{
    NSString *webpageTitle = [self.webview stringByEvaluatingJavaScriptFromString:@"document.title"]; //get webpage title from JS
    
    if (webpageTitle) {
        self.title = webpageTitle;
    } else {
        self.title = self.webview.request.URL.absoluteString;
    }
    
    if (self.frameCount > 0) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
    
    [self.awesomeToolbar setEnabled:[self.webview canGoBack] forButtonWithTitle:kWebBrowserBackString];
    [self.awesomeToolbar setEnabled:[self.webview canGoForward] forButtonWithTitle:kWebBrowserForwardString];
    [self.awesomeToolbar setEnabled:self.frameCount > 0 forButtonWithTitle:kWebBrowserStopString];
    [self.awesomeToolbar setEnabled:self.webview.request.URL && self.frameCount == 0 forButtonWithTitle:kWebBrowserRefreshString];

    
    
}

@end
