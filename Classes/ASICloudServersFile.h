//
//  ASICloudServersFile.h
//  OpenStack
//
//  Created by Michael Mayo on 8/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ASICloudServersFile : NSObject {
    NSString *path;
    NSString *content;
}

@property (retain) NSString *path;
@property (retain) NSString *content;

@end
