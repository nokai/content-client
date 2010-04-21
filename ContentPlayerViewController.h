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

@interface ContentPlayerViewController : UIViewController<ContentListViewControllerDelegate> {
	UIToolbar *toolBar;
	ContentWebView *contentWebView;
	UINavigationController *_contentListNavigationController;
	ContentListViewController *_contentListViewController;
	UIPopoverController *_contentListPopoverController;
	
	ContentManager *contentManager;
	
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;
@property (nonatomic, retain) IBOutlet ContentWebView *contentWebView;

@property (nonatomic, retain) ContentManager *contentManager;

- (IBAction)displayContentItemList:(id)sender;
- (void)displayContentItem:(ContentItem*)contentItem;

@end
