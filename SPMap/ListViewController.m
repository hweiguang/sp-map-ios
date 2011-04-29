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

/*
 The view controller stack within the Navigation Controller curently as
 Map VC <-> Category VC <-> List VC
 By selecting a POI, the next view controller to show is Map VC.
 By popping the current; i.e. List VC and previous view controller; i.e. Category VC
 from the Navigation Controller, we can show the selected POI in the Map VC
 
 This can be achieve by following the examples shown in
 http://stackoverflow.com/questions/410471/how-can-i-pop-a-view-from-a-uinavigationcontroller-and-replace-it-with-another-in
 */

- (void)showAll {
    
    /*
     1. self.navigationController will return nil if self is not currently on the navigation controller's stack. 
     So save it to a local variable before you lose access to it.
     
     2. You must retain (and properly release) self or the object who owns the method you are in will be deallocated, causing strangeness.
     */
    
    [[self retain] autorelease];
    NSMutableArray *controllers = [[self.navigationController.viewControllers mutableCopy] autorelease];
    //  ready to pop list vc
    [controllers removeLastObject];
    //  ready to pop category vc 
    [controllers removeLastObject];   
    
    //  retrieve the existing map vc which is the root vc; index 0
    //  set the selected POI to be displayed
    MapViewController *mapViewController = [controllers objectAtIndex:0];
    mapViewController.selectedLocations = selectedCategory;
    
    //  set the navigation controller's stack
    self.navigationController.viewControllers = controllers;
    
    //  display the map vc
    //    [self.navigationController pushViewController:mapViewController animated: YES];
    
    //    [UIView beginAnimations:nil context:NULL]; 
    //    [UIView setAnimationDuration: 1.5];
    //    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:YES];
    
    //[self.navigationController setViewControllers :controllers animated:YES];
    
    //[UIView commitAnimations];
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
    //Sorting the location array by alphabet
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
/*
 The view controller stack within the Navigation Controller curently as
 Map VC <-> Category VC <-> List VC
 By selecting a POI, the next view controller to show is Map VC.
 By popping the current; i.e. List VC and previous view controller; i.e. Category VC
 from the Navigation Controller, we can show the selected POI in the Map VC
 
 This can be achieve by following the examples shown in
 http://stackoverflow.com/questions/410471/how-can-i-pop-a-view-from-a-uinavigationcontroller-and-replace-it-with-another-in
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     1. self.navigationController will return nil if self is not currently on the navigation controller's stack. 
     So save it to a local variable before you lose access to it.
     
     2. You must retain (and properly release) self or the object who owns the method you are in will be deallocated, causing strangeness.
     */

    [[self retain] autorelease];
    NSMutableArray *controllers = [[self.navigationController.viewControllers mutableCopy] autorelease];
    //  ready to pop list vc
    [controllers removeLastObject];
    //  ready to pop category vc 
    [controllers removeLastObject];   
    
    //  retrieve the existing map vc which is the root vc; index 0
    //  set the selected POI to be displayed
    MapViewController *mapViewController = [controllers objectAtIndex:0];
    Location * aLocation = [locationsincategory objectAtIndex:indexPath.row];
    mapViewController.selectedLocations = aLocation.title;
    
    //  set the navigation controller's stack
    self.navigationController.viewControllers = controllers;
    
    //  display the map vc
//    [self.navigationController pushViewController:mapViewController animated: YES];
    
//    [UIView beginAnimations:nil context:NULL]; 
//    [UIView setAnimationDuration: 1.5];
//    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:YES];
    
    //[self.navigationController setViewControllers :controllers animated:YES];
    
    //[UIView commitAnimations];

}

@end
