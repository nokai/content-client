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

- (BOOL)downloadFileAtURL:(NSURL*)url toDestinationFilePath:(NSString*)destinationFilePath unpackToDirectoryPath:(NSString*)unpackToDirectoryPath error:(NSError**)err {
	if (downloadItems == nil) {
		self.downloadItems = [[NSMutableArray alloc] init];
	}
	
	DownloadItem *downloadItem = [[DownloadItem alloc] initWithURL:url destinationFilePath:destinationFilePath unpackToDirectoryPath:unpackToDirectoryPath];
	downloadItem.delegate = self;	
	[downloadItems addObject:downloadItem];
	[downloadItem download:self];

	
	/*
	if (operationQueue == nil) {
		self.operationQueue = [[NSOperationQueue alloc] init];
	}
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:downloadItem selector:@selector(download:) object:self];
	[operationQueue addOperation:op];
	[operationQueue setSuspended:NO];
	*/

	return YES;
}

- (void)downloadItemDidFinishLoading:(DownloadItem*)downloadItem {
	[downloadItems removeObject:downloadItem];
}

- (void)downloadItem:(DownloadItem*)downloadItem didFailWithError:(NSError**)error {
}


@end
