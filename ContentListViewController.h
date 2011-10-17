//
//  ContentListViewController.h
//  content-client
//
//  Created by Brian Pfeil on 4/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentManager.h"

@protocol ContentListViewControllerDelegate;


@interface ContentListViewController : UITableViewController {
	ContentManager *contentManager;
	NSDictionary *contentManifest;
	NSArray *_contentList;
	
	id delegate;
}

@property (nonatomic, retain) ContentManager *contentManager;
@property (nonatomic, retain) NSDictionary *contentManifest;
@property (nonatomic, retain) id<ContentListViewControllerDelegate> delegate;

- (void)reload;

@end

@protocol ContentListViewControllerDelegate
- (void)contentListViewController:(ContentListViewController*)contentListViewController didFinishWithInfo:(NSDictionary*)info;
@end
