//
//  ValidationKeyViewController.h
//  OpenStack
//
//  Created by Michael Mayo on 8/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingsViewController;

@interface ValidationKeyViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    SettingsViewController *settingsViewController;
    BOOL usingOpscodePlatform;
    NSString *organization;
    NSString *validationKey;
    UITextView *textView;
}

@property (nonatomic, retain) SettingsViewController *settingsViewController;

-(void)cancelButtonPressed:(id)sender;
-(void)saveButtonPressed:(id)sender;

@end
