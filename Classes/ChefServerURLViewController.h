//
//  ChefServerURLViewController.h
//  OpenStack
//
//  Created by Michael Mayo on 7/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingsViewController;

@interface ChefServerURLViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    BOOL usingOpscodePlatform;
    IBOutlet UITableView *tableView;
    IBOutlet UIView *opscodeLogoView;
    UITextField *textField;
    CGRect bigRect;
    CGRect smallRect;
    NSString *endPointString;
    SettingsViewController *settingsViewController;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIView *opscodeLogoView;
@property (nonatomic, retain) SettingsViewController *settingsViewController;

-(void)cancelButtonPressed:(id)sender;
-(void)saveButtonPressed:(id)sender;

@end
