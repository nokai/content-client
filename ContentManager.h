//
//  ContentManager.h
//  content-client
//
//  Created by Brian Pfeil on 4/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "DownloadManager.h"
#import "Constants.h"
#import "ContentItem.h"
#import "ASIHTTPRequest.h"

typedef void (^BasicBlock)(void);
typedef void (^InfoBlock)(NSDictionary *info);

@interface ContentManager : NSObject {
	NSDictionary *contentManifest;	
	Reachability *_contentServerReachability;
    BOOL _syncInProgress;
    NSMutableArray *_downloadQueue;
	DownloadManager *downloadManager;
	ASIHTTPRequest *_activeRequest;
    int _activeDownloadItemIndex;
    int _itemsToDownloadInSession;
	id delegate;
    
    InfoBlock syncStartedBlock;
}

- (void)setSyncStartedBlock:(InfoBlock)aSyncStartedBlock;

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) NSDictionary *contentManifest;
@property (nonatomic, retain) DownloadManager *downloadManager;

+ (ContentManager*)defaultContentManager;

- (NSString*)contentItemContentFilePath:(ContentItem*)contentItem;

- (BOOL)deleteAllContent;
- (BOOL)isLocalContentAvailable;
- (BOOL)canSync;
- (BOOL)sync:(NSError**)err;
- (BOOL)syncInProgress;
- (void)cancelSync;
- (int)itemsToDownloadInSession;
- (int)activeDownloadItemIndex;

- (NSString*)userid;

@end
