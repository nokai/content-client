//
//  CustomerManager.m
//  content-client
//
//  Created by Brian Pfeil on 4/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CustomerManager.h"

static CustomerManager *defaultCustomerManager = nil;

@implementation CustomerManager

+ (CustomerManager*)defaultCustomerManager {
	if (defaultCustomerManager == nil) {
		defaultCustomerManager = [[CustomerManager alloc] init];
	}
	return defaultCustomerManager;
}

@end
