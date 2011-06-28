//
//  CategoriesViewController.m
//  SPMap
//
//  Created by Wei Guang on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CategoriesViewController.h"
#import "ListViewController.h"
#import "SPMapAppDelegate.h"

@implementation CategoriesViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.contentSizeForViewInPopover = CGSizeMake(320, 480); //For iPad only
    
    SPMapAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    
    // Getting category set from appDelegate
    if (category == nil)
        category = [[NSMutableArray alloc] initWithSet:appDelegate.categories];
    // Sort the array by alphabet
    [category sortUsingSelector:@selector(compare:)];
    
    if ([category count] == 0) {
        // Listen for updates from appDelegate
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(reloadCategories) 
                                                     name:@"XMLLoaded" object:nil];
    }
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void) reloadCategories {
    SPMapAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    // Getting category set from appDelegate
    category = [[NSMutableArray alloc] initWithSet:appDelegate.categories];
    // Sort the array by alphabet
    [category sortUsingSelector:@selector(compare:)];
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [category count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Setting textLabel text to show category array
    cell.textLabel.text = [category objectAtIndex:indexPath.row];
    // Setting accessoryType
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ListViewController *listViewController = [[ListViewController alloc] initWithNibName:@"ListViewController" 
                                                                                  bundle:nil];
    
    //Pass the selected object to the next view
    listViewController.selectedCategory = [category objectAtIndex:indexPath.row];
    
    UIBarButtonItem *backbutton = [[UIBarButtonItem alloc] init];
	backbutton.title = @"Back";
	self.navigationItem.backBarButtonItem = backbutton;
	[backbutton release];
    
    [self.navigationController pushViewController:listViewController animated:YES];
    [listViewController release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [category release];
    [super dealloc];
}

@end
