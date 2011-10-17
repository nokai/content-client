//
//  ContentManager.m
//  content-client
//
//  Created by Brian Pfeil on 4/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ContentManager.h"
#import "ContentItem.h"
#import "Utl.h"
#import "ZipArchive.h"
#import "Settings.h"
#import "ASIHTTPRequest.h"

static ContentManager *defaultContentManager = nil;

@interface ContentManager()
- (NSString*)contentServerHostname;
- (NSString*)contentServerBaseURL;
- (NSString*)contentServerRelativeBasePath;
- (NSString*)contentServerPort;
- (BOOL)setup;
- (BOOL)initDirectoryStructure;
- (BOOL)loadLocalData;
- (NSString*)baseContentDirectoryPath;
- (NSString*)contentArchiveDirectoryPath;
- (NSString*)contentDirectoryPath;
- (NSString*)contentItemArchiveFilePathFromFileName:(NSString*)contentItemArchiveFileName;
- (BOOL)contentItemArchiveFileExists:(NSString*)contentItemArchiveFileName;
- (NSArray*)contentItemDirectoryNames;
- (NSDictionary*)downloadContentManifest;
- (void)downloadNextContentItem;
- (BOOL)unpackArchive:(NSString*)contentItemArchiveFilePath toDirectoryPath:(NSString*)directoryPath;
- (NSDictionary*)localContentManifest;
- (BOOL)shouldDownloadContentItemArchive:(NSString*)contentItemArchiveFileName;
- (BOOL)isConnected;
- (NSString*)contentManifestFilePath;
- (NSString*)contentManifesFileContents;
- (NSString*)contentManifestHashFilePath;
- (NSString*)contentManifestHashFileContents;
- (BOOL)localContentManifestFileExists;
@end

@implementation ContentManager

@synthesize delegate, downloadManager, contentManifest;

#pragma mark inits

- (id)init {
	if ([super init]) {
		// init code here
		delegate = nil;
		contentManifest = nil;
		_contentServerReachability = nil;
        _syncInProgress = NO;
        _downloadQueue = nil;
		downloadManager = nil;
        _itemsToDownloadInSession = 0;
        _activeRequest = nil;
		[self setup];
	}
	return self;
}

- (BOOL)setup {
    return [self initDirectoryStructure] && [self loadLocalData];
}

- (BOOL)initDirectoryStructure {
	return [Utl createDirectoryAtPath:[Utl applicationDocumentsDirectory]]
		    && [Utl createDirectoryAtPath:[self baseContentDirectoryPath]]
			&& [Utl createDirectoryAtPath:[self contentArchiveDirectoryPath]]
			&& [Utl createDirectoryAtPath:[self contentDirectoryPath]];	
}

- (BOOL)loadLocalData {
	if ([self localContentManifestFileExists]) {
		self.contentManifest = [self localContentManifest];
	}

	return YES;
}

#pragma mark singleton

+ (ContentManager*)defaultContentManager {
	if (defaultContentManager == nil) {
		defaultContentManager = [[ContentManager alloc] init];
	}
	return defaultContentManager;
}

#pragma mark server variables

- (NSString*)contentServerHostname {
	//return kCMDefaultContentServerHostname;
    return [Settings stringForKeyPath:@"contentServer.hostName"];
}

- (NSString*)contentServerPort {
    return [Settings stringForKeyPath:@"contentServer.port"];
}

- (NSString*)contentServerRelativeBasePath {
	return [Settings stringForKeyPath:@"contentServer.relativeBasePath"];
}

- (NSString*)contentServerBaseURL {
	return [NSString stringWithFormat:@"%@://%@:%@/%@",
            [Settings stringForKeyPath:@"contentServer.scheme"],
            [self contentServerHostname],
            [self contentServerPort],
            [self contentServerRelativeBasePath]];
}

#pragma mark paths

- (NSString*)baseContentDirectoryPath {
	NSString *applicationDocumentsDirectory = [Utl applicationDocumentsDirectory];
	return [applicationDocumentsDirectory stringByAppendingPathComponent:[Settings stringForKeyPath:@"contentServer.contentDirectoryName"]];
}

- (NSString*)contentArchiveDirectoryPath {
	return [[self baseContentDirectoryPath] stringByAppendingPathComponent:[Settings stringForKeyPath:@"contentServer.contentArchivesDirectoryName"]];
}

- (NSString*)contentDirectoryPath {
	return [[self baseContentDirectoryPath] stringByAppendingPathComponent:[Settings stringForKeyPath:@"contentServer.ContentItemsDirectoryName"]];	
}

- (NSString*)contentManifestFilePath {
	return [[self baseContentDirectoryPath] stringByAppendingPathComponent:[Settings stringForKeyPath:@"contentServer.manifestName"]];
}

- (NSString*)contentManifestHashFileName {
	return [Settings stringForKeyPath:@"contentServer.manifestHashFileName"];
}

- (NSString*)contentItemArchiveFilePathFromFileName:(NSString*)contentItemArchiveFileName {
	NSString *contentItemArchiveFilePath = [[self contentArchiveDirectoryPath] stringByAppendingPathComponent:contentItemArchiveFileName];
	return contentItemArchiveFilePath;
}

- (NSArray*)contentItemDirectoryNames {
	NSError *err;
	return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self contentDirectoryPath] error:&err];
}

- (NSString*)contentItemDirectoryPathFromContentItemDirectoryName:(NSString*)contentItemDirectoryName {
	return [NSString stringWithFormat:@"%@/%@", [self contentDirectoryPath], contentItemDirectoryName];
}

- (NSString*)contentItemContentFilePath:(ContentItem*)contentItem {
	NSString *contentFileName = [contentItem contentFileName];
	NSString *contentItemDirectoryPath = [self contentItemDirectoryPathFromContentItemDirectoryName:[contentItem contentItemDirectoryName]];
	return [NSString stringWithFormat:@"%@/%@", contentItemDirectoryPath, contentFileName];
}

- (NSString*)completedContentItemsFilePath {
    return [[self baseContentDirectoryPath] stringByAppendingPathComponent:@"completedContentItems.json"];
}

#pragma mark accessors

- (NSDictionary*)localContentManifest {
	NSError *err;
	if ([[NSFileManager defaultManager] fileExistsAtPath:[self contentManifestFilePath]]) {
		NSString *localContentManifestContents = [NSString stringWithContentsOfFile:[self contentManifestFilePath] encoding:NSUTF8StringEncoding error:&err];
		return [localContentManifestContents JSONValue];
	} else {
		return nil;
	}	
}

- (NSString*)contentManifestHashFilePath {
	return [[self baseContentDirectoryPath] stringByAppendingPathComponent:[self contentManifestHashFileName]];
}

- (NSString*)contentManifesFileContents {
	NSError *err;
	if ([[NSFileManager defaultManager] fileExistsAtPath:[self contentManifestHashFilePath]]) {
		return [NSString stringWithContentsOfFile:[self contentManifestFilePath] encoding:NSUTF8StringEncoding error:&err];
	} else {
		return nil;
	}
}

- (NSString*)contentManifestHashFileContents {
	NSError *err;
	if ([[NSFileManager defaultManager] fileExistsAtPath:[self contentManifestHashFilePath]]) {
		return [NSString stringWithContentsOfFile:[self contentManifestHashFilePath] encoding:NSUTF8StringEncoding error:&err];
	} else {
		return nil;
	}
}

/*
- (NSDictionary*)contentMetadata {
	if (contentMetadata != nil) {
		return contentMetadata;
	}
	
	self.contentMetadata = [[NSMutableDictionary alloc] init];
	
	NSMutableArray *contentItems = [[NSMutableArray alloc] init];
	
	// build out content
	NSArray *contentItemDirectoryNames = [self contentItemDirectoryNames];
	for (NSString *contentItemDirectoryName in contentItemDirectoryNames) {
		NSString *contentItemDirectoryPath = [[self contentDirectoryPath] stringByAppendingPathComponent:contentItemDirectoryName];
		ContentItem *contentItem = [[ContentItem alloc] initWithBaseDirectoryPath:contentItemDirectoryPath];
		[contentItems addObject:contentItem];
	}
	
	[contentMetadata setValue:kCMKeyContentItems forKey:@"contentItems"];
	
	return contentMetadata;
}
*/


#pragma mark predicates

- (BOOL)localContentManifestFileExists {
	return [[NSFileManager defaultManager] fileExistsAtPath:[self contentManifestFilePath]];
}

- (BOOL)isLocalContentAvailable {
	//TODO: add more logic
	return [self localContentManifestFileExists];
}

- (BOOL)contentItemArchiveFileExists:(NSString*)contentItemArchiveFileName {
	NSString *contentItemArchiveFilePath = [self contentItemArchiveFilePathFromFileName:contentItemArchiveFileName];
	return [[NSFileManager defaultManager] fileExistsAtPath:contentItemArchiveFilePath];
}

- (BOOL)shouldDownloadContentItemArchive:(NSString*)contentItemArchiveFileName {
	return ![self contentItemArchiveFileExists:contentItemArchiveFileName];
}

- (BOOL)isConnected {
	if (_contentServerReachability == nil) {
		_contentServerReachability = [[Reachability reachabilityWithHostName:[self contentServerHostname]] retain];
	}
	
	NetworkStatus networkStatus = [_contentServerReachability currentReachabilityStatus];
	
	return networkStatus != NotReachable;
}

- (BOOL)canSync {
	return [self isConnected];
}


#pragma mark actions

- (BOOL)deleteAllContent {
    NSString *directoryPath = [self baseContentDirectoryPath];
    DLog(@"deleting all local content from %@", directoryPath);
	BOOL success = [Utl deleteFile:directoryPath];
    
    // clear completedContentItemHashes
    [[DataMgr app] setValue:[NSArray array] forKeyPath:@"completedContentItemHashes"];
    
	if (success) {
		success = [self setup];
	} else {
        //TODO: error code here
    }
    return success;
}

- (void)cancelSync {
    if (_activeRequest) {
        [_activeRequest clearDelegatesAndCancel];
    }
}

- (BOOL)sync:(NSError**)err {
    
    if (_syncInProgress) {
        return YES;
    }
	
	@synchronized(self) {
        
        _syncInProgress = YES;
        
		// check connectivity
		if (![self isConnected]) {
            DLog(@"can't reach server");
			if (*err) {
				*err = nil;
			}
            _syncInProgress = NO;
			return NO;
		}
        
        SEL selBeginContentUpdateCheck = @selector(contentManager:beginContentUpdateCheckWithInfo:);
        if (delegate != nil && [delegate respondsToSelector:selBeginContentUpdateCheck]) {
            [delegate performSelector:selBeginContentUpdateCheck withObject:self withObject:nil];
        }
        
        BOOL remoteContentManifestHashFileChanged;
        
        // get the latest content manifest from server
        BOOL updateSuccess = [self updateContentManifestHashFile:&remoteContentManifestHashFileChanged];
        
        if (!updateSuccess) {
            DLog(@"Failed to get updated content manifest file");
            //*err = [NSError errorWithDomain:<#(NSString *)domain#> code:<#(NSInteger)code#> userInfo:<#(NSDictionary *)dict#> 
            _syncInProgress = NO;
            return NO;
        }
        
        // content hasn't changed
        if (updateSuccess && !remoteContentManifestHashFileChanged) {
            DLog(@"No content changes on server");
            _syncInProgress = NO;
            return YES;
        }
        
        // content has changed
        if (updateSuccess && remoteContentManifestHashFileChanged) {
            DLog(@"Server content manifest has changed");
            if ([self isConnected]) {		
                [self downloadContentManifest];
            }
        }
        
        // build the download queue
        if (!_downloadQueue) {
            _downloadQueue = [[NSMutableArray alloc] init];
        } else  {
            [_downloadQueue removeAllObjects];
        }

        NSArray *contentItemMetaDataList = [contentManifest valueForKey:kCMKeyContentItemMetaDataList];
        for (NSDictionary *contentItemMetaData in contentItemMetaDataList) {
            NSString *contentItemArchiveFileName = [contentItemMetaData valueForKey:kCMKeyContentItemArchiveFileName];
            
            if(![self isContentItemComplete:[contentItemMetaData valueForKey:@"md5_hash"]]) {
                [_downloadQueue addObject:contentItemMetaData];
            }
            
        }
        
        _activeDownloadItemIndex = 0;
        _itemsToDownloadInSession = (_downloadQueue != nil) ? [_downloadQueue count] : 0;
        
        // start downloads
        [self downloadNextContentItem];

	}
	
	return YES;
}

- (BOOL)syncInProgress {
    return _syncInProgress;
}

- (int)itemsToDownloadInSession {
    return _itemsToDownloadInSession;
}

- (int)activeDownloadItemIndex {
    return _activeDownloadItemIndex;
}


- (BOOL)updateContentManifestHashFile:(BOOL*)changed {
	NSString *contentManifestHashFileURLString = [NSString stringWithFormat:@"%@/%@?userid=%@", [self contentServerBaseURL], [self contentManifestHashFileName], [self userid]];
	NSURL *contentManifestHashFileURL = [NSURL URLWithString:contentManifestHashFileURLString];
	NSError *err;
    DLog(@"Downloading content manifest hash file");
	NSString *remoteContentManifestHashFileContents = [NSString stringWithContentsOfURL:contentManifestHashFileURL encoding:NSUTF8StringEncoding error:&err];
	NSString *localContentManifestHashFileContents = [self contentManifestHashFileContents];
	if (![remoteContentManifestHashFileContents isEqualToString:localContentManifestHashFileContents]) {
		NSError *err;
		[remoteContentManifestHashFileContents writeToFile:[self contentManifestHashFilePath] atomically:NO encoding:NSUTF8StringEncoding error:&err];
		*changed = YES;
	} else {
		*changed = NO;		
	}
	return YES;
}

- (NSDictionary*)downloadContentManifest {
	NSString *contentManifestURL = [NSString stringWithFormat:@"%@/%@", [self contentServerBaseURL], kCMDefaultContentManifestName];
    NSString *localContentManifestFilePath = [self contentManifestFilePath];
    
    // save manifest locally
    DLog(@"Downloading content manifest from %@ and saving locally to ", contentManifestURL, localContentManifestFilePath);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:contentManifestURL]];
    [request setDownloadDestinationPath:localContentManifestFilePath];
    [request startSynchronous];

	NSError *err;
    NSString *localContentManifestContents = [NSString stringWithContentsOfFile:localContentManifestFilePath encoding:NSUTF8StringEncoding error:&err];
    
	[self loadLocalData];
	
	return [localContentManifestContents JSONValue];
}

- (BOOL)downloadContentItemArchive:(NSDictionary*)contentItemMetaData unpackToDirectoryPath:(NSString*)unpackToDirectoryPath {
	NSString *contentItemArchiveFileName = [contentItemMetaData valueForKey:kCMKeyContentItemArchiveFileName];
	NSString *contentArchivesDirName = [contentManifest valueForKey:kCMKeyContentArchivesDirName];
	NSString *contentItemArchiveURLString = [NSString stringWithFormat:@"%@/%@/%@", [self contentServerBaseURL], contentArchivesDirName, contentItemArchiveFileName];
	NSURL *contentItemArchiveURL = [NSURL URLWithString:contentItemArchiveURLString];
	//NSData *contentItemArchiveData = [NSData dataWithContentsOfURL:contentItemArchiveURL];
	NSString *contentItemArchiveFilePath = [[self contentArchiveDirectoryPath] stringByAppendingPathComponent:contentItemArchiveFileName];
	
    NSString *cacheDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *contentItemHash = [contentItemMetaData valueForKey:@"md5_hash"];
    NSString *temporaryFileDownloadPath = [cacheDirectoryPath stringByAppendingPathComponent:contentItemHash];
    
    //NSString *directoryName = [contentItemMetaData valueForKeyPath:@"contentItemDirectoryName"];
    NSString *directoryName = [contentItemMetaData valueForKeyPath:@"md5_hash"];
    NSString *contentItemDirectoryPath = [self contentItemDirectoryPathFromContentItemDirectoryName:directoryName];
    
    DLog(@"temporaryFileDownloadPath = %@", temporaryFileDownloadPath);
    DLog(@"DownloadDestinationPath = %@", contentItemArchiveFilePath);
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:contentItemArchiveURL];
    request.downloadProgressDelegate = self;
    request.showAccurateProgress = YES;
    [request setDownloadDestinationPath:contentItemArchiveFilePath];
    [request setTemporaryFileDownloadPath:temporaryFileDownloadPath];
    [request setAllowResumeForFileDownloads:YES];
    
    [request setStartedBlock:^{
        // notify download started
        SEL selStart = @selector(contentManagerDidStartContentItemDownload:withContentItemMetaData:);
        if (delegate != nil && [delegate respondsToSelector:selStart]) {
            [delegate performSelector:selStart withObject:self withObject:contentItemMetaData];
        }
    }];
    
    [request setCompletionBlock:^{
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT , 0);
        dispatch_async(queue, ^{
            BOOL unpackSuccessful = [self unpackArchive:contentItemArchiveFilePath toDirectoryPath:contentItemDirectoryPath];
            
            if (unpackSuccessful) {
                // remove archive file
                [[NSFileManager defaultManager] removeItemAtPath:contentItemArchiveFilePath error:nil];
                [self setContentItemComplete:contentItemHash];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    // notify download finished				
                    SEL selFinish = @selector(contentManagerDidFinishContentItemDownload:withContentItemMetaData:);
                    if (delegate != nil && [delegate respondsToSelector:selFinish]) {
                        [delegate performSelector:selFinish withObject:self withObject:contentItemMetaData];
                    }
                    
                    // download next content item
                    [_downloadQueue removeObjectAtIndex:0];
                    [self downloadNextContentItem];
                });
            }
        });

        
    }];
    
    [request setFailedBlock:^{
        DLog(@"download failed for %@", request.url);
        _syncInProgress = NO;
        SEL selRequestFailed = @selector(contentManager:requestFailedWithInfo:);
        if (delegate != nil && [delegate respondsToSelector:selRequestFailed]) {
            [delegate performSelector:selRequestFailed withObject:self withObject:request];
        }
        
    }];
    
    [request setBytesReceivedBlock:^(unsigned long long size, unsigned long long total) {
        DLog(@"setBytesReceivedBlock(size=%d,total=%d)", size, total);
    }];
    
    _activeRequest = request;
    [request startAsynchronous];
    
    
//	if (downloadManager == nil) {
//		self.downloadManager = [[DownloadManager alloc] init];
//		downloadManager.delegate = self;
//	}
//	
//	
//	NSError *err;
	//[downloadManager downloadFileAtURL:contentItemArchiveURL toDestinationFilePath:contentItemArchiveFilePath unpackToDirectoryPath:(NSString*)unpackToDirectoryPath error:&err];
	
	
	//BOOL createdFile = [[NSFileManager defaultManager] createFileAtPath:contentItemArchiveFilePath contents:contentItemArchiveData attributes:nil];
	
	//if (createdFile) {
		//TODO: this is broken and +Utl fileMD5 causes app crash
		/*
		NSString *remoteMD5Hash = [contentItemMetaData valueForKey:@"md5_hash"];
		NSString *localMD5Hash = [Utl fileMD5:contentItemArchiveFilePath];
		
		// check if server file contents matches the local file contents
		if (![remoteMD5Hash isEqualToString:localMD5Hash]) {
			return NO;			
		} else {
			return YES;
		}
		 */
		return YES;
		
	//} else {
	//	return NO;
	//}
	
}

- (void)setContentItemComplete:(NSString*)hash {
    DLog(@"adding hash to completedContentItemHashes");
    NSArray *completedContentItemHashes = [[DataMgr app] valueForKeyPath:@"completedContentItemHashes"];
    
    if (completedContentItemHashes == nil) {
        completedContentItemHashes = [NSArray arrayWithObject:hash];
    } else {
        completedContentItemHashes = [completedContentItemHashes arrayByAddingObject:hash];
    }
    [[DataMgr app] setValue:completedContentItemHashes forKeyPath:@"completedContentItemHashes"];
}

- (BOOL)isContentItemComplete:(NSString*)hash {
    NSArray *completedContentItemHashes = [[DataMgr app] valueForKeyPath:@"completedContentItemHashes"];
    return [completedContentItemHashes containsObject:hash];
}

- (void)setProgress:(float)newProgress {
    DLog(@"newProgress = %f", newProgress);
    SEL selProgress = @selector(contentManager:progressUpdateWithInfo:);
    if (delegate != nil && [delegate respondsToSelector:selProgress]) {
        NSDictionary *contentItemMetaData = [_downloadQueue objectAtIndex:0];
        
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:contentItemMetaData, @"contentItemMetaData",
                              [NSNumber numberWithFloat:newProgress], @"progress", nil];
        
        [delegate performSelector:selProgress withObject:self withObject:info];
    }
}

- (BOOL)unpackArchive:(NSString*)contentItemArchiveFilePath toDirectoryPath:(NSString*)directoryPath {
    DLog(@"extracting archive file %@ to directory %@", contentItemArchiveFilePath, directoryPath);
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
	if (symbolicLinkCreated) {
		;
	}
	return YES;
}

- (void)downloadNextContentItem {
    
    // nothing left to download
    if ((_downloadQueue == nil) || ([_downloadQueue count] == 0)) {
        _syncInProgress = NO;
		SEL sel = @selector(contentManagerDidFinishSyncing:);
		if (delegate != nil && [delegate respondsToSelector:sel]) {
			[delegate performSelector:sel withObject:self];
		}
        return;
    }
    
    if (_activeDownloadItemIndex == 0) {
        _activeDownloadItemIndex = 1;
    } else {
        _activeDownloadItemIndex++;
    }
    
    NSDictionary *contentItemMetaData = [_downloadQueue objectAtIndex:0];
    NSString *directoryName = [contentItemMetaData valueForKeyPath:@"contentItemDirectoryName"];

    // download and extract				
    [self downloadContentItemArchive:contentItemMetaData unpackToDirectoryPath:[self contentItemDirectoryPathFromContentItemDirectoryName:directoryName]];				
}

- (NSString*)userid {
	return [[UIDevice currentDevice] uniqueIdentifier];
}

#pragma mark -
#pragma mark blocks

- (void)setSyncStartedBlock:(InfoBlock)aSyncStartedBlock {
	[syncStartedBlock release];
	syncStartedBlock = [aSyncStartedBlock copy];
}


#pragma mark cleanup

- (void)dealloc {
	[delegate release];
	[contentManifest release];
	[_contentServerReachability release];
	[downloadManager release];
	[super dealloc];
}


@end
