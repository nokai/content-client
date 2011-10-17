//
//  ContentItem.m
//  content-client
//
//  Created by Brian Pfeil on 4/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ContentItem.h"
#import "Utl.h"
#import "Constants.h"
#import "Settings.h"

static NSString* const kCIKeyBaseDirectoryPath = @"BaseDirectoryPath";

static NSString* const kCIDefaultManifestFileName = @"manifest.json";

static NSString* const kCIKeyName = @"content_item_manifest.name";
static NSString* const kCIKeyDescription = @"content_item_manifest.description";
static NSString* const kCIKeyContentFileName = @"content_item_manifest.contentFileName";
static NSString* const kCIKeyContentItemDirectoryName = @"contentItemDirectoryName";
static NSString* const kCIKeyContentItemHash = @"md5_hash";

@interface ContentItem()
- (NSString*)lookupString:(NSString*)keyPath;
- (BOOL)contentFileExists;
@end


@implementation ContentItem

#pragma mark init

- (id)init {
	if (self = [super init]) {
		// init
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary*)dict {
	if (self = [self init]) {
		_dict = [dict retain];
	}
	return self;
}

+ (ContentItem*)contentItemFromDict:(NSDictionary*)dict {
	ContentItem *contentItem = [[ContentItem alloc] initWithDictionary:[dict copy]];
	return contentItem;
}

#pragma mark predicates

- (BOOL)isAvailableForDisplay {
	return [self contentFileExists];
}

- (BOOL)contentFileExists {
	NSString *applicationDocumentsDirectory = [Utl applicationDocumentsDirectory];	
	NSString *contentItemDirectoryName = [self contentItemDirectoryName];	
	NSString *contentFileName = [self contentFileName];
	NSString *contentFilePath = [NSString stringWithFormat:@"%@/%@/%@/%@/%@",
                                 applicationDocumentsDirectory,
                                 [Settings stringForKeyPath:@"contentServer.contentDirectoryName"],
                                 [Settings stringForKeyPath:@"contentServer.ContentItemsDirectoryName"],
                                 contentItemDirectoryName,
                                 contentFileName];
	return [[NSFileManager defaultManager] fileExistsAtPath:contentFilePath];	
}

#pragma mark helpers

- (NSString*)lookupString:(NSString*)keyPath {
	return [_dict valueForKeyPath:keyPath];	
}

#pragma mark properties

- (NSString*)name {
	return [self lookupString:kCIKeyName];
}

- (NSString*)contentItemDescription {
	return [self lookupString:kCIKeyDescription];
}

- (NSString*)contentFileName {
	return [self lookupString:kCIKeyContentFileName];
}

- (NSString*)contentItemDirectoryName {
	//return [self lookupString:kCIKeyContentItemDirectoryName];
    return [self lookupString:kCIKeyContentItemHash];
}

- (void)dealloc {
	[_dict release];
	[super dealloc];
}

@end
