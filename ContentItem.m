//
//  ContentItem.m
//  content-client
//
//  Created by Brian Pfeil on 4/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ContentItem.h"

static NSString* const kCIKeyBaseDirectoryPath = @"BaseDirectoryPath";

static NSString* const kCIDefaultManifestFileName = @"manifest.json";

static NSString* const kCIKeyName = @"content_item_manifest.name";
static NSString* const kCIKeyContentFileName = @"content_item_manifest.contentFileName";
static NSString* const kCIKeyContentItemDirectoryName = @"contentItemDirectoryName";

@interface ContentItem()
- (NSString*)lookupString:(NSString*)keyPath;
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

- (id)initWithBaseDirectoryPath:(NSString*)baseDirectoryPath {
	if ([self init]) {
		[self setValue:baseDirectoryPath forKey:kCIKeyBaseDirectoryPath];
		NSString *manifestFilePath = [baseDirectoryPath stringByAppendingPathComponent:kCIDefaultManifestFileName];
		NSError *err;
		NSString *manifestFileContents = [NSString stringWithContentsOfFile:manifestFilePath encoding:NSASCIIStringEncoding error:&err];
		[self addEntriesFromDictionary:[manifestFileContents JSONValue]];
	}
	return self;
}

+ (ContentItem*)contentItemFromDict:(NSDictionary*)dict {
	ContentItem *contentItem = [[ContentItem alloc] initWithDictionary:[dict copy]];
	return contentItem;
}

#pragma mark helpers

- (NSString*)lookupString:(NSString*)keyPath {
	return [_dict valueForKeyPath:keyPath];	
}

#pragma mark properties

- (NSString*)name {
	return [self lookupString:kCIKeyName];
}

- (NSString*)contentFileName {
	return [self lookupString:kCIKeyContentFileName];
}

- (NSString*)contentItemDirectoryName {
	return [self lookupString:kCIKeyContentItemDirectoryName];	
}

- (void)dealloc {
	[_dict release];
	[super dealloc];
}

@end
