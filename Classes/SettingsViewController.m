//
//  SettingsViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 4/8/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import "SettingsViewController.h"
#import "UISwitchCell.h"
#import "AccountViewController.h"
#import "SetPasswordLockViewController.h"
#import "RackspaceCloudAppDelegate.h"
#import "PasswordLockViewController.h"
#import "ChefServerURLViewController.h"
#import "ValidationKeyViewController.h"

#define kPrimaryAccountSection 0
#define kSecondaryAccountsSection 1
#define kPasswordLockSection 2
#define kChefIntegrationSection 3
#define kAPIEndpoints 4

@implementation SettingsViewController

@synthesize tableView, passwordLockSwitch, chefIntegrationSwitch;

#pragma mark -
#pragma mark Settings

- (void)loadSettings {
    defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"chef_validation_key"]) {
        [defaults setObject:@"" forKey:@"chef_validation_key"];
    }
    //    if (![defaults objectForKey:@"chef_endpoint"]) {
    //        [defaults setObject:@"" forKey:@"chef_endpoint"];
    //    }
    [defaults synchronize];
    
    chefIntegrationEnabled = [defaults boolForKey:@"chef_integration_enabled"];
    
}

- (void)updateSettings {
    //    [defaults setObject:endPointString forKey:@"chef_endpoint"];
    [defaults setBool:chefIntegrationEnabled forKey:@"chef_integration_enabled"];
    //    [defaults setBool:!usingOpscodePlatform forKey:@"chef_using_chef_server"];
    [defaults synchronize];
}

#pragma mark -
#pragma mark Utilities

- (BOOL)requiresPassword {
    RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSString *password = [defaults stringForKey:@"lock_password"];
    return app.isPasswordLocked && (password != nil) && ![password isEqualToString:@""];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self loadSettings];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}

#pragma mark -
#pragma mark Password Lock switch

- (void)persistLockSwitchValue {
    RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSLog(@"switch value: %i", !self.passwordLockSwitch.enabled);
    app.isPasswordLocked = NO;
    [defaults setObject:[NSNumber numberWithBool:!self.passwordLockSwitch.enabled] forKey:@"password_lock_enabled"];
    if (self.passwordLockSwitch.enabled) {
        [defaults setObject:@"" forKey:@"lock_password"];
    }
    [defaults synchronize];
}

- (void)passwordLockSwitchChanged {
    if ([self requiresPassword]) {
        PasswordLockViewController *vc = [[PasswordLockViewController alloc] initWithNibName:@"PasswordLockViewController" bundle:nil];
        vc.modalPresentationStyle = UIModalPresentationFormSheet;
        vc.callback = @selector(persistLockSwitchValue);
        vc.masterViewController = nil;
        vc.settingsViewController = self;
        [self presentModalViewController:vc animated:YES];
    } else {
        
        // TODO: if off, do nothing
        NSLog(@"switch value: %i", passwordLockSwitch.on);
        
        if (passwordLockSwitch.on) {
            SetPasswordLockViewController *vc = [[SetPasswordLockViewController alloc] initWithNibName:@"SetPasswordLockViewController" bundle:nil];
            vc.settingsViewController = self;
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentModalViewController:vc animated:YES];
        }
    }
}

#pragma mark -
#pragma mark Chef Integration Switch

- (void)chefIntegrationSwitchChanged {
    NSArray *indexPaths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:kChefIntegrationSection], [NSIndexPath indexPathForRow:2 inSection:kChefIntegrationSection], nil];
    chefIntegrationEnabled = chefIntegrationSwitch.on;
    if (chefIntegrationEnabled) {
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    } else {
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    }
    [self updateSettings];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == kPrimaryAccountSection) {
        return 1;
    } else if (section == kSecondaryAccountsSection) {
        NSDictionary *accounts = [defaults objectForKey:@"secondary_accounts"];
        return [accounts count] + 1;
    } else if (section == kChefIntegrationSection) {
        return chefIntegrationEnabled ? 3 : 1;
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == kPrimaryAccountSection) {
        return @"Primary Account";
    } else if (section == kSecondaryAccountsSection) {
        return @"Secondary Accounts";
    } else if (section == kAPIEndpoints) {
        return @"API Endpoints";
    } else if (section == kPasswordLockSection) {
        return @"Password Lock";
    } else if (section == kChefIntegrationSection) {
        return @"Chef Integration";
    } else {
        return @"";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == kPrimaryAccountSection) {
        return @"This is the account that will appear on the login screen of this application.";
    } else if (section == kSecondaryAccountsSection) {
        return @"To log in with a secondary account, tap the Switch User button above the Services list.";
    } else if (section == kAPIEndpoints) {
        return @"This is the base URL for communicating with the OpenStack API.";
    } else if (section == kPasswordLockSection) {
        return @"If the password lock is turned on, you will be prompted to enter the password before you are allowed to view your Cloud Servers or Object Storage containers.";
    } else if (section == kChefIntegrationSection) {
        return @"With Chef integration enabled, you will be able to launch Cloud Servers into your Chef roles.  For more information, visit opscode.com/chef";
    } else {
        return @"";
    }
}

- (UITableViewCell *)switchCell:(UITableView *)aTableView label:(NSString *)label action:(SEL)action value:(BOOL)value {
	UISwitchCell *cell = (UISwitchCell *)[aTableView dequeueReusableCellWithIdentifier:label];
	
	if (cell == nil) {
		cell = [[UISwitchCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:label delegate:self action:action value:value];
        passwordLockSwitch = cell.uiSwitch;
	}
    
    // handle orientation placement issues
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        CGRect frame = CGRectMake(574.0, 9.0, 94.0, 27.0);
        cell.uiSwitch.frame = frame;
    } else {
        CGRect frame = CGRectMake(513.0, 9.0, 94.0, 27.0);
        cell.uiSwitch.frame = frame;
    }
    
	cell.textLabel.text = label;
	
	return cell;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //self.tableView.backgroundView = nil;
    
    static NSString *CellIdentifier = @"Cell";
    static NSString *APICellIdentifier = @"APICell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.25];
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.detailTextLabel.backgroundColor = [UIColor clearColor];        
    }
    
    UITableViewCell *apiCell = [aTableView dequeueReusableCellWithIdentifier:APICellIdentifier];
    if (apiCell == nil) {
        apiCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        apiCell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.25];
		apiCell.textLabel.backgroundColor = [UIColor clearColor];
		apiCell.detailTextLabel.backgroundColor = [UIColor clearColor];        
    }
    
    
    // Configure the cell...
    cell.textLabel.text = @"Hello world.";
    
    if (indexPath.section == kPrimaryAccountSection) {
        cell.textLabel.text = [defaults stringForKey:@"username_preference"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.section == kSecondaryAccountsSection) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSDictionary *accounts = [defaults objectForKey:@"secondary_accounts"];
        NSArray *keys = [accounts keysSortedByValueUsingSelector:@selector(compare:)];
        
        if (indexPath.row < [keys count]) {
            cell.textLabel.text = [keys objectAtIndex:indexPath.row];
        } else {
            cell.textLabel.text = @"Add an account...";
        }
    } else if (indexPath.section == kPasswordLockSection) {
        NSString *password = [defaults stringForKey:@"lock_password"];
        BOOL hasPassword = (password != nil) && ![password isEqualToString:@""];
        UISwitchCell *switchCell = [self switchCell:aTableView label:@"Password Lock" action:@selector(passwordLockSwitchChanged) value:hasPassword];
        passwordLockSwitch = switchCell.uiSwitch;
        return switchCell;
    } else if (indexPath.section == kAPIEndpoints) {
        apiCell.textLabel.text = @"Object Storage";
        apiCell.detailTextLabel.text = @"https://storage.api.rackspacecloud.com";
        return apiCell;
    } else if (indexPath.section == kChefIntegrationSection) {
        if (indexPath.row == 0) {
            UISwitchCell *switchCell = [self switchCell:aTableView label:@"Chef Integration" action:@selector(chefIntegrationSwitchChanged) value:NO];
            chefIntegrationSwitch = switchCell.uiSwitch;
            chefIntegrationSwitch.on = chefIntegrationEnabled;
            return switchCell;
        } else if (indexPath.row == 1) {
            apiCell.textLabel.text = @"Chef Configuration";
            apiCell.detailTextLabel.text = @"";
            apiCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return apiCell;
        } else if (indexPath.row == 2) {
            apiCell.textLabel.text = @"Validation Key";
            apiCell.detailTextLabel.text = [defaults objectForKey:@"chef_validation_key"];
            apiCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return apiCell;
        }
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    if (indexPath.section == kChefIntegrationSection) {
        if (indexPath.row == 1) { // chef server url
            ChefServerURLViewController *vc = [[ChefServerURLViewController alloc] initWithNibName:@"ChefServerURLViewController" bundle:nil];
            vc.settingsViewController = self;
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentModalViewController:vc animated:YES];
            [vc release];
        } else if (indexPath.row == 2) { // validation key
            ValidationKeyViewController *vc = [[ValidationKeyViewController alloc] initWithNibName:@"ValidationKeyViewController" bundle:nil];
            vc.settingsViewController = self;
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentModalViewController:vc animated:YES];
            [vc release];
        }
        
    } else if (indexPath.section != 2) {
        
        AccountViewController *vc = [[AccountViewController alloc] initWithNibName:@"AccountViewController" bundle:nil];
        vc.settingsViewController = self;
        vc.primaryAccount = (indexPath.section == 0);
        
        if (indexPath.section == 1) {
            NSDictionary *accounts = [defaults objectForKey:@"secondary_accounts"];
            NSArray *keys = [accounts keysSortedByValueUsingSelector:@selector(compare:)];
            
            if (indexPath.row < [keys count]) {
                vc.originalUsername = [keys objectAtIndex:indexPath.row];
            }
        }
        
        vc.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentModalViewController:vc animated:YES];
        [vc release];
        
    }
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [tableView release];
    [passwordLockSwitch release];
    [chefIntegrationSwitch release];
    [super dealloc];
}


@end

