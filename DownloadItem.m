//
//  DownloadItem.m
//  content-client
//
//  Created by Brian Pfeil on 4/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DownloadItem.h"


@implementation DownloadItem

@synthesize delegate, url, destinationFilePath, tempFilePath, suggestedFilename, receivedData, fileHandle;

- (id)init {
	if (self = [super init]) {
		// init
	}
	return self;
}

- (id)initWithURL:(NSURL*)_url destinationFilePath:(NSString*)_destinationFilePath {
	[self init];
	self.url = _url;
	self.destinationFilePath = _destinationFilePath;
	self.tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"tmp"]];
}

- (void)download:(id)sender {
	
	// create a temp file to download to and prepare it for writing each chunk of data as it arrives
	[[NSFileManager defaultManager] createFileAtPath:tempFilePath contents:nil attributes:nil];
	fileHandle = [[NSFileHandle fileHandleForUpdatingAtPath:tempFilePath] retain];
	if (fileHandle) {
		[fileHandle seekToEndOfFile];
	}
	
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:url
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
	//[receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	if (fileHandle) {
		[fileHandle seekToEndOfFile];
		[fileHandle writeData:data];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[fileHandle closeFile];
	NSError *err;
	BOOL moveSuccessful = [[NSFileManager defaultManager] moveItemAtPath:tempFilePath toPath:destinationFilePath error:&err];
	
	if (moveSuccessful) {
		SEL sel = @selector(downloadItemDidFinishLoading:);
		if (delegate && [delegate respondsToSelector:sel]) {
			[delegate performSelector:sel withObject:self];
		}
	} else {
		SEL sel = @selector(downloadItem:didFailWithError:);
		if (delegate && [delegate respondsToSelector:sel]) {
			[delegate performSelector:sel withObject:self withObject:nil];
		}		
	}
}

- (void) dealloc {
	[super dealloc];
}


@end
