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

@synthesize selectedCategories;

- (void) viewDidLoad {
    
    SPMapAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    // Getting category set from appDelegate
    category = [[NSMutableArray alloc] initWithSet:appDelegate.categories];
    // Sort the array by alphabet
    [category sortUsingSelector:@selector(compare:)];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [category count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    //  remove previously selected category; i.e. caching used by tableview for tableviewcell
    cell.accessoryType = UITableViewCellAccessoryNone;
    // Setting textLabel text to show category array
    cell.textLabel.text = [category objectAtIndex:indexPath.row];
    if ([selectedCategories containsObject:[category objectAtIndex:indexPath.row]])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        // Check the selection
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        //Add the category to selectedCategoriesSet
        [selectedCategories addObject:[category objectAtIndex:indexPath.row]];
        
    } else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        // Uncheck the selection
        cell.accessoryType = UITableViewCellAccessoryNone;
        // Reflect deselection in data model
        [selectedCategories removeObject:[category objectAtIndex:indexPath.row]];        
    }
}
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    ListViewController *listViewController = [[ListViewController alloc] initWithNibName:@"ListViewController" bundle:nil];
    //Pass the selected object to the next view
    listViewController.places = [category objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:listViewController animated:YES];
    [listViewController release];
}
*/
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [selectedCategories release];
    [category release];
    [super dealloc];
}

@end
