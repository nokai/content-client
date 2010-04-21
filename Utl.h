//
//  Utl.h
//  MobilePharma
//
//  Created by Brian Pfeil on 3/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Utl : NSObject {

}

+ (NSString *)applicationDocumentsDirectory;
+ (BOOL)deleteFromDocumentsDirectoryWithFileName:(NSString*)fileName;
+ (NSString*)documentsDirectoryFilePathFromFileName:(NSString*)fileName;
+ (BOOL)writeToDocumentsDirectory:(id)data fileName:(NSString*)fileName;

+ (BOOL)createDirectoryAtPath:(NSString*)path;
+ (BOOL)writeToFile:(id)data path:(NSString*)path; 
+ (BOOL)deleteFile:(NSString*)path;

+ (id)propertyListFromFile:(NSString*)path;
+ (id)propertyListFromDocumentsDirectoryWithFileName:(NSString*)fileName;

+ (NSString*)telURLStringFromString:(NSString*)aPhoneNumber;
+ (NSString*)emailURLStringFromString:(NSString*)anEmailAddress;

+(BOOL)isDate:(NSDate*)firstDate onSameDayAsDate:(NSDate*)secondDate;

@end
