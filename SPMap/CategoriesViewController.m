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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    
    [self.navigationController pushViewController:listViewController animated:YES];
    [listViewController release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [category release];
    [super dealloc];
}

@end
