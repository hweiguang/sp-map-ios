//
//  OverlayViewController.m
//  SP Map
//
//  Created by Wei Guang on 5/9/11.
//  Copyright 2011 Singapore Polytechnic. All rights reserved.
//

#import "OverlayViewController.h"
#import "MapViewController.h"

@implementation OverlayViewController

@synthesize mapViewController;

- (void)dealloc {
    [mapViewController release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(reloadsearchResults) 
                                                 name:@"reloadsearchResults" object:nil];
}

- (void) reloadsearchResults {
    searchResults = mapViewController.searchResults;
    // Sort the array by alphabet
    [searchResults sortUsingSelector:@selector(compare:)];
    [self.tableView reloadData];
}

- (void) viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }    
    cell.textLabel.text = [searchResults objectAtIndex:indexPath.row];
    // Setting accessoryType
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Search Results";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    mapViewController.selectedLocations = nil;
    mapViewController.selectedLocations = [searchResults objectAtIndex:indexPath.row];
    [mapViewController checkMapStatus];
    [mapViewController.searchBar resignFirstResponder];
    [searchResults removeAllObjects];
    [tableView reloadData];
}

@end
