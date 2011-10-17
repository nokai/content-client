//
//  BPMetadata.m
//  text
//
//  Created by Brian Pfeil on 9/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Settings.h"

static Settings* metadataSharedInstance = nil;

@implementation Settings

@synthesize dict;

+ (Settings*)sharedInstance {
	if (metadataSharedInstance == nil) {
		metadataSharedInstance = [[[self class] alloc] init];
	}
	return metadataSharedInstance;
}

+ (NSString*)stringForKeyPath:(NSString*)path {
    Settings* md = [[self class]  sharedInstance];
    return [md stringForKeyPath:path];
}

- (NSString*)stringForKeyPath:(NSString*)path {
    NSDictionary *d = [self metadata];
    return [d valueForKeyPath:path];
}

+ (NSString*)string:(NSString*)name {
    Settings* md = [[self class]  sharedInstance];
    return [md string:name];
}

- (NSString*)string:(NSString*)name {
    NSDictionary *d = [self metadata];
    return [d valueForKeyPath:[NSString stringWithFormat:@"strings.%@", name]];
}

- (NSDictionary*)metadata {
	NSString* path = [[NSBundle mainBundle] pathForResource:@"metadata" ofType:@"json"];
	NSError* err;
	NSString* metadataAsJSONString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
	return [metadataAsJSONString JSONValue];
}

- (NSDictionary*)dict {
	return [self metadata];
}

- (NSDictionary*)metadataForPropertyName:(NSString*)propertyName {
	return [[self metadata] valueForKeyPath:propertyName];
}


@end
