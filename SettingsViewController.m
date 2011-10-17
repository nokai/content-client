//
//  SettingsViewController.m
//  content-client
//
//  Created by Brian Pfeil on 10/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "Settings.h"

enum {
	SettingsSectionSync,
    SettingsSectionStorage,
    SettingsSectionDebug,
	CountSettingsSections
};

enum {
	SettingsSectionSyncSync,
    SettingsSectionSyncReset,
	SettingsSectionSyncLastSync,
	SettingsSectionSyncRows
};

enum {
    SettingsSectionStorageUsage,
	SettingsSectionStorageRows
};

enum {
    SettingsSectionDebugLog,
    SettingsSectionDebugRows
};

@interface SettingsViewController()
- (void)done;
@end

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Settings";
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return CountSettingsSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowsInSection = 0;
    switch (section) {
        case SettingsSectionSync: {
            rowsInSection = SettingsSectionSyncRows;
            break;
        }
        case SettingsSectionStorage: {
            rowsInSection = SettingsSectionStorageRows;
            break;
        }
        case SettingsSectionDebug: {
            rowsInSection = SettingsSectionDebugRows;
            break;
        }
        default: {
            break;
        }
    }
    return rowsInSection;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    switch (section) {
        case SettingsSectionSync: {
            title = [Settings string:@"settingsSectionSyncTitle"];
            break;
        }
        case SettingsSectionStorage: {
            title = [Settings string:@"settingsSectionStorageTitle"];
            break;
        }
        case SettingsSectionDebug: {
            title = [Settings string:@"settingsSectionDebugTitle"];
            break;
        }
        default: {
            break;
        }
    }
    
    return  title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.text = @"";
    }
    

    switch (indexPath.section) {
        case SettingsSectionSync: {
            switch (indexPath.row) {
                    case SettingsSectionSyncSync: {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                        cell.textLabel.textAlignment = UITextAlignmentCenter;
                        cell.textLabel.text = [Settings string:@"sync"];
                        break;
                    }
                    case SettingsSectionSyncReset: {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                        cell.textLabel.textAlignment = UITextAlignmentCenter;
                        cell.textLabel.text = [Settings string:@"reset"];
                        break;
                    }                    
            }
            
            break;
        }
        default: {
            break;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.section) {
        case SettingsSectionSync: {
            switch (indexPath.row) {
                case SettingsSectionSyncSync: {
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"sync" object:nil userInfo:nil];
                    [self done];
                    break;
                }
                case SettingsSectionSyncReset: {
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"reset" object:nil userInfo:nil];
                    [self done];
                    break;
                }
                default: {
                    break;
                }
            }
            break;
        }
    }
    
}

- (void)done {
    // for iphone
    //[self dismissModalViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SettingsViewController.dismissPopoverAnimated" object:nil userInfo:nil];
}

@end
