//
//  Utl.m
//  MobilePharma
//
//  Created by Brian Pfeil on 3/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Utl.h"
#import <CommonCrypto/CommonDigest.h>


@implementation Utl

+ (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (BOOL)createDirectoryAtPath:(NSString*)path {
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:path attributes:nil];
	}
	return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+(NSString*)telURLStringFromString:(NSString*)aPhoneNumber {
	NSMutableString *telURLString = [NSMutableString stringWithFormat:@"tel:%@", aPhoneNumber];
	[telURLString replaceOccurrencesOfString:@"+" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [telURLString length])];
	[telURLString replaceOccurrencesOfString:@" " withString:@"-" options:NSLiteralSearch range:NSMakeRange(0, [telURLString length])];
	return telURLString;
}

+(NSString*)emailURLStringFromString:(NSString*)anEmailAddress {
	NSMutableString *emailURLString = [NSMutableString stringWithFormat:@"mailto:%@", anEmailAddress];
	[emailURLString replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [emailURLString length])];
	return emailURLString;
}

+(BOOL)isDate:(NSDate*)firstDate onSameDayAsDate:(NSDate*)secondDate {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *firstDateComponents = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit ) fromDate:firstDate];
	NSDateComponents *secondDateComponents = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit ) fromDate:secondDate];
	
	return ([firstDateComponents year] == [secondDateComponents year]) &&
			([firstDateComponents month] == [secondDateComponents month]) &&
			([firstDateComponents day] == [secondDateComponents day]);
}

+(id)propertyListFromFile:(NSString*)path {

	id propertyListData = nil;
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
	if (fileExists) {
		NSData *theData = [[NSData alloc] initWithContentsOfFile:path];
		NSString *errorDescription;
		propertyListData = [NSPropertyListSerialization propertyListFromData:theData mutabilityOption:NSPropertyListMutableContainers format:nil errorDescription:&errorDescription];
		[theData release];
	}
	return propertyListData;
}

+(BOOL)writeToFile:(id)data path:(NSString*)path {
	return [data writeToFile:path atomically:YES];
}

+(id)propertyListFromDocumentsDirectoryWithFileName:(NSString*)fileName {
	NSString *path =[[self class] documentsDirectoryFilePathFromFileName:fileName];
	return [[self class] propertyListFromFile:path];
}

+(BOOL)deleteFile:(NSString*)path {
	NSError *error;
	return [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
}

+(BOOL)deleteFromDocumentsDirectoryWithFileName:(NSString*)fileName {
	return [[self class] deleteFile:[[self class] documentsDirectoryFilePathFromFileName:fileName]];
}

+(BOOL)writeToDocumentsDirectory:(id)data fileName:(NSString*)fileName {
	NSString *path =[[self class] documentsDirectoryFilePathFromFileName:fileName];
	return [[self class] writeToFile:data path:path];
}

+(NSString*)documentsDirectoryFilePathFromFileName:(NSString*)fileName {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
	return path;
}

+(NSString*)fileMD5:(NSString*)path
{
	NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
	if( handle== nil ) return @"ERROR GETTING FILE MD5"; // file didnt exist
	
	CC_MD5_CTX md5;
	
	CC_MD5_Init(&md5);
	
	BOOL done = NO;
	while(!done)
	{
		NSData* fileData = [handle readDataOfLength: 1024];
		CC_MD5_Update(&md5, [fileData bytes], [fileData length]);
		if( [fileData length] == 0 ) {
			done = YES;
		}
		[fileData release];
	}
	[handle closeFile];
	[handle release];
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5_Final(digest, &md5);
	NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
				   digest[0], digest[1], 
				   digest[2], digest[3],
				   digest[4], digest[5],
				   digest[6], digest[7],
				   digest[8], digest[9],
				   digest[10], digest[11],
				   digest[12], digest[13],
				   digest[14], digest[15]];
	return s;
}

@end
