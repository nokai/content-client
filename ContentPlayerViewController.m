    //
//  ContentPlayerViewController.m
//  content-client
//
//  Created by Brian Pfeil on 4/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ContentPlayerViewController.h"
#import "Settings.h"

@interface ContentPlayerViewController()
- (void)setStandardTitle;
- (void)createGestureRecognizers;
- (void)toggleToolbarVisibility;
- (UIButton*)customButtonWithImage:(NSString*)imageName action:(SEL)sel;
- (void)contentManagerDidFinishSyncing:(ContentManager*)contentManager;
- (void)setDownloadProgress:(NSNumber*)progress withMessage:(NSString*)message;
- (void)setActivityMessage:(NSString*)message;
- (void)setContentLoading:(BOOL)contentLoading;
- (void)setErrors:(BOOL)errors;
@end


@implementation ContentPlayerViewController

@synthesize contentManager=_contentManager,
    toolbar=_toolbar,
    titleView=_titleView,
    titleLabel=_titleLabel,
    progressView=_progressView,
    activityIndicatorView=_activityIndicatorView,
    warningErrorsBarButtonItem=_warningErrorsBarButtonItem,
    contentLoadingActivityIndicatorView=_contentLoadingActivityIndicatorView,
    contentLoadingActivityLabel=_contentLoadingActivityLabel,
    contentWebView,
    settingsViewController=_settingsViewController,
    settingsPopoverController=_settingsPopoverController;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		_contentListNavigationController = nil;
        _contentListViewController = nil;
		_contentListPopoverController = nil;

		self.contentManager = [ContentManager defaultContentManager];		
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
    _contentManager.delegate = self;
    
    [self setStandardTitle];
	

    // uncomment for Veeva Orange
    //self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
    self.toolbar.translucent = YES;
    self.warningErrorsBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self customButtonWithImage:@"warningsErrors.png" action:@selector(sceneListView:)]];    
    _warningErrorsBarButtonItem.customView.hidden = YES;
    NSMutableArray *tbItems = [NSMutableArray arrayWithArray:_toolbar.items];
    [tbItems insertObject:_warningErrorsBarButtonItem atIndex:([tbItems count] - 1)];
    self.toolbar.items = tbItems;
    
    _progressViewBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_progressView];
    _syncBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(sync:)];    
    _cancelSyncBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelSync:)];    
    
    [self setContentLoading:NO];
    
	[self createGestureRecognizers];

    // hide to allow background image to be visible
    contentWebView.alpha = 0.0;
    
    self.settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"sync" object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSError *err;
        [_contentManager sync:&err];

    }];

    [[NSNotificationCenter defaultCenter] addObserverForName:@"reset" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [_contentManager deleteAllContent];
    }];

    [[NSNotificationCenter defaultCenter] addObserverForName:@"SettingsViewController.dismissPopoverAnimated" object:nil queue:nil usingBlock:^(NSNotification *note) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if (_settingsPopoverController) {
                [_settingsPopoverController dismissPopoverAnimated:YES];
            }
        }
    }];
    
    
    NSError *err;
    [_contentManager sync:&err];
}

- (UIButton*)customButtonWithImage:(NSString*)imageName action:(SEL)sel {
    UIImage *img = [UIImage imageNamed:imageName];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    [btn setImage:img forState:UIControlStateNormal];
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    return btn;
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

-(IBAction)showSettings:(id)sender {
	UINavigationController *nc = [[UINavigationController alloc] init];
	[nc pushViewController:_settingsViewController animated:NO];
	
	// iPad
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// if the popover is showing, just dismiss it
		if (_settingsPopoverController != nil && [_settingsPopoverController isPopoverVisible]) {
			[_settingsPopoverController dismissPopoverAnimated:YES];
			return;
		}
		
		Class uiPopoverControllerClass = NSClassFromString(@"UIPopoverController");
		self.settingsPopoverController = (id)[[uiPopoverControllerClass alloc] initWithContentViewController:nc];
        [_settingsPopoverController setPopoverContentSize:CGSizeMake(320, 480)];
        [_settingsPopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        //[self.mypopoverController presentPopoverFromRect:[(UIButton*)sender frame] inView:_toolbar permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	} else { // iPhone/iPod Touch
		[self presentModalViewController:nc animated:YES];
	}
	
	[nc release];	
}

- (void)toggleToolbarVisibility {
	[UIView beginAnimations:@"toggleToolbarVisibility" context:nil];
    CGFloat navigationBarHeight = 44;
    if (_toolbar.alpha == 1.0) {
        _toolbar.alpha = 0.0;
        _toolbar.frame = CGRectOffset(_toolbar.frame, 0, -navigationBarHeight);
    } else {
        _toolbar.alpha = 1.0;
        _toolbar.frame = CGRectMake(0, 0, _toolbar.frame.size.width, _toolbar.frame.size.height);
    }
	
	[UIView commitAnimations];
}

- (void)sync:(id)sender {
	NSError *err;
	[_contentManager sync:&err];
}

- (void)cancelSync:(id)sender {
    [_contentManager cancelSync];
    [self setStandardTitle];
}

- (IBAction)displayContentItemList:(id)sender {
	
	// already displayed, so toggle off
	if (_contentListPopoverController != nil && _contentListPopoverController.popoverVisible) {
		[_contentListPopoverController dismissPopoverAnimated:YES];
		return;
	}
	
	if (_contentListViewController == nil) {
		_contentListViewController = [[[ContentListViewController alloc] initWithNibName:@"ContentListViewController" bundle:nil] retain];
		_contentListViewController.contentManager = _contentManager;
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
	NSString *contentItemContentFilePath = [_contentManager contentItemContentFilePath:contentItem];
	NSString *contentItemContentDirectoryPath = [_contentManager contentItemDirectoryPathFromContentItemDirectoryName:[contentItem contentItemDirectoryName]];
	NSURL *contentItemURL = [NSURL fileURLWithPath:contentItemContentFilePath];
	
    contentWebView.alpha = 1.0;
	[contentWebView loadRequest:[NSURLRequest requestWithURL:contentItemURL]];
    
	// other ways to load content
	//[contentWebView loadData:data MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:[NSURL fileURLWithPath:contentItemContentDirectoryPath]];
    //[contentWebView loadHTMLString:[NSString stringWithContentsOfFile:contentItemContentFilePath] baseURL:[NSURL fileURLWithPath:contentItemContentDirectoryPath]];    
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
    DLog(@"content started loading");
//    [UIView animateWithDuration:0.25 animations:^{
//        self.contentWebView.hidden = YES;
//        [self setContentLoading:YES];        
//    }];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    DLog(@"content finished loading");
//    [UIView animateWithDuration:0.25 animations:^{    
//        self.contentWebView.hidden = NO;
//        [self setContentLoading:NO];
//    }];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {

}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	return YES;
}

- (void)setContentLoading:(BOOL)contentLoading {
    _contentLoadingActivityIndicatorView.hidden = !contentLoading;
    _contentLoadingActivityLabel.hidden = !contentLoading;
}

- (void)setErrors:(BOOL)errors {
    _warningErrorsBarButtonItem.customView.hidden = !errors;
}

#pragma mark content manager
- (void)contentManager:(ContentManager*)contentMgr beginContentUpdateCheckWithInfo:(NSDictionary*)info {
    [self setErrors:NO];
    [self setActivityMessage:[Settings string:@"contentUpdateCheckMessage"]];
}

- (void)contentManager:(ContentManager*)contentMgr requestFailedWithInfo:(NSDictionary*)info {
    [self setStandardTitle];
    [self setErrors:YES];
}

- (void)contentManagerDidStartContentItemDownload:(ContentManager*)contentMgr withContentItemMetaData:(NSDictionary*)contentItemMetaData {
    NSNumber *progress = [NSNumber numberWithFloat:0.0f];
    NSString *message = [NSString stringWithFormat:[Settings string:@"downloadMessageFormatString"],
                         [contentMgr activeDownloadItemIndex],
                         [contentMgr itemsToDownloadInSession],
                         [contentItemMetaData valueForKeyPath:@"content_item_manifest.name"], (progress.floatValue * 100)];
    
    [self setDownloadProgress:progress withMessage:message];
}

- (void)contentManager:(ContentManager*)contentMgr progressUpdateWithInfo:(NSDictionary*)info {
    NSNumber *progress = [info valueForKey:@"progress"];
    NSDictionary *contentItemMetaData = [info valueForKey:@"contentItemMetaData"];
    
    NSString *message = [NSString stringWithFormat:[Settings string:@"downloadMessageFormatString"],
                         [contentMgr activeDownloadItemIndex],
                         [contentMgr itemsToDownloadInSession],
                         [contentItemMetaData valueForKeyPath:@"content_item_manifest.name"], (progress.floatValue * 100)];
    
    [self setDownloadProgress:progress withMessage:message];
}


- (void)contentManagerDidFinishContentItemDownload:(ContentManager*)contentManager withContentItemMetaData:(NSDictionary*)contentItemMetaData {
    DLog(@"contentItemMetaData = %@", contentItemMetaData);
	if (_contentListViewController != nil) {
		[_contentListViewController reload];
	}
}


- (void)contentManagerDidFinishSyncing:(ContentManager*)contentManager {
	if (_contentListViewController != nil) {
		[_contentListViewController reload];
	}
    [self setStandardTitle];
//	_titleLabel.text = @"Content Player";
//    _progressView.hidden = YES;
//    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:_syncBarButtonItem, _progressViewBarButtonItem, nil];
}

- (void)setDownloadProgress:(NSNumber*)progress withMessage:(NSString*)message {
    _activityIndicatorView.hidden = YES;
    _progressView.hidden = NO;
    _titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y, _titleLabel.frame.size.width, 15);
    _titleLabel.font = [UIFont systemFontOfSize:13.0f];
	_titleLabel.text = message;
    _progressView.progress = progress.floatValue;

}

- (void)setActivityMessage:(NSString*)message {
    _progressView.hidden = YES;
    _titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y, _titleLabel.frame.size.width, 32);
    _titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    _titleLabel.text = message;
    _activityIndicatorView.hidden = NO;
    [_activityIndicatorView startAnimating];

}

- (void)setStandardTitle {
    _progressView.hidden = YES;
    _titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y, _titleLabel.frame.size.width, 32);
    _titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    _titleLabel.text = [Settings string:@"applicationTitle"];    
}

#pragma mark orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[contentWebView orientationChanged];
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
