//
//  AppDelegate_Pad.m
//  content-client
//
//  Created by Brian Pfeil on 4/13/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "AppDelegate_Pad.h"

@implementation AppDelegate_Pad


#pragma mark -
#pragma mark Application delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
    // Override point for customization after application launch
	[self displayContentPlayer];	
    [window makeKeyAndVisible];
	/*
	[window setNeedsLayout];	
	[window setNeedsDisplay];
	UIView *view = [window.subviews objectAtIndex:0];
	[view setNeedsDisplay];
	[view setNeedsLayout];
	*/
	
	return YES;
}


/**
 Superclass implementation saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	[super applicationWillTerminate:application];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
	[super dealloc];
}


@end

