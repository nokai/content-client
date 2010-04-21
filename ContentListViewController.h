//
//  ContentListViewController.h
//  content-client
//
//  Created by Brian Pfeil on 4/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ContentListViewControllerDelegate;


@interface ContentListViewController : UITableViewController {
	NSDictionary *contentManifest;
	NSArray *_contentList;
	
	id delegate;
}

@property (nonatomic, retain) NSDictionary *contentManifest;
@property (nonatomic, retain) id<ContentListViewControllerDelegate> delegate;

@end

@protocol ContentListViewControllerDelegate

- (void)contentListViewController:(ContentListViewController*)contentListViewController didFinishWithInfo:(NSDictionary*)info;

@end
