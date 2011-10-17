//
//  ContentWebView.m
//  content-client
//
//  Created by Brian Pfeil on 4/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ContentWebView.h"

@interface ContentWebView()
- (NSString*)stringByEvaluatingJavaScriptFunction:(NSString*)functionName withArgument:(id)argument;
@end


@implementation ContentWebView

- (NSString*)stringByEvaluatingJavaScriptFunction:(NSString*)functionName withArgument:(id)argument {
	NSString *argumentStringRepresentation = (argument == nil) ? @"" : [argument JSONRepresentation];
	NSString *javaScriptCode = [NSString stringWithFormat:@"(function() { %@(%@); })();", functionName, argumentStringRepresentation];
	// only execute javascript code if we are done loading
	if (!self.loading) {
		return [self stringByEvaluatingJavaScriptFromString:javaScriptCode];			
	} else {
		[NSException raise:@"Execute javascript code before the page has finished loading" format:@"Trying to execute javascript code before the page has finished loading"];
	}
	return nil;
}

- (void)orientationChanged {
	[self stringByEvaluatingJavaScriptFunction:@"app.orientationChanged" withArgument:nil];
}

- (void)setContentData:(id)data {
	[self stringByEvaluatingJavaScriptFunction:@"app.setContentData" withArgument:data];
}

- (id)getContentData {
	NSString *contentDataAsJSONString = [self stringByEvaluatingJavaScriptFunction:@"app.getContentDataAsJSONString" withArgument:nil];
	return [contentDataAsJSONString JSONValue];
}

@end
