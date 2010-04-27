//
//  AppDelegate_Shared.m
//  content-client
//
//  Created by Brian Pfeil on 4/13/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "AppDelegate_Shared.h"
#import "JSON.h"
#import "WebViewController.h"
#import "ZipArchive.h"
#import "ContentManager.h"

@interface AppDelegate_Shared()
- (IBAction)loadWebContent;
- (void)downloadTest;
@end


@implementation AppDelegate_Shared

@synthesize window, navigationController, contentPlayerViewController, webView;

- (void)displayContentPlayer {
	
	//TODO: Remove this
	// wipe out all content
	NSError *err;
	BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[self applicationDocumentsDirectory] error:&err];
	if (!success) {
		//TODO: error code here
	}
	
	if (contentPlayerViewController == nil) {
		self.contentPlayerViewController = [[ContentPlayerViewController alloc] initWithNibName:@"ContentPlayerViewController" bundle:nil];
		contentPlayerViewController.title = @"Content Player";
		ContentManager *defaultContentManager = [ContentManager defaultContentManager];
		NSError *err;
		[defaultContentManager sync:&err];
		contentPlayerViewController.contentManager = defaultContentManager;
	}
	
	self.navigationController = [[UINavigationController alloc] initWithRootViewController:contentPlayerViewController];
	
	[window addSubview:navigationController.view];
}


- (IBAction)loadWebContent {
	
	[self downloadTest];
	
	//NSData *contents = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://localhost/video.m4v"]];
	//NSString *documentsDir = [self applicationDocumentsDirectory];
	//NSString *tempFilePath = [documentsDir stringByAppendingPathComponent:@"a.m4v"];
	//BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:documentsDir];
	//[[NSFileManager defaultManager] createFileAtPath:tempFilePath contents:contents attributes:nil];
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *bundlePath = [bundle bundlePath];
	NSString *indexPath = [bundlePath stringByAppendingPathComponent:@"index.html"];
	//[webView loadHTMLString:@"<html style='width: 100%; height: 100%; margin: 0'><body style='width: 100%; height: 100%; margin: 0'><video src='video.m4v' autoplay='true' controls='true' width='768' height='1024'>Pathophysiology of allergic rhinitis</video></body></html>" baseURL:[NSURL fileURLWithPath:bundlePath]];
	//NSString *videoPath = [bundlePath stringByAppendingPathComponent:@"video.m4v"];
	//[webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:videoPath]]];
	//[webView loadData:[NSData dataWithContentsOfFile:videoPath] MIMEType:@"video/mp4" textEncodingName:@"utf-8" baseURL:[NSURL URLWithString:bundlePath]];
	
	//[mpvc retain];
	
	//MPMoviePlayerViewController *mpvc = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:videoPath]];
	WebViewController *wvc = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
	[window addSubview:wvc.view];
	[wvc.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:indexPath]]];
	//[wvc.webView loadHTMLString:@"<html style='margin: 0; width: 100%; height: 100%;'><body onorientationchange=\"alert('hello'); \" style='margin: 0; width: 100%; height: 100%;'><video src='video.m4v' autoplay='true' controls='true' width='768' height='1004'>Pathophysiology of allergic rhinitis</video></body></html>" baseURL:[NSURL fileURLWithPath:bundlePath]];
	// var e = document.getElementsByTagName('video')[0]; e.videoWidth = (e.videoWidth == 768) ? 1004 : 768; e.videoHeight = (e.videoHeight == 768) ? 1004 : 768;
	//[wvc presentModalViewController:mpvc animated:YES];
	
	//[window addSubview:mpvc.view];
	//[mpvc.moviePlayer 
}

- (void)downloadTest {
	NSString *urlString = @"http://localhost:8088/ZipArchive.zip";
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
												cachePolicy:NSURLRequestUseProtocolCachePolicy
											timeoutInterval:60.0];
	
    // Create the connection with the request and start loading the data.
	NSURLConnection  *urlConnection = [[NSURLConnection alloc] initWithRequest:theRequest
																delegate:self];
	
	if (urlConnection) {
		receivedData = [[NSMutableData data] retain];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	suggestedFilename = [[response suggestedFilename] retain];
	[receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	NSArray *components = [suggestedFilename componentsSeparatedByString:@"."];
	NSString *baseFileName = [components objectAtIndex:0];
	
	NSString *destFilePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:suggestedFilename];	
	[suggestedFilename release];
	suggestedFilename = nil;
	
	[[NSFileManager defaultManager] createFileAtPath:destFilePath contents:receivedData attributes:nil];
	[receivedData release];
	receivedData = nil;
	
	NSString *baseExtractDirPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"extract"];	
	if (![[NSFileManager defaultManager] fileExistsAtPath:baseExtractDirPath]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:baseExtractDirPath attributes:nil];
	}
	
	NSString *extractDirPath = [baseExtractDirPath stringByAppendingPathComponent:baseFileName];
	if (![[NSFileManager defaultManager] fileExistsAtPath:extractDirPath]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:extractDirPath attributes:nil];
	}
	
	ZipArchive *za = [[ZipArchive alloc] init];
	if ([za UnzipOpenFile:destFilePath]) {
		BOOL ret = [za UnzipFileTo:extractDirPath overWrite: YES];
		if (NO == ret){} [za UnzipCloseFile];
	}
	[za release];	
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 
 Conditionalize for the current platform, or override in the platform-specific subclass if appropriate.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
        } 
    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.

 Conditionalize for the current platform, or override in the platform-specific subclass if appropriate.
*/
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"content_client.sqlite"]];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }    
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
	[window release];
	[super dealloc];
}


@end

