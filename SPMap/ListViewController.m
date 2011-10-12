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

- (void)dealloc {
    [selectedCategory release];
    [locations release];
    [locationsincategory release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void) reloadtableView {
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    [self.tableView reloadRowsAtIndexPaths: visiblePaths
                          withRowAnimation: UITableViewRowAnimationNone];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(reloadtableView) 
                                                 name:@"ReloadDistance" object:nil];
    
    self.contentSizeForViewInPopover = CGSizeMake(320, 480); //For iPad only
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
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
        Location *aLocation = [locations objectAtIndex:i];
        if ([aLocation.category isEqualToString:selectedCategory])
            [locationsincategory addObject:aLocation];
    }
    
    if ([locationsincategory count] > 1) {
    //Add a Show All button to display all the pins in this category on the Map
    UIBarButtonItem *showallButton = [[UIBarButtonItem alloc] initWithTitle:@"Show All"
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self 
                                                                     action:@selector(showAll)];
	self.navigationItem.rightBarButtonItem = showallButton;
    [showallButton release];
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
    
    UILabel *primaryLabel;
    UILabel *secondaryLabel;
    UILabel *distanceLabel;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        //Primary Label for the title
        primaryLabel = [[[UILabel alloc]initWithFrame:CGRectMake(10,0,265,25)]autorelease];
        primaryLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
        primaryLabel.tag = 1;
        
        //Secondary Label for the subtitle
        secondaryLabel = [[[UILabel alloc]initWithFrame:CGRectMake(10,25,265,15)]autorelease];
        secondaryLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        secondaryLabel.tag = 2;
        
        //Distance Label for displaying distance from user location to POI
        distanceLabel = [[[UILabel alloc]initWithFrame:CGRectMake(275,14.5,40,15)]autorelease];
        distanceLabel.textAlignment = UITextAlignmentCenter;
        distanceLabel.adjustsFontSizeToFitWidth = YES;
        distanceLabel.tag = 3;
        
        [cell.contentView addSubview:primaryLabel];
        [cell.contentView addSubview:secondaryLabel];
        [cell.contentView addSubview:distanceLabel]; 
    }
    else {
        primaryLabel = (UILabel *)[cell.contentView viewWithTag:1];
        secondaryLabel = (UILabel *)[cell.contentView viewWithTag:2];
        distanceLabel = (UILabel *)[cell.contentView viewWithTag:3];
    }
    
    Location * aLocation = [locationsincategory objectAtIndex:indexPath.row];
    
    primaryLabel.text = aLocation.title;
    secondaryLabel.text = aLocation.subtitle;
    
    SPMapAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    
    MapViewController *mapViewController = (MapViewController*)[appDelegate.navigationController.viewControllers objectAtIndex:0];
    //If we are getting invalid coordidates for user location do not display distance.
    if (mapViewController.lat == 0 || mapViewController.lon == 0) {
        distanceLabel.text = @"N/A";
    }
    else {
        CLLocation *userLocation = [[CLLocation alloc]initWithLatitude:mapViewController.lat
                                                             longitude:mapViewController.lon];
        double lat = [aLocation.lat doubleValue];
        double lon = [aLocation.lon doubleValue];;
        
        CLLocation *location = [[CLLocation alloc]initWithLatitude:lat longitude:lon];
        
        CLLocationDistance distance = [userLocation distanceFromLocation:location];
        
        NSString *distanceString = [NSString stringWithFormat:@"%.0f", distance];
        distanceString = [distanceString stringByAppendingString:@"m"];
        
        distanceLabel.text = distanceString;
        
        [location release];
        [userLocation release];
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hidePopover" 
                                                            object:nil];
    else
        [self.navigationController popToRootViewControllerAnimated:YES];
    
    SPMapAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    
    MapViewController *mapViewController = (MapViewController*)[appDelegate.navigationController.viewControllers objectAtIndex:0];
    
    mapViewController.selectedPoint = [locationsincategory objectAtIndex:indexPath.row];
    
    [mapViewController loadSinglePoint];
    
}

- (void)showAll {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hidePopover" 
                                                            object:nil];
    else
        [self.navigationController popToRootViewControllerAnimated:YES];
    
    SPMapAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    
    MapViewController *mapViewController = (MapViewController*)[appDelegate.navigationController.viewControllers objectAtIndex:0];

    [mapViewController loadCategoryPoints:locationsincategory];
}

@end
