//
//  ASICloudServersFile.m
//  OpenStack
//
//  Created by Michael Mayo on 8/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ASICloudServersFile.h"


@implementation ASICloudServersFile

@synthesize path, content;

- (void)dealloc {
    [path release];
    [content release];
    [super dealloc];
}

@end
