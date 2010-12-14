//
//  ChefServerURLViewController.m
//  OpenStack
//
//  Created by Michael Mayo on 7/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ChefServerURLViewController.h"
#import "TextFieldCell.h"
#import "SettingsViewController.h"


#define kSections 2
#define kPlatformSection 0
#define kEndpointSection 1


@implementation ChefServerURLViewController

@synthesize tableView, opscodeLogoView, settingsViewController;

#pragma mark -
#pragma mark Settings

- (void)loadSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"chef_endpoint"]) {
        [defaults setObject:@"" forKey:@"chef_endpoint"];
    }
    [defaults synchronize];
    
    endPointString = [defaults objectForKey:@"chef_endpoint"];
    usingOpscodePlatform = ![defaults boolForKey:@"chef_using_chef_server"];
    
}

- (void)updateSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //[defaults setObject:endPointString forKey:@"chef_endpoint"];
    [defaults setObject:textField.text forKey:@"chef_endpoint"];
    [defaults setBool:YES forKey:@"chef_integration_enabled"];
    [defaults setBool:!usingOpscodePlatform forKey:@"chef_using_chef_server"];
    [defaults synchronize];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadSettings];
    tableView.scrollEnabled = NO;
    [tableView setTableHeaderView:opscodeLogoView];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    bigRect = self.tableView.frame;
    smallRect = CGRectMake(bigRect.origin.x, bigRect.origin.y, bigRect.size.width, 352.0);
}

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

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark Text Field Delegate

- (BOOL)textField:(UITextField *)aTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {    
    endPointString = [aTextField.text stringByReplacingCharactersInRange:range withString:string];
    //[self updateSettings];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.25];
	[UIView setAnimationDelegate:self];
    self.tableView.frame = smallRect;
    [self.tableView scrollToRowAtIndexPath:indexPath
                    atScrollPosition:UITableViewScrollPositionTop
                    animated:YES];
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)aTextField {
    endPointString = aTextField.text;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.25];
	[UIView setAnimationDelegate:self];
    self.tableView.frame = bigRect;
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField {
    [aTextField resignFirstResponder];
    return NO;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return kSections; // padding to make room for the opscode logo
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == kPlatformSection) {
        return 2;
    } else if (section == kEndpointSection) {
        return 1;
    } else {
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == kPlatformSection) {
        return @"How are you using Chef?";
    } else if (section == kEndpointSection) {
        if (usingOpscodePlatform) {
            return @"Opscode Organization";
        } else {
            return @"Chef Server URL";
        }
    } else {
        return @"";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == kEndpointSection) {
        return @"With Chef support enabled, you will be able to specify server roles and recipes when you create a Cloud Server.  The node will automatically install Chef and attempt to bootstrap itself.";
    } else {
        return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)aTableView platformCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"PlatformCell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    if (indexPath.row == 0) {
        cell.textLabel.text = @"I use the Opscode Platform.";
        cell.accessoryType = usingOpscodePlatform ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    } else {
        cell.textLabel.text = @"I run my own Chef server.";
        cell.accessoryType = usingOpscodePlatform ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView endpointCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"EndpointCell";
    
    //tableView.backgroundView = nil;
    
//    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
//    }
//    
//    // Configure the cell...
//    if (usingOpscodePlatform) {
//        cell.textLabel.text = @"Organization";
//        cell.detailTextLabel.text = @"greenisus";
//    } else {
//        cell.textLabel.text = @"Chef Server URL";
//    }
    
    TextFieldCell *cell = (TextFieldCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        textField = cell.textField;
        textField.delegate = self;
        textField.returnKeyType = UIReturnKeyDone;
    }
    
    // Configure the cell...
    textField.text = endPointString;
    
    return cell;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == kPlatformSection) {
        return [self tableView:aTableView platformCellForRowAtIndexPath:indexPath];
    } else {
        return [self tableView:aTableView endpointCellForRowAtIndexPath:indexPath];
    }
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

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
    
    if (indexPath.section == kPlatformSection) {
        usingOpscodePlatform = (indexPath.row == 0);        
        //[self updateSettings];
        [aTableView deselectRowAtIndexPath:indexPath animated:YES];
        [NSTimer scheduledTimerWithTimeInterval:0.4 target:aTableView selector:@selector(reloadData) userInfo:nil repeats:NO];
        
        //NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:3.5];
        //NSTimer *timer = [[NSTimer alloc] initWithFireDate:fireDate interval:3.0 target:aTableView selector:@selector(reloadData) userInfo:nil repeats:NO];
        //[timer fire];
        //[timer release];
    }
}

#pragma mark -
#pragma mark Button Handlers

-(void)cancelButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:3]; // TODO: use constants
    [self.settingsViewController.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)saveButtonPressed:(id)sender {
    [self updateSettings];
    [self dismissModalViewControllerAnimated:YES];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:3]; // TODO: use constants
    [self.settingsViewController.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    [opscodeLogoView release];
    [settingsViewController release];
    [super dealloc];
}


@end

