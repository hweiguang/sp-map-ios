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

@synthesize selectedCategory;
@synthesize locations;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [selectedCategory release];
    [locations release];
    [locationsincategory release];
}

- (void)showAll {
    
    MapViewController *mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    
    //Passing the selectedCategory to the map to display all the locations that are in the selected category
    mapViewController.selectedLocations = selectedCategory;
    
    [self.navigationController pushViewController:mapViewController animated:YES];
    [mapViewController release];    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Add a Show All button to display all the pins in this category on the Map
    UIBarButtonItem *showallButton = [[UIBarButtonItem alloc] initWithTitle:@"Show All"
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self 
                                                                     action:@selector(showAll)];
	self.navigationItem.rightBarButtonItem = showallButton;
    [showallButton release];
    
    // Set title to show select category name
    self.title = selectedCategory;
    
    SPMapAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    // Getting locations array from appDelegate
    locations = [[NSMutableArray alloc] initWithArray:appDelegate.locations];
    //Sorting the location array
    NSSortDescriptor *alphaDesc = [[NSSortDescriptor alloc] initWithKey:@"title" 
                                                              ascending:YES
                                                               selector:@selector(localizedCaseInsensitiveCompare:)];
    [locations sortUsingDescriptors:[NSMutableArray arrayWithObjects:alphaDesc, nil]];	
    [alphaDesc release]; 
    alphaDesc = nil;
    
    // Setting up selectedLocations array for display
    locationsincategory = [[NSMutableArray alloc]init];
    //loop through all locations and add locations that are in the category
    for (int i=0; i<[locations count]; i++)
    {
        Location *myLocation = [locations objectAtIndex:i];
        if ([myLocation.category isEqualToString:selectedCategory])
            [locationsincategory addObject:myLocation];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [locationsincategory count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    Location * aLocation = [locationsincategory objectAtIndex:indexPath.row];
    cell.textLabel.text = aLocation.title;
    cell.detailTextLabel.text = aLocation.subtitle;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MapViewController *mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    
    Location * aLocation = [locationsincategory objectAtIndex:indexPath.row];
    
    selectedCategory = aLocation.title;
    
    //Passing the title of the selected Location to the map
    mapViewController.selectedLocations = selectedCategory;
    
    [self.navigationController pushViewController:mapViewController animated:YES];
    [mapViewController release];
}

@end
