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

static ContentManager *defaultContentManager = nil;

@interface ContentManager()
- (NSString*)contentServerHostname;
- (NSString*)contentServerBaseURL;
- (NSString*)contentServerRelativeBasePath;
- (NSString*)contentServerPort;
- (BOOL)initDirectoryStructure;
- (BOOL)loadLocalData;
- (NSString*)baseContentDirectoryPath;
- (NSString*)contentArchiveDirectoryPath;
- (NSString*)contentDirectoryPath;
- (NSString*)contentItemArchiveFilePathFromFileName:(NSString*)contentItemArchiveFileName;
- (BOOL)contentItemArchiveFileExists:(NSString*)contentItemArchiveFileName;
- (NSArray*)contentItemDirectoryNames;
- (NSDictionary*)downloadContentManifest;
- (NSDictionary*)localContentManifest;
- (BOOL)shouldDownloadContentItemArchive:(NSString*)contentItemArchiveFileName;
- (BOOL)isConnected;
- (BOOL)downloadContentItemArchive:(NSDictionary*)contentItemMetaData;
- (NSString*)contentManifestFilePath;
- (NSString*)contentManifesFileContents;
- (NSString*)contentManifestHashFilePath;
- (NSString*)contentManifestHashFileContents;
- (BOOL)unpackContentItemArchive:(NSString*)contentItemArchiveFilePath toDirectoryPath:(NSString*)directoryPath;
- (BOOL)localContentManifestFileExists;
@end

@implementation ContentManager

@synthesize downloadManager, contentManifest;

#pragma mark inits

- (id)init {
	if ([super init]) {
		// init code here
		contentManifest = nil;
		_contentServerReachability = nil;
		downloadManager = nil;
		[self initDirectoryStructure];
		[self loadLocalData];
	}
	return self;
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
	return kCMDefaultContentServerHostname;
}

- (NSString*)contentServerPort {
	return kCMDefaultContentServerPort;
}

- (NSString*)contentServerRelativeBasePath {
	return kCMDefaultContentServerRelativeBasePath;
}

- (NSString*)contentServerBaseURL {
	return [NSString stringWithFormat:@"http://%@:%@/%@", [self contentServerHostname], [self contentServerPort], [self contentServerRelativeBasePath]];
}

#pragma mark paths

- (NSString*)baseContentDirectoryPath {
	NSString *applicationDocumentsDirectory = [Utl applicationDocumentsDirectory];
	return [applicationDocumentsDirectory stringByAppendingPathComponent:kCMBaseContentDirectoryName];
}

- (NSString*)contentArchiveDirectoryPath {
	return [[self baseContentDirectoryPath] stringByAppendingPathComponent:kCMDefaultContentArchivesDirectoryName];
}

- (NSString*)contentDirectoryPath {
	return [[self baseContentDirectoryPath] stringByAppendingPathComponent:kCMDefaultContentItemsDirectoryName];	
}

- (NSString*)contentManifestFilePath {
	return [[self baseContentDirectoryPath] stringByAppendingPathComponent:kCMDefaultContentManifestName];
}

- (NSString*)contentManifestHashFileName {
	return kCMDefaultContentManifestHashFileName;
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

- (NSDictionary*)downloadContentManifest {
	NSString *contentManifestURL = [NSString stringWithFormat:@"%@/%@", [self contentServerBaseURL], kCMDefaultContentManifestName];
	NSError *err;	
	NSString *_contentManifest = [NSString stringWithContentsOfURL:[NSURL URLWithString:contentManifestURL] encoding:NSUTF8StringEncoding error:&err];

	// save manifest locally
	NSError *err2;
	[_contentManifest writeToFile:[self contentManifestFilePath] atomically:NO encoding:NSUTF8StringEncoding error:&err2];
	[self loadLocalData];
	
	return [_contentManifest JSONValue];
}

- (BOOL)updateContentManifestHashFile:(BOOL*)changed {
	NSString *contentManifestHashFileURLString = [NSString stringWithFormat:@"%@/%@", [self contentServerBaseURL], [self contentManifestHashFileName]];
	NSURL *contentManifestHashFileURL = [NSURL URLWithString:contentManifestHashFileURLString];
	NSError *err;
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

- (BOOL)downloadContentItemArchive:(NSDictionary*)contentItemMetaData {
	NSString *contentItemArchiveFileName = [contentItemMetaData valueForKey:kCMKeyContentItemArchiveFileName];
	NSString *contentArchivesDirName = [contentManifest valueForKey:kCMKeyContentArchivesDirName];
	NSString *contentItemArchiveURLString = [NSString stringWithFormat:@"%@/%@/%@", [self contentServerBaseURL], contentArchivesDirName, contentItemArchiveFileName];
	NSURL *contentItemArchiveURL = [NSURL URLWithString:contentItemArchiveURLString];
	NSData *contentItemArchiveData = [NSData dataWithContentsOfURL:contentItemArchiveURL];
	NSString *contentItemArchiveFilePath = [[self contentArchiveDirectoryPath] stringByAppendingPathComponent:contentItemArchiveFileName];
	
	if (downloadManager == nil) {
		self.downloadManager = [[DownloadManager alloc] init];
		downloadManager.delegate = self;
	}
	
	//[downloadManager downloadFileAtURL:contentItemArchiveURL toDestinationFilePath:contentItemArchiveFilePath error:&err];
	
	BOOL createdFile = [[NSFileManager defaultManager] createFileAtPath:contentItemArchiveFilePath contents:contentItemArchiveData attributes:nil];
	
	if (createdFile) {
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
		
	} else {
		return NO;
	}
	
}

- (BOOL)sync:(NSError**)err {
	
	// check connectivity
	if (![self isConnected]) {
		if (*err) {
			*err = nil;
		}
		return NO;
	}	
	
	BOOL remoteContentManifestHashFileChanged;
	BOOL updateSuccess = [self updateContentManifestHashFile:&remoteContentManifestHashFileChanged];
	
	if (!updateSuccess) {
		//*err = [NSError errorWithDomain:<#(NSString *)domain#> code:<#(NSInteger)code#> userInfo:<#(NSDictionary *)dict#> 
		return NO;
	}
	
	if (updateSuccess && !remoteContentManifestHashFileChanged) {
		return YES;
	}
	
	if (updateSuccess && remoteContentManifestHashFileChanged) {
		if ([self isConnected]) {		
			[self downloadContentManifest];
		}
	}
	
	//NSString *contentArchivesDirName = [contentManifest valueForKey:kCMKeyContentArchivesDirName];
	
	NSArray *contentItemMetaDataList = [contentManifest valueForKey:kCMKeyContentItemMetaDataList];
	for (NSDictionary *contentItemMetaData in contentItemMetaDataList) {
		//ContentItem *contentItem = [ContentItem contentItemFromDict:contentItemMetaData];
		NSString *contentItemArchiveFileName = [contentItemMetaData valueForKey:kCMKeyContentItemArchiveFileName];
		
		// check if we should download the archive
		if ([self shouldDownloadContentItemArchive:contentItemArchiveFileName]) {
			BOOL downloaded = [self downloadContentItemArchive:contentItemMetaData];
			if (!downloaded) {
			}
			NSString *directoryName = [contentItemMetaData valueForKeyPath:@"contentItemDirectoryName"];
			[self unpackContentItemArchive:[self contentItemArchiveFilePathFromFileName:contentItemArchiveFileName] toDirectoryPath:[self contentItemDirectoryPathFromContentItemDirectoryName:directoryName]];
		}
	}
	
	return NO;
}

- (BOOL)unpackContentItemArchive:(NSString*)contentItemArchiveFilePath toDirectoryPath:(NSString*)directoryPath {
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

#pragma mark cleanup

- (void)dealloc {
	[contentManifest release];
	[_contentServerReachability release];
	[downloadManager release];
	[super dealloc];
}


@end
