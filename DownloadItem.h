//
//  DownloadItem.h
//  content-client
//
//  Created by Brian Pfeil on 4/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DownloadItem : NSObject {
	id delegate;
	NSURL *url;
	NSString *destinationFilePath;
	NSString *tempFilePath;	
	NSString *suggestedFilename;
	NSMutableData *receivedData;
	NSFileHandle *fileHandle;
	NSString *unpackToDirectoryPath;	
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, copy) NSString *destinationFilePath;
@property (nonatomic, copy) NSString *unpackToDirectoryPath;
@property (nonatomic, copy) NSString *tempFilePath;
@property (nonatomic, copy) NSString *suggestedFilename;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSFileHandle *fileHandle;

- (id)initWithURL:(NSURL*)_url destinationFilePath:(NSString*)_destinationFilePath unpackToDirectoryPath:(NSString*)_unpackToDirectoryPath;

- (void)download:(id)sender;

@end
