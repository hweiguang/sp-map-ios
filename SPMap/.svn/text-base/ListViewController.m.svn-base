//
//  ListViewController.m
//  SP Map
//
//  Created by Wei Guang on 4/14/11.
//  Copyright 2011 Singapore Polytechnic. All rights reserved.
//

#import "ListViewController.h"
#import "MapViewController.h"
#import "Location.h"
#import "SPMapAppDelegate.h"

@implementation ListViewController

@synthesize places;
@synthesize locations;
@synthesize selectedLocations;

- (void)dealloc
{
    [super dealloc];
    [places release];
    [selectedLocations release];
}

- (void)showAll {
    
    MapViewController *mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    mapViewController.selectedCategories = [NSMutableSet setWithObject:places];
    DebugLog(@"ListView SelectedCategory%@",mapViewController.selectedCategories);
    [self.navigationController pushViewController:mapViewController animated:YES];
    [mapViewController release];    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Add a Show All button to display all the pins in this category on the Map
    UIBarButtonItem *showallButton = [[UIBarButtonItem alloc] initWithTitle:@"Show All"
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self 
                                                                     action:@selector(showAll)];
	self.navigationItem.rightBarButtonItem = showallButton;
    [showallButton release];
    
    // Set title to show select category name
    self.title = places;
    
    SPMapAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    
    locations = appDelegate.locations;
    selectedLocations = [[NSMutableArray alloc]init];
    //loop through all locations and add locations that are in the category
    for (int i=0; i<[locations count]; i++)
    {
        Location *myLocation = [locations objectAtIndex:i];
        if ([myLocation.category isEqualToString:places])
        {
            [selectedLocations addObject:myLocation];
             DebugLog(@"selectedlocations%@",[selectedLocations description]);
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [selectedLocations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    Location * aLocation = [selectedLocations objectAtIndex:indexPath.row];
    cell.textLabel.text = aLocation.title;
    cell.detailTextLabel.text = aLocation.subtitle;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     MapViewController *mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
     [self.navigationController pushViewController:mapViewController animated:YES];
     [mapViewController release];
}

@end
