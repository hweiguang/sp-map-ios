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
    
    //Sorting the location array by alphabet
    NSSortDescriptor *alphaDesc = [[NSSortDescriptor alloc] initWithKey:@"title" 
                                                              ascending:YES
                                                               selector:@selector(localizedCaseInsensitiveCompare:)];
    [searchResults sortUsingDescriptors:[NSMutableArray arrayWithObjects:alphaDesc, nil]];	
    [alphaDesc release]; 
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
        max = CGSizeMake(300, 10000);
    }
    else {
        max = CGSizeMake(748, 10000);   
    }
    
    Location * aLocation = [searchResults objectAtIndex:indexPath.row];
    
    //Return the height
    return ([aLocation.title sizeWithFont:[UIFont boldSystemFontOfSize:20] 
                        constrainedToSize:max 
                            lineBreakMode:UILineBreakModeWordWrap].height) + 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UILabel *text;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        //UILabel for display the search results
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            text = [[[UILabel alloc]initWithFrame:CGRectMake(10,10,300,25)]autorelease]; //frame for iPhone
            text.numberOfLines = 0;
            text.tag = 1;
            text.font = [UIFont boldSystemFontOfSize:20];
            [cell.contentView addSubview:text];
        }
        else {
            text = [[[UILabel alloc]initWithFrame:CGRectMake(10,10,748,25)]autorelease]; //frame for iPad
            text.numberOfLines = 0;
            text.tag = 1;
            text.font = [UIFont boldSystemFontOfSize:20];
            [cell.contentView addSubview:text];
        }
    }
    else {
        text = (UILabel *)[cell.contentView viewWithTag:1];
    }
    
    Location * aLocation = [searchResults objectAtIndex:indexPath.row];
    
    text.text = aLocation.title;
    
    CGRect currentFrame = text.frame;  
    CGSize max;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        max = CGSizeMake(300, 10000);
    }
    else {
        max = CGSizeMake(748, 10000);   
    }
    //Calculating the height needed to display the text in multi line
    CGSize expected = [aLocation.title sizeWithFont:text.font
                                  constrainedToSize:max 
                                      lineBreakMode:UILineBreakModeWordWrap]; 
    currentFrame.size.height = expected.height;
    text.frame = currentFrame;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Search Results";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [mapViewController.searchBar resignFirstResponder];
    
    mapViewController.selectedPoint = [searchResults objectAtIndex:indexPath.row];
    [mapViewController checkMapStatus];
    
    [searchResults removeAllObjects];
    [self.tableView reloadData];
}

@end
