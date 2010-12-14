//
//  AddServerViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/8/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import "AddServerViewController.h"
#import "ASICloudServersServer.h"
#import "ASICloudServersImage.h"
#import "ASICloudServersFlavor.h"
#import "ASICloudServersServerRequest.h"
#import "ASICloudServersImageRequest.h"
#import "ASICloudServersFlavorRequest.h"
#import "TextFieldCell.h"
#import "UIViewController+SpinnerView.h"
#import "ServersListViewController.h"
#import "ServerDetailViewController.h"
#import "UIViewController+RackspaceCloud.h"
#import "ASICloudServersFile.h"
#import "UISwitchCell.h"

// TODO: root password for null


#define kRawCloudServer 0
#define kChefBootstrapped 1

#define kServerNameTag 55
#define kChefRunListTag 66

@implementation AddServerViewController

@synthesize server, serverDetailViewController, navigationItem, slider, tableView;

- (void)loadChefSettings {
    
    chefBootstrapped = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"chef_endpoint"]) {
        [defaults setObject:@"" forKey:@"chef_endpoint"];
    }
    if (![defaults objectForKey:@"chef_validation_key"]) {
        [defaults setObject:@"" forKey:@"chef_validation_key"];
    }
    [defaults synchronize];
    
    chefIntegrationEnabled = [defaults boolForKey:@"chef_integration_enabled"];
    chefEndpoint = [defaults objectForKey:@"chef_endpoint"];
    usingOpscodePlatform = ![defaults boolForKey:@"chef_using_chef_server"];
    chefValidationKey = [defaults objectForKey:@"chef_validation_key"];
    
    chefBootstrapped = chefIntegrationEnabled;
}

#pragma mark -
#pragma mark Slider

- (void)sliderMoved:(id)sender {
    //NSLog(@"Slider moved to %f" , slider.value);
    ASICloudServersFlavor *flavor = [[ASICloudServersFlavorRequest flavors] objectAtIndex:(int)slider.value];
    sizeLabel.text = [NSString stringWithFormat:@"%iMB RAM, %iGB Disk", flavor.ram, flavor.disk];
    server.flavorId = flavor.flavorId;
}

- (void)configureSlider {
    slider.minimumValue = 0.0;
    slider.maximumValue = [[ASICloudServersFlavorRequest flavors] count] - 1.0;
    //NSLog(@"Slider range: %f-%f", slider.minimumValue, slider.maximumValue);
    [slider addTarget:self action:@selector(sliderMoved:) forControlEvents:UIControlEventValueChanged];    
}

/*
 - (id)initWithStyle:(UITableViewStyle)style {
 // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 if (self = [super initWithStyle:style]) {
 }
 return self;
 }
 */

- (void)viewDidLoad {
    
    [self configureSlider];
    [self loadChefSettings];
	//server = [[ASICloudServersServer alloc] init];
    server = [ASICloudServersServer server];
    
    ASICloudServersFlavor *flavor = [[ASICloudServersFlavorRequest flavors] objectAtIndex:0];
    server.flavorId = flavor.flavorId;
    server.chefRunList = @"";
    
    chefSection = chefBootstrapped ? 0 : -1;
    nameSection = chefSection + 1;
    sizeSection = nameSection + 1;
    osSection = sizeSection + 1;
    copyPasswordSection = osSection + 1;
    totalSections = 5 + chefSection;
    
    lookingAtImages = NO;
    
    [super viewDidLoad];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return totalSections;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == nameSection) {
		return 1;
	} else if (section == osSection) {
        if (switchingImageView) {
            return 0;
        } else if (lookingAtImages) {
            return [images count] + 1;
        } else {
            return [[ASICloudServersImageRequest imageGroups] count];
        }
	} else if (section == sizeSection) {
		return 1; // [[ASICloudServersFlavorRequest flavors] count];
	} else if (section == chefSection) {
        return 1;
    } else if (section == copyPasswordSection) {
        return 1;
    }
	
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == nameSection) {
		return @"Server Name";
	} else if (section == osSection) {
		return @"Choose an Operating System";
	} else if (section == sizeSection) {
		return @"Choose a Size";
	} else if (section == chefSection) {
        return @"Chef Run List";
    } else if (section == copyPasswordSection) {
        return @"Root Password";
    }
	
    return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == chefSection) {
        return @"Example: role[webserver] recipe[drizzle] recipe[nagios]\nThe Chef bootstrap process will output to /var/log/chef.out and /var/log/chef.err on your Cloud Server.";
    } else if (section == sizeSection) {
        return @"Please refer to rackspacecloud.com for Cloud Servers pricing.";
    } else if (section == copyPasswordSection) {
        return @"Your initial root password will also be emailed to the address associated with this account.";
    } else {
        return @"";
    }	
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == sizeSection) {
        return aTableView.rowHeight + 20.0;
    } else {
        return aTableView.rowHeight;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView sizeCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"SizeCell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];		
        slider.frame = CGRectMake(39.0, 11.0, 242.0, slider.frame.size.height);
        [cell addSubview:slider];
    }
    
    // Configure the cell...
	cell.textLabel.text = @" "; //256 MB RAM, 10 GB Disk";
	
    sizeLabel = cell.detailTextLabel;
    
    
    //ASICloudServersFlavor *flavor = [[ASICloudServersFlavorRequest flavors] objectAtIndex:indexPath.row];
    ASICloudServersFlavor *flavor = [[ASICloudServersFlavorRequest flavors] objectAtIndex:(int)slider.value];
    //cell.textLabel.text = flavor.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%iMB RAM, %iGB Disk                             ", flavor.ram, flavor.disk];
    cell.detailTextLabel.textColor = [UIColor blackColor];
    cell.imageView.image = nil;
    //    if (server.flavorId == flavor.flavorId) {
    //        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    //    } else {
    cell.accessoryType = UITableViewCellAccessoryNone;
    //    }
    
    return cell;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView copyPasswordCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CopyPasswordCell";
    
    UISwitchCell *cell = (UISwitchCell *)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UISwitchCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier delegate:self action:@selector(copyPasswordSwitchChanged:) value:NO] autorelease];
		cell.backgroundColor = [UIColor whiteColor];
        cell.uiSwitch.backgroundColor = [UIColor whiteColor];
        cell.uiSwitch.frame = CGRectMake(374.0, 9.0, 94.0, 27.0);
    }
    
    // Configure the cell...
	cell.textLabel.text = @"Copy Root Password After Create";
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];		
    }
    
    static NSString *NameCellIdentifier = @"NameCell";
    
    TextFieldCell *nameCell = (TextFieldCell *)[aTableView dequeueReusableCellWithIdentifier:NameCellIdentifier];
    if (nameCell == nil) {
        nameCell = [[[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NameCellIdentifier] autorelease];
		serverNameTextField = nameCell.textField;
        serverNameTextField.tag = kServerNameTag;
		serverNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
		serverNameTextField.delegate = self;
    }
    
    static NSString *RunListCellIdentifier = @"RunListCell";
    
    TextFieldCell *runListCell = (TextFieldCell *)[aTableView dequeueReusableCellWithIdentifier:RunListCellIdentifier];
    if (runListCell == nil) {
        runListCell = [[[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RunListCellIdentifier] autorelease];
		chefRunListTextField = runListCell.textField;
        chefRunListTextField.placeholder = @"Optional";
        chefRunListTextField.tag = kChefRunListTag;
		chefRunListTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
		chefRunListTextField.delegate = self;
    }
    
	serverNameTextField.text = server.name;
    chefRunListTextField.text = server.chefRunList;
	
    // Configure the cell...
	cell.textLabel.text = @"";
	
    // Set up the cell...
	if (indexPath.section == nameSection) {
		return nameCell;
    } else if (indexPath.section == chefSection) {
		return runListCell;
	} else if (indexPath.section == osSection) {
		/*
         ASICloudServersImage *image = [[ASICloudServersImageRequest images] objectAtIndex:indexPath.row];
         cell.textLabel.text = image.name;
         cell.detailTextLabel.text = @"";
         cell.imageView.image = [ASICloudServersImage iconForImageId:image.imageId];
         if (server.imageId == image.imageId) {
         cell.accessoryType = UITableViewCellAccessoryCheckmark;
         } else {
         cell.accessoryType = UITableViewCellAccessoryNone;
         }
         */
        
        if (lookingAtImages) {
            
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Back to all operating systems...";
                cell.detailTextLabel.text = @"";
                cell.imageView.image = nil;
                cell.accessoryType = UITableViewCellAccessoryNone;
            } else {
                ASICloudServersImage *image = [images objectAtIndex:indexPath.row - 1];
                cell.textLabel.text = image.name;
                cell.imageView.image = [ASICloudServersImage iconForImageName:image.name];
                if (server.imageId == image.imageId) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                
            }
        } else {
            NSDictionary *imageGroups = [ASICloudServersImageRequest imageGroups];
            NSArray *keys = [[imageGroups allKeys] sortedArrayUsingSelector:@selector(compare:)];
            NSString *key = [keys objectAtIndex:indexPath.row];
            cell.textLabel.text = [keys objectAtIndex:indexPath.row];            
            cell.imageView.image = [ASICloudServersImage iconForImageName:key];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
	} else if (indexPath.section == sizeSection) {
        return [self tableView:aTableView sizeCellForRowAtIndexPath:indexPath];
	} else if (indexPath.section == copyPasswordSection) {
        return [self tableView:aTableView copyPasswordCellForRowAtIndexPath:indexPath];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //	if (indexPath.section == osSection) {
    //		ASICloudServersImage *image = [[ASICloudServersImageRequest images] objectAtIndex:indexPath.row];
    //		server.imageId = image.imageId;
    //    } else 
    if (indexPath.section == osSection) {
        if (lookingAtImages && indexPath.row == 0) {
            // tapped the back button, so go back!
            lookingAtImages = NO;
            // TODO: fancy reload
            
            switchingImageView = YES;
            
            NSLog(@"image count: %i", [images count]);            
            NSMutableArray *newIndexPaths = [[NSMutableArray alloc] initWithCapacity:[images count]];
            for (int i = 0; i < [images count] + 1; i++) {
                [newIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:osSection]];
            }            
            [aTableView deleteRowsAtIndexPaths:newIndexPaths withRowAnimation:UITableViewRowAnimationMiddle];
            [newIndexPaths release];
            
            switchingImageView = NO;
            
            NSDictionary *imageGroups = [ASICloudServersImageRequest imageGroups];
            NSMutableArray *oldIndexPaths = [[NSMutableArray alloc] initWithCapacity:[imageGroups count]];
            for (int i = 0; i < [imageGroups count]; i++) {
                [oldIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:osSection]];
            }            
            [aTableView insertRowsAtIndexPaths:oldIndexPaths withRowAnimation:UITableViewRowAnimationMiddle];
            [oldIndexPaths release];
            
            
            
        } else if (lookingAtImages) {
            ASICloudServersImage *image = [images objectAtIndex:indexPath.row - 1];
            server.imageId = image.imageId;
            [aTableView reloadData];            
        } else {
            lookingAtImages = YES;
            NSDictionary *imageGroups = [ASICloudServersImageRequest imageGroups];
            NSArray *keys = [[imageGroups allKeys] sortedArrayUsingSelector:@selector(compare:)];
            NSString *key = [keys objectAtIndex:indexPath.row];
            images = [imageGroups valueForKey:key];
            // TODO: fancy reload
            
            switchingImageView = YES;
            
            NSMutableArray *oldIndexPaths = [[NSMutableArray alloc] initWithCapacity:[imageGroups count]];
            for (int i = 0; i < [imageGroups count]; i++) {
                [oldIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:osSection]];
            }            
            [aTableView deleteRowsAtIndexPaths:oldIndexPaths withRowAnimation:UITableViewRowAnimationMiddle];
            [oldIndexPaths release];
            
            switchingImageView = NO;
            
            NSLog(@"image count: %i", [images count]);            
            NSMutableArray *newIndexPaths = [[NSMutableArray alloc] initWithCapacity:[images count]];
            for (int i = 0; i < [images count] + 1; i++) {
                [newIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:osSection]];
            }            
            [aTableView insertRowsAtIndexPaths:newIndexPaths withRowAnimation:UITableViewRowAnimationMiddle];
            [newIndexPaths release];
        }
        [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
	//[aTableView reloadData];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == serverNameTextField.tag) {
        server.name = textField.text;
    } else if (textField.tag == chefRunListTextField.tag) {
        server.chefRunList = textField.text;
    }
}


#pragma mark -
#pragma mark HTTP Response Handlers

-(void)createServerSuccess:(ASICloudServersServerRequest *)request {
	
	NSLog(@"CREATE %i - %@", [request responseStatusCode], [request responseString]);
    
    if (copyPassword) {
        ASICloudServersServer *newServer = [request server];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:newServer.adminPass];
        [self alert:nil message:[NSString stringWithFormat:@"The root password for %@ has been copied to your pasteboard.", newServer.name]];
    }
    
	[self.serverDetailViewController.serversListViewController loadServers];
    [self hideSpinnerView];
	[self dismissModalViewControllerAnimated:YES];    
}

#pragma mark -
#pragma mark Chef File Prep

- (void)insertCrontab {
    ASICloudServersFile *file = [[ASICloudServersFile alloc] init];
    NSString *content = @"PATH=/usr/sbin:/usr/bin:/sbin:/bin\n@reboot (bash /etc/install-chef && /usr/bin/chef-client -j /etc/chef/first-boot.json && rm /var/spool/cron/crontabs/root)> /var/log/chef.out 2> /var/log/chef.err\n";
    NSLog(@"\ncrontab:\n%@", content);
    
    file.path = @"/var/spool/cron/crontabs/root";
    file.content = content;
    
    [server.files addObject:file];
}

- (void)insertInstallScript {
    ASICloudServersFile *file = [[ASICloudServersFile alloc] init];
    NSString *content = @"#!/bin/bash\n# Customized rc.local for chef installation\n\nif [ ! -f /usr/bin/chef-client ]; then\napt-get update\napt-get install -y ruby ruby1.8-dev build-essential wget libruby-extras libruby1.8-extras\ncd /tmp\nwget http://rubyforge.org/frs/download.php/69365/rubygems-1.3.6.tgz\ntar xvf rubygems-1.3.6.tgz\ncd rubygems-1.3.6\nruby setup.rb\ncp /usr/bin/gem1.8 /usr/bin/gem\ngem install chef ohai --no-rdoc --no-ri --verbose\nfi\nexit 0\n";
    NSLog(@"\ninstall script:\n%@", content);
    
    file.path = @"/etc/install-chef";
    file.content = content;
    
    [server.files addObject:file];
}

- (void)insertClientTemplate {
    ASICloudServersFile *file = [[ASICloudServersFile alloc] init];
    NSString *chefServerUrl;
    NSString *validationClientName;
    
    if (usingOpscodePlatform) {
        chefServerUrl = [NSString stringWithFormat:@"https://api.opscode.com/organizations/%@", chefEndpoint];
        validationClientName = [NSString stringWithFormat:@"%@-validator", chefEndpoint];
    } else {
        chefServerUrl = chefEndpoint;
        validationClientName = @"chef-validator";
    }
    
    NSString *content = [NSString stringWithFormat:@"log_level        :info\nlog_location     STDOUT\nchef_server_url  \"%@\"\nvalidation_client_name \"%@\"\n", chefServerUrl, validationClientName];
    
    NSLog(@"\nclient:\n%@", content);
    
    file.path = @"/etc/chef/client.rb";
    file.content = content;
    
    [server.files addObject:file];
}

- (void)insertValidatorKey {
    ASICloudServersFile *file = [[ASICloudServersFile alloc] init];
    NSLog(@"\nvalidation key:\n%@", chefValidationKey);
    
    file.path = @"/etc/chef/validation.pem";
    file.content = chefValidationKey;
    
    [server.files addObject:file];
}

- (void)insertRunlist {
    ASICloudServersFile *file = [[ASICloudServersFile alloc] init];
    // TODO: use user input
    
    NSLog(@"chefRunList: %@", server.chefRunList);
    
    NSString *content = @"{ \"run_list\": ["; 
    
    NSArray *items = [server.chefRunList componentsSeparatedByString:@" "];
    for (int i = 0; i < [items count]; i++) {
        content = [NSString stringWithFormat:@"%@ \"%@\"", content, [items objectAtIndex:i]];
        if (i < ([items count] - 1)) {
            content = [NSString stringWithFormat:@"%@, ", content];
        }
    }
    
    content = [NSString stringWithFormat:@"%@ ] }", content];
    
    NSLog(@"\n\nrun list:\n\n%@", content);
    
    file.path = @"/etc/chef/first-boot.json";
    file.content = content;
    
    [server.files addObject:file];
}

- (void)addChefFilesToServer {
    [self insertCrontab];
    [self insertInstallScript];
    [self insertClientTemplate];
    [self insertValidatorKey];
    [self insertRunlist];
}

#pragma mark -
#pragma mark Button Handlers

-(void)copyPasswordSwitchChanged:(id)sender {
    UISwitch *uiSwitch = (UISwitch *)sender;
    copyPassword = uiSwitch.on;
    NSLog(@"copy root password on create: %i", copyPassword);
}

-(void)cancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

-(void)saveButtonPressed:(id)sender {	
	if (server.name == nil || [server.name isEqualToString:@""]) {
		[self alert:@"Error" message:@"Please enter a server name."];
	} else if (server.flavorId == 0) {
		[self alert:@"Error" message:@"Please select a flavor."];
	} else if (server.imageId == 0) {
		[self alert:@"Error" message:@"Please select an image."];
	} else {
		// create the server
        
        if (chefBootstrapped && ![chefRunListTextField.text isEqualToString:@""]) {
            [self addChefFilesToServer];            
        }
        
		[self request:[ASICloudServersServerRequest createServerRequest:server] behavior:@"creating your server" success:@selector(createServerSuccess:)];
	}	
}

- (void)dealloc {
	[server release];
	[serverDetailViewController release];
    [navigationItem release];
    [slider release];
    [tableView release];
    [super dealloc];
}


@end

