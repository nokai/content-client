//
//  ContentPlayerViewController.h
//  content-client
//
//  Created by Brian Pfeil on 4/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentWebView.h"
#import "ContentManager.h"
#import "ContentListViewController.h"
#import "ContentItem.h"
#import "SettingsViewController.h"

@interface ContentPlayerViewController : UIViewController<ContentListViewControllerDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate> {
	UIToolbar *_toolbar;
	ContentWebView *contentWebView;
	UINavigationController *_contentListNavigationController;
	ContentListViewController *_contentListViewController;
	UIPopoverController *_contentListPopoverController;
	ContentManager *_contentManager;
    
    UIView *_titleView;
    UILabel *_titleLabel;
    UIProgressView *_progressView;
    UIActivityIndicatorView *_activityIndicatorView;

    UILabel *_contentLoadingActivityLabel;
    UIActivityIndicatorView *_contentLoadingActivityIndicatorView;

    
    UIBarButtonItem *_warningErrorsBarButtonItem;
    
    UIBarButtonItem *_progressViewBarButtonItem;
    UIBarButtonItem *_syncBarButtonItem;
    UIBarButtonItem *_cancelSyncBarButtonItem;
    
    SettingsViewController *_settingsViewController;
    id _settingsPopoverController;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIView *titleView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *warningErrorsBarButtonItem;
@property (nonatomic, retain) IBOutlet UILabel *contentLoadingActivityLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *contentLoadingActivityIndicatorView;
@property (nonatomic, retain) IBOutlet ContentWebView *contentWebView;
@property (nonatomic, retain) ContentManager *contentManager;
@property (nonatomic, retain) SettingsViewController *settingsViewController;
@property (nonatomic, retain) id settingsPopoverController;

- (void)sync:(id)sender;
- (IBAction)displayContentItemList:(id)sender;
- (void)displayContentItem:(ContentItem*)contentItem;
-(IBAction)showSettings:(id)sender;

@end
