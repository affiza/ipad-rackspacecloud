//
//  ValidationKeyViewController.m
//  OpenStack
//
//  Created by Michael Mayo on 8/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ValidationKeyViewController.h"
#import "SettingsViewController.h"


@implementation ValidationKeyViewController

@synthesize settingsViewController;

#pragma mark -
#pragma mark Settings

- (void)loadSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"chef_endpoint"]) {
        [defaults setObject:@"" forKey:@"chef_endpoint"];
    }
    if (![defaults objectForKey:@"chef_validation_key"]) {
        [defaults setObject:@"" forKey:@"chef_validation_key"];
    }
    [defaults synchronize];
    
    organization = [defaults objectForKey:@"chef_endpoint"];
    usingOpscodePlatform = ![defaults boolForKey:@"chef_using_chef_server"];
    validationKey = [defaults objectForKey:@"chef_validation_key"];
    
}

- (void)updateSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //[defaults setObject:endPointString forKey:@"chef_endpoint"];
    //[defaults setBool:YES forKey:@"chef_integration_enabled"];
    //[defaults setBool:!usingOpscodePlatform forKey:@"chef_using_chef_server"];
    [defaults setObject:textView.text forKey:@"chef_validation_key"];
    [defaults synchronize];
}

#pragma mark -
#pragma mark Text View

- (void)loadTextView {
    CGRect rect = CGRectMake(40.0, 12.0, 459.0, 260.0);
    textView = [[UITextView alloc] initWithFrame:rect]; // TODO: size this
    
    textView.editable = YES;
    textView.backgroundColor = [UIColor clearColor];
    textView.font = [UIFont fontWithName:@"Courier" size:11.0];
    
    // TODO: use file sharing to load the validator key too
    // TODO: perhaps use file sharing to load file injecting files other than chef
    
    textView.text = validationKey;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSettings];
    [self loadTextView];
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

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 282.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Chef Validation Key";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (usingOpscodePlatform) {
        return [NSString stringWithFormat:@"To communicate with the Opscode Platform, you must provide your validator key.  The validator key is inside the %@-validator.pem file you received when you signed up for the Opscode Platform.", organization];
    } else {
        return @"To communicate with your Chef server, you must provide your validator key.  The validator key is probably in your validation.pem file.";
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell addSubview:textView];
    }
    
    // Configure the cell...
    //cell.textLabel.text = validationKey;
    
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
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}


#pragma mark -
#pragma mark Button Handlers

-(void)cancelButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:3]; // TODO: use constants
    [self.settingsViewController.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)saveButtonPressed:(id)sender {
    [self updateSettings];
    [self dismissModalViewControllerAnimated:YES];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:3]; // TODO: use constants
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
    [settingsViewController release];
    [textView release];
    [super dealloc];
}


@end

