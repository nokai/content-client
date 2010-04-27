    //
//  ContentPlayerViewController.m
//  content-client
//
//  Created by Brian Pfeil on 4/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ContentPlayerViewController.h"

@interface ContentPlayerViewController()
- (void)createGestureRecognizers;
- (void)toggleToolbarVisibility;
@end


@implementation ContentPlayerViewController

@synthesize toolBar, contentWebView;
@synthesize contentManager;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		_contentListNavigationController = nil;
        _contentListViewController = nil;
		_contentListPopoverController = nil;
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Presentations" style:UIBarButtonItemStylePlain target:self action:@selector(displayContentItemList:)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(sync:)];
	[self createGestureRecognizers];
	[super viewDidLoad];
}

- (void)createGestureRecognizers {
	UITapGestureRecognizer *singleFingerDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerDoubleTap:)];
    singleFingerDoubleTap.numberOfTapsRequired = 2;
	singleFingerDoubleTap.delegate = self;
	
    [self.view addGestureRecognizer:singleFingerDoubleTap];
    [singleFingerDoubleTap release];	
}

- (void)handleSingleFingerDoubleTap:(UIGestureRecognizer *)sender {
	NSLog(@"handleSingleFingerDoubleTap called");
	[self toggleToolbarVisibility];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer {
	// this is in place as a workaround a bug acknowledged by apple
	// apple dev forum post: https://devforums.apple.com/message/161990#161990
    if ([otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && [[otherGestureRecognizer view] isDescendantOfView:[gestureRecognizer view]]) {
        return YES;
    }
    return NO;	
}

- (void)toggleToolbarVisibility {
	[UIView beginAnimations:@"toggleToolbarVisibility" context:nil];
	self.navigationController.navigationBar.alpha = (self.navigationController.navigationBar.alpha == 1.0) ? 0 : 1;
	[UIView commitAnimations];
}

- (IBAction)displayContentItemList:(id)sender {
	
	// already displayed, so toggle off
	if (_contentListPopoverController != nil && _contentListPopoverController.popoverVisible) {
		[_contentListPopoverController dismissPopoverAnimated:YES];
		return;
	}
	
	if (_contentListViewController == nil) {
		_contentListViewController = [[[ContentListViewController alloc] initWithNibName:@"ContentListViewController" bundle:nil] retain];
		_contentListViewController.contentManifest = contentManager.contentManifest;
		_contentListViewController.delegate = self;
	}
	
	_contentListNavigationController = [[UINavigationController alloc] init];
	[_contentListNavigationController pushViewController:_contentListViewController animated:NO];
	_contentListPopoverController = [[UIPopoverController alloc] initWithContentViewController:_contentListNavigationController];
	
	[_contentListPopoverController presentPopoverFromBarButtonItem:sender
											    permittedArrowDirections:UIPopoverArrowDirectionAny
																   animated:YES];
	[_contentListNavigationController release];
}

- (void)contentListViewController:(ContentListViewController*)contentListViewController didFinishWithInfo:(NSDictionary*)info {
	ContentItem *contentItem = [info valueForKey:@"contentItem"];
	[self toggleToolbarVisibility];
	[self displayContentItem:contentItem];
	[_contentListPopoverController dismissPopoverAnimated:YES];
}

- (void)displayContentItem:(ContentItem*)contentItem {
	NSString *contentItemContentFilePath = [contentManager contentItemContentFilePath:contentItem];
	NSData *data = [NSData dataWithContentsOfFile:contentItemContentFilePath];
	NSString *contentItemContentDirectoryPath = [contentManager contentItemDirectoryPathFromContentItemDirectoryName:[contentItem contentItemDirectoryName]];
	NSURL *contentItemURL = [NSURL fileURLWithPath:contentItemContentFilePath];
	[contentWebView loadHTMLString:[NSString stringWithContentsOfFile:contentItemContentFilePath] baseURL:[NSURL fileURLWithPath:contentItemContentDirectoryPath]];

	// other ways to load the page
	//[webView loadData:data MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:[NSURL fileURLWithPath:contentItemContentDirectoryPath]];
	//[webView loadRequest:[NSURLRequest requestWithURL:contentItemURL]];
}

- (NSString*)stringByEvaluatingJavaScriptFunction:(NSString*)functionName withArgument:(id)argument {
	NSString *argumentStringRepresentation = (argument == nil) ? @"" : [argument JSONRepresentation];
	NSString *javaScriptCode = [NSString stringWithFormat:@"(function() { %@(%@); })();", functionName, argumentStringRepresentation];
	// only execute javascript code if we are done loading
	if (!contentWebView.loading) {
		return [contentWebView stringByEvaluatingJavaScriptFromString:javaScriptCode];			
	} else {
		[NSException raise:@"Execute javascript code before the page has finished loading" format:@"Trying to execute javascript code before the page has finished loading"];
	}
}

#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {

}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	return YES;
}

#pragma mark orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self stringByEvaluatingJavaScriptFunction:@"orientationChanged" withArgument:nil];
	
	//[contentWebView stringByEvaluatingJavaScriptFromString:@"orientationChanged();"];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[_contentListPopoverController release];
	[_contentListViewController release];	
	[_contentListNavigationController release];
    [super dealloc];
}


@end
