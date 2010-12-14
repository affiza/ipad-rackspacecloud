//
//  ASICloudServersImageRequest.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/8/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import "ASICloudServersImageRequest.h"
#import "ASICloudServersImageXMLParserDelegate.h"
#import "ASICloudServersImage.h"

static NSArray *images = nil;
static NSMutableDictionary *imageGroups = nil;
static NSMutableDictionary *imageDict = nil;
static NSRecursiveLock *accessDetailsLock = nil;

@implementation ASICloudServersImageRequest

@synthesize xmlParserDelegate;

+ (void)initialize {
    imageGroups = [[NSMutableDictionary alloc] initWithCapacity:10];
    [imageGroups setValue:[[NSMutableArray alloc] init] forKey:@"Arch"];
    [imageGroups setValue:[[NSMutableArray alloc] init] forKey:@"CentOS"];
    [imageGroups setValue:[[NSMutableArray alloc] init] forKey:@"Debian"];
    [imageGroups setValue:[[NSMutableArray alloc] init] forKey:@"Fedora"];
    [imageGroups setValue:[[NSMutableArray alloc] init] forKey:@"Gentoo"];
    [imageGroups setValue:[[NSMutableArray alloc] init] forKey:@"Oracle"];
    [imageGroups setValue:[[NSMutableArray alloc] init] forKey:@"Red Hat Enterprise Linux"];
    [imageGroups setValue:[[NSMutableArray alloc] init] forKey:@"Ubuntu"];
    [imageGroups setValue:[[NSMutableArray alloc] init] forKey:@"Windows Server"];
    [imageGroups setValue:[[NSMutableArray alloc] init] forKey:@"Custom Images"];
    
}

+ (void)placeImageInGroup:(ASICloudServersImage *)image {
    NSString *name = image.name;
    NSMutableArray *group;
    
    if ([name hasPrefix:@"Arch"]) {
        group = [imageGroups valueForKey:@"Arch"];
    } else if ([name hasPrefix:@"CentOS"]) {
        group = [imageGroups valueForKey:@"CentOS"];
    } else if ([name hasPrefix:@"Debian"]) {
        group = [imageGroups valueForKey:@"Debian"];
    } else if ([name hasPrefix:@"Fedora"]) {
        group = [imageGroups valueForKey:@"Fedora"];
    } else if ([name hasPrefix:@"Oracle"]) {
        group = [imageGroups valueForKey:@"Oracle"];
    } else if ([name hasPrefix:@"Red Hat"]) {
        group = [imageGroups valueForKey:@"Red Hat Enterprise Linux"];
    } else if ([name hasPrefix:@"Ubuntu"]) {
        group = [imageGroups valueForKey:@"Ubuntu"];
    } else if ([name hasPrefix:@"Windows"]) {
        group = [imageGroups valueForKey:@"Windows Server"];
    } else if ([name hasPrefix:@"Gentoo"]) {
        group = [imageGroups valueForKey:@"Gentoo"];
    } else {
        group = [imageGroups valueForKey:@"Custom Images"];
    }
    
    [group addObject:image];
}

+ (NSArray *)images {
	return images;
}

+ (NSDictionary *)imageGroups {
    return imageGroups;
}

+ (void)setImages:(NSArray *)newImages
{
	[accessDetailsLock lock];
	[images release];
	[imageDict release];
	images = [newImages retain];
	imageDict = [[NSMutableDictionary alloc] initWithCapacity:[newImages count]];
    
	for (int i = 0; i < [images count]; i++) {
		ASICloudServersImage *image = [images objectAtIndex:i];
		if ([image.status isEqualToString:@"ACTIVE"]) {
			[imageDict setObject:image forKey:[NSNumber numberWithInt:image.imageId]];
            [self placeImageInGroup:image];
		}
	}
	[accessDetailsLock unlock];
}

+ (ASICloudServersImage *)imageForId:(NSUInteger)imageId {
	return [imageDict objectForKey:[NSNumber numberWithInt:imageId]];
}

#pragma mark -
#pragma mark GET - Image List

+ (id)listRequest {
	NSString *urlString = [NSString stringWithFormat:@"%@/images/detail.xml", [ASICloudFilesRequest serverManagementURL]];
	ASICloudServersImageRequest *request = [[[ASICloudServersImageRequest alloc] initWithURL:[NSURL URLWithString:urlString]] autorelease];
	[request setRequestMethod:@"GET"];
	[request addRequestHeader:@"X-Auth-Token" value:[ASICloudServersImageRequest authToken]];
	return request;
}

- (NSArray *)images {
	if (xmlParserDelegate.imageObjects) {
		return xmlParserDelegate.imageObjects;
	}
	
	NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:[self responseData]] autorelease];
	if (xmlParserDelegate == nil) {
		xmlParserDelegate = [[ASICloudServersImageXMLParserDelegate alloc] init];
	}
	
	[parser setDelegate:xmlParserDelegate];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	
	return xmlParserDelegate.imageObjects;
}

- (void)dealloc {
	[xmlParserDelegate release];
	[super dealloc];
}



@end
