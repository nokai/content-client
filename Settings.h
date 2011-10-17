//
//  BPMetadata.h
//  text
//
//  Created by Brian Pfeil on 9/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Settings : NSObject {

}

+ (Settings*)sharedInstance;
+ (NSString*)stringForKeyPath:(NSString*)path;
- (NSString*)stringForKeyPath:(NSString*)path;
- (NSDictionary*)metadata;
- (NSDictionary*)metadataForPropertyName:(NSString*)propertyName;

+ (NSString*)string:(NSString*)name;
- (NSString*)string:(NSString*)name;

@property (nonatomic, readonly) NSDictionary* dict;

@end
