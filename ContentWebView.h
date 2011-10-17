//
//  ContentWebView.h
//  content-client
//
//  Created by Brian Pfeil on 4/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ContentWebView : UIWebView {

}

- (void)orientationChanged;

- (void)setContentData:(id)data;
- (id)getContentData;

@end
