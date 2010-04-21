//
//  DownloadManager.m
//  content-client
//
//  Created by Brian Pfeil on 4/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DownloadManager.h"

static DownloadManager *defaultDownloadManager = nil;

@implementation DownloadManager

@synthesize delegate, operationQueue, downloadItems;

- (id)init {
	if (self = [super init]) {
		delegate = nil;
		operationQueue = nil;
		downloadItems = nil;
	}
	return self;
}

- (void) dealloc {
	[delegate release];
	[operationQueue release];
	[downloadItems release];
	[super dealloc];
}


+ (DownloadManager*)defaultDownloadManager {
	if (defaultDownloadManager == nil) {
		defaultDownloadManager = [[DownloadManager alloc] init];
	}
	return defaultDownloadManager;
}

- (BOOL)downloadFileAtURL:(NSURL*)url toDestinationFilePath:(NSString*)destinationFilePath error:(NSError**)err {
	DownloadItem *downloadItem = [[DownloadItem alloc] initWithURL:url destinationFilePath:destinationFilePath];
	downloadItem.delegate = self;
	[downloadItems addObject:downloadItem];

	if (operationQueue == nil) {
		self.operationQueue = [[NSOperationQueue alloc] init];
	}

	if (downloadItems == nil) {
		self.downloadItems = [[NSMutableArray alloc] init];
	}
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:downloadItem selector:@selector(download:) object:self];
								  
	[operationQueue addOperation:op];

	return YES;
}

- (void)downloadItemDidFinishLoading:(DownloadItem*)downloadItem {
}

- (void)downloadItem:(DownloadItem*)downloadItem didFailWithError:(NSError**)error {
}


@end
