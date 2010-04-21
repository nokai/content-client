//
//  DownloadManager.h
//  content-client
//
//  Created by Brian Pfeil on 4/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadItem.h"

@interface DownloadManager : NSObject {
	id delegate;
	NSOperationQueue *operationQueue;
	NSMutableArray *downloadItems;
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) NSOperationQueue *operationQueue;
@property (nonatomic, retain) NSMutableArray *downloadItems;

+ (DownloadManager*)defaultDownloadManager;

- (BOOL)downloadFileAtURL:(NSURL*)url toDestinationFilePath:(NSString*)destinationFilePath error:(NSError**)err;

@end
