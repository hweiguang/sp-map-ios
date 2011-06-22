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
#import "CustomCellforListVC.h"

@implementation ListViewController

@synthesize selectedCategory;

- (void)dealloc {
    [selectedCategory release];
    [locations release];
    [locationsincategory release];
    [super dealloc];
}

- (void) reloadtableView {
    [self.tableView reloadData];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(reloadtableView) 
                                                 name:@"ReloadDistance" object:nil];
    
    self.contentSizeForViewInPopover = CGSizeMake(320, 480); //For iPad only
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
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
    if (locations == nil)
        locations = [[NSMutableArray alloc] initWithArray:appDelegate.locations];
    
    //Sorting the location array by alphabet
    NSSortDescriptor *alphaDesc = [[NSSortDescriptor alloc] initWithKey:@"title" 
                                                              ascending:YES
                                                               selector:@selector(localizedCaseInsensitiveCompare:)];
    [locations sortUsingDescriptors:[NSMutableArray arrayWithObjects:alphaDesc, nil]];	
    [alphaDesc release]; 
    
    // Setting up selectedLocations array for display
    if (locationsincategory == nil)
        locationsincategory = [[NSMutableArray alloc]init];
    [locationsincategory removeAllObjects];
    
    //loop through all locations and add locations that are in the category
    for (int i=0; i<[locations count]; i++)
    {
        Location *myLocation = [locations objectAtIndex:i];
        if ([myLocation.category isEqualToString:selectedCategory])
            [locationsincategory addObject:myLocation];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [locationsincategory count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    CustomCellforListVC *cell = (CustomCellforListVC*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[CustomCellforListVC alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    Location * aLocation = [locationsincategory objectAtIndex:indexPath.row];
    
    cell.primaryLabel.text = aLocation.title;
    cell.secondaryLabel.text = aLocation.subtitle;
    
    SPMapAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    
    MapViewController *mapViewController = (MapViewController*)[appDelegate.navigationController.viewControllers objectAtIndex:0];
    //If we are getting invalid coordidates for user location do not display distance.
    if (mapViewController.lat == 0 || mapViewController.lon == 0) {
        cell.distanceLabel.text = @"N.A";
        return cell;
    }
    else {
        CLLocation *userLocation = [[CLLocation alloc]initWithLatitude:mapViewController.lat
                                                             longitude:mapViewController.lon];
        
        NSString *distanceString;
        
        for (int i=0; i<[locationsincategory count]; i++) {
            double lat = [aLocation.lat doubleValue];
            double lon = [aLocation.lon doubleValue];;
            
            CLLocation *location = [[CLLocation alloc]initWithLatitude:lat longitude:lon];
            
            CLLocationDistance distance = [userLocation distanceFromLocation:location];
            
            distanceString = [NSString stringWithFormat:@"%.0f", distance];
            distanceString = [distanceString stringByAppendingString:@"m"];
            
            cell.distanceLabel.text = distanceString;
            
            [location release];
        }
        [userLocation release];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SPMapAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    
    MapViewController *mapViewController = (MapViewController*)[appDelegate.navigationController.viewControllers objectAtIndex:0];
    
    Location * aLocation = [locationsincategory objectAtIndex:indexPath.row];
    
    mapViewController.selectedLocations = nil;
    
    //Passing the identity of the selected Location to the map
    mapViewController.selectedLocations = aLocation.identity;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hidePopover" 
                                                            object:nil];
    }
    else {
        [mapViewController loadCallout];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)showAll {
    
    SPMapAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    
    MapViewController *mapViewController = (MapViewController*)[appDelegate.navigationController.viewControllers objectAtIndex:0];
    
    mapViewController.selectedLocations = nil;
    
    //Passing the title of the selected Location to the map
    mapViewController.selectedLocations = selectedCategory;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hidePopover" 
                                                            object:nil];
    }
    else {
        [mapViewController loadCallout];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
