//
//  Base64.h
//  OpenStack
//
//  Created by Michael Mayo on 8/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Base64 : NSObject {

}

+ (NSString*) encode:(const uint8_t*) input length:(NSInteger) length;
+ (NSString*) encode:(NSData*) rawBytes;
+ (NSData*) decode:(const char*) string length:(NSInteger) inputLength;
+ (NSData*) decode:(NSString*) string;

@end
