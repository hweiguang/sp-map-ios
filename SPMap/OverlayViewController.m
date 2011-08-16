//
//  OverlayViewController.m
//  SP Map
//
//  Created by Wei Guang on 5/9/11.
//  Copyright 2011 Singapore Polytechnic. All rights reserved.
//

#import "OverlayViewController.h"
#import "MapViewController.h"
#import "CustomCellforSearch.h"

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize max;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        max = CGSizeMake(310, 10000);
    }
    else {
        max = CGSizeMake(758, 10000);   
    }
    //Return the height
    return ([[searchResults objectAtIndex:indexPath.row] sizeWithFont:[UIFont boldSystemFontOfSize:17.0] 
                                                    constrainedToSize:max 
                                                        lineBreakMode:UILineBreakModeWordWrap].height) + 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    CustomCellforSearch *cell = (CustomCellforSearch*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[CustomCellforSearch alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.text.text = [searchResults objectAtIndex:indexPath.row];
    
    CGRect currentFrame = cell.text.frame;  
    CGSize max;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        max = CGSizeMake(310, 10000);
    }
    else {
        max = CGSizeMake(758, 10000);   
    }
    //Calculating the height needed to display the text in multi line
    CGSize expected = [[searchResults objectAtIndex:indexPath.row] sizeWithFont:cell.text.font
                                                              constrainedToSize:max 
                                                                  lineBreakMode:UILineBreakModeWordWrap]; 
    currentFrame.size.height = expected.height;
    cell.text.frame = currentFrame;
    
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
