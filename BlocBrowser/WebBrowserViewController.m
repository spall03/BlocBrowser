//
//  WebBrowserViewController.m
//  BlocBrowser
//
//  Created by Stephen Palley on 12/15/14.
//  Copyright (c) 2014 Steve Palley. All rights reserved.
//

#import "WebBrowserViewController.h"

@interface WebBrowserViewController () <UIWebViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *forwardButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *reloadButton;
 @property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

 @property (nonatomic, assign) NSUInteger frameCount;

@end

@implementation WebBrowserViewController

#pragma mark - UIViewController

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
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem]; //setting up nav buttons
    [self.backButton setEnabled:NO];
    
    self.forwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.forwardButton setEnabled:NO];
    
    self.stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.stopButton setEnabled:NO];
    
    self.reloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.reloadButton setEnabled:NO];
    
    [self.backButton setTitle:NSLocalizedString(@"Back", @"Back comnmand") forState:UIControlStateNormal];
    [self.backButton addTarget:self.webview action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    [self.forwardButton setTitle:NSLocalizedString(@"Forward", @"Forward comnmand") forState:UIControlStateNormal];
    [self.forwardButton addTarget:self.webview action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    
    [self.stopButton setTitle:NSLocalizedString(@"Stop", @"Stop comnmand") forState:UIControlStateNormal];
    [self.stopButton addTarget:self.webview action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];
    
    [self.reloadButton setTitle:NSLocalizedString(@"Refresh", @"Reload comnmand") forState:UIControlStateNormal];
    [self.reloadButton addTarget:self.webview action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    
//    NSString *urlString = @"http://wikipedia.org";
//    NSURL *url = [NSURL URLWithString:urlString]; //create URL object
//    NSURLRequest *request = [NSURLRequest requestWithURL:url]; //pass it in to create URL request object
//    [self.webview loadRequest:request]; //ask the webview to load this request
    
    //adding subviews to main view
    for (UIView *viewToAdd in @[self.webview, self.textField, self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
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
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - (itemHeight * 2); //we want browser to take up all space NOT taken up by URL bar or control bar
    CGFloat buttonWidth = CGRectGetWidth(self.view.bounds) / 4;
    
    // Now, assign the frames
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webview.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight); //put browser right underneath URL bar
    
    CGFloat currentButtonX = 0;
    
    //automagically assign button positions
    for (UIButton *thisButton in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
        thisButton.frame = CGRectMake(currentButtonX, CGRectGetMaxY(self.webview.frame), buttonWidth, itemHeight);
        currentButtonX += buttonWidth;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    //enable forward and back buttons if it makes sense to do so
    self.backButton.enabled = [self.webview canGoBack];
    self.forwardButton.enabled = [self.webview canGoForward];
    
    //same for stop and reload buttons, depending on whether page is loading or not
    self.stopButton.enabled = self.frameCount > 0;
    self.reloadButton.enabled = self.frameCount == 0;
    
    
}

@end
