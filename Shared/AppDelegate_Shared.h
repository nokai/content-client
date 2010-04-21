//
//  AppDelegate_Shared.h
//  content-client
//
//  Created by Brian Pfeil on 4/13/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ContentPlayerViewController.h"

@interface AppDelegate_Shared : NSObject <UIApplicationDelegate, UIWebViewDelegate> {
    
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    
    UIWindow *window;
	ContentPlayerViewController *contentPlayerViewController;
	
	
	UIWebView *webView;
	
	NSMutableData *receivedData;
	NSString *suggestedFilename;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ContentPlayerViewController *contentPlayerViewController;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (NSString *)applicationDocumentsDirectory;
- (void)displayContentPlayer;
- (IBAction)loadWebContent;

@end

