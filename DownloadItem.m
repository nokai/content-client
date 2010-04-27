//
//  DownloadItem.m
//  content-client
//
//  Created by Brian Pfeil on 4/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DownloadItem.h"
#import "Utl.h"
#import "ZipArchive.h"

@interface DownloadItem()
- (BOOL)unpackArchive:(NSString*)contentItemArchiveFilePath toDirectoryPath:(NSString*)directoryPath;
@end


@implementation DownloadItem

@synthesize delegate, url, destinationFilePath, tempFilePath, unpackToDirectoryPath, suggestedFilename, receivedData, fileHandle;

- (id)init {
	if (self = [super init]) {
		// init
	}
	return self;
}

- (id)initWithURL:(NSURL*)_url destinationFilePath:(NSString*)_destinationFilePath unpackToDirectoryPath:(NSString*)unpackToDirectoryPath {
	[self init];
	self.url = _url;
	self.destinationFilePath = _destinationFilePath;
	self.unpackToDirectoryPath = unpackToDirectoryPath;
	self.tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"tmp"]];
	return self;
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
	
	SEL selDownloadItemDidFinishLoading = @selector(downloadItemDidFinishLoading:);
	SEL selDownloadItemDidFailWithError = @selector(downloadItem:didFailWithError:);	
	
	BOOL moveSuccessful = [[NSFileManager defaultManager] moveItemAtPath:tempFilePath toPath:destinationFilePath error:&err];
	
	if (moveSuccessful) {
		BOOL unpackSuccessful = [self unpackArchive:destinationFilePath toDirectoryPath:unpackToDirectoryPath];
		
		if (unpackSuccessful) {
			if (delegate && [delegate respondsToSelector:selDownloadItemDidFinishLoading]) {
				[delegate performSelector:selDownloadItemDidFinishLoading withObject:self];
				return;
			}
		}
		
	}
	
	// failure case
	if (delegate && [delegate respondsToSelector:selDownloadItemDidFailWithError]) {
		[delegate performSelector:selDownloadItemDidFailWithError withObject:self withObject:nil];
	}		

}

- (BOOL)unpackArchive:(NSString*)contentItemArchiveFilePath toDirectoryPath:(NSString*)directoryPath {
	[Utl createDirectoryAtPath:directoryPath];
	
	ZipArchive *za = [[ZipArchive alloc] init];
	if ([za UnzipOpenFile:contentItemArchiveFilePath]) {
		BOOL ret = [za UnzipFileTo:directoryPath overWrite:YES];
		if (NO == ret){} [za UnzipCloseFile];
	}
	[za release];
	
	NSString *symbolicLinkPath = [directoryPath stringByAppendingPathComponent:@"support"];
	NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	NSString *symbolicLinkDestinationPath = [NSString stringWithFormat:@"%@/%@", bundlePath, @"www/contentapp"];
	
	NSError *err;
	BOOL symbolicLinkCreated = [[NSFileManager defaultManager] createSymbolicLinkAtPath:symbolicLinkPath withDestinationPath:symbolicLinkDestinationPath error:&err];
	return YES;
}

- (void) dealloc {
	[super dealloc];
}


@end
