//
//  AddServerViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/8/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASICloudServersServer, ServerDetailViewController;

@interface AddServerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
	UITextField *serverNameTextField;
    
	IBOutlet UISlider *slider;
    UILabel *sizeLabel;
	ASICloudServersServer *server;
	ServerDetailViewController *serverDetailViewController;
    IBOutlet UITableView *tableView;
    
    BOOL switchingImageView;
    BOOL lookingAtImages;
    NSArray *images;
    
    // chef integration
    IBOutlet UINavigationItem *navigationItem;
    BOOL chefIntegrationEnabled;
    BOOL usingOpscodePlatform;
    NSString *chefValidationKey;
    NSString *chefEndpoint;
    BOOL chefBootstrapped;
    UITextField *chefRunListTextField;
    
    // sections
    NSInteger totalSections;
    NSInteger nameSection;
    NSInteger sizeSection;
    NSInteger osSection;
    NSInteger copyPasswordSection;
    NSInteger chefSection;
    
    BOOL copyPassword;
}

@property (nonatomic, retain) ASICloudServersServer *server;
@property (nonatomic, retain) ServerDetailViewController *serverDetailViewController;
@property (nonatomic, retain) IBOutlet UINavigationItem *navigationItem;
@property (nonatomic, retain) IBOutlet UISlider *slider;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

-(void)cancelButtonPressed:(id)sender;
-(void)saveButtonPressed:(id)sender;

@end
