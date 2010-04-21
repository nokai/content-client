    //
//  ContentPlayerViewController.m
//  content-client
//
//  Created by Brian Pfeil on 4/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ContentPlayerViewController.h"

@interface ContentPlayerViewController()
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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (IBAction)displayContentItemList:(id)sender {
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
	toolBar.hidden = YES;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[contentWebView stringByEvaluatingJavaScriptFromString:@"orientationChanged();"];
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
