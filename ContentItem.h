//
//  ContentItem.h
//  content-client
//
//  Created by Brian Pfeil on 4/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ContentItem : NSObject {
	NSMutableDictionary *_dict;
}

+ (ContentItem*)contentItemFromDict:(NSDictionary*)dict;

- (id)initWithBaseDirectoryPath:(NSString*)baseDirectoryPath;

- (NSString*)name;
- (NSString*)contentFileName;
- (NSString*)contentItemDirectoryName;

@end
