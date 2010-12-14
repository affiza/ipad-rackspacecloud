//
//  SettingsViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 4/8/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RackspaceCloudSplitViewDelegate.h"


@interface SettingsViewController : RackspaceCloudSplitViewDelegate <UITableViewDataSource, UITableViewDelegate> {
	IBOutlet UITableView *tableView;
	NSUserDefaults *defaults;
    UISwitch *passwordLockSwitch;
    UISwitch *chefIntegrationSwitch;
    BOOL chefIntegrationEnabled;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) UISwitch *passwordLockSwitch;
@property (nonatomic, retain) UISwitch *chefIntegrationSwitch;

@end
