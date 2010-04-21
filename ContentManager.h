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

static NSString* const kCMDefaultContentServerHostname = @"localhost";
static NSString* const kCMDefaultContentServerPort = @"8087";
static NSString* const kCMDefaultContentServerRelativeBasePath = @"content";
static NSString* const kCMDefaultContentManifestName = @"manifest.json";
static NSString* const kCMDefaultContentManifestHashFileName = @"manifest.fingerprint";
static NSString* const kCMBaseContentDirectoryName = @"content";
static NSString* const kCMDefaultContentArchivesDirectoryName = @"content_archives";
static NSString* const kCMDefaultContentItemsDirectoryName = @"content_items";
static NSString* const kCMKeyContentArchivesDirName = @"content_archives_dir_name";
static NSString* const kCMKeyContentItemMetaDataList = @"content_item_metadata_list";
static NSString* const kCMKeyContentItemArchiveFileName = @"content_item_archive_file_name";
static NSString* const kCMKeyContentItems = @"contentItems";


@interface ContentManager : NSObject {
	NSDictionary *contentManifest;	
	Reachability *_contentServerReachability;
	DownloadManager *downloadManager;
}

@property (nonatomic, retain) NSDictionary *contentManifest;
@property (nonatomic, retain) DownloadManager *downloadManager;

+ (ContentManager*)defaultContentManager;

- (BOOL)isLocalContentAvailable;
- (BOOL)canSync;
- (BOOL)sync:(NSError**)err;

@end
