//
//  UsersTableViewController.m
//  StackOverFlowUsers
//
//  Created by Joseph Goldberg on 4/5/18.
//  Copyright © 2018 Joseph Goldberg. All rights reserved.
//

#import "UsersTableViewController.h"
#import "UsersTableViewCell.h"

@interface UsersTableViewController ()
@property (strong, nonatomic) NSArray *userArray;
@property (strong, nonatomic) NSArray *finishedUserArray;
@property (strong, nonatomic) NSMutableDictionary *imageDictionary;

@end

@implementation UsersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.finishedUserArray = [[NSArray alloc] init];
    self.imageDictionary = [[NSMutableDictionary alloc] init];
    [self makeAPIRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)processDataFromJSON:(NSDictionary *)jsonDictionary
{
    self.userArray = [jsonDictionary objectForKey:@"items"];
    return;
}

- (void)makeAPIRequest
{
    static NSString *urlString = @"https://api.stackexchange.com/2.2/users?site=stackoverflow";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        NSLog(@"RESPONSE: %@",response);
        
        if (!error) {
            // Success
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSError *jsonError;
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                
                if (jsonError) {
                    // Error Parsing JSON
                    
                } else {
                    // Success Parsing JSON
                    // Log NSDictionary response:
                    NSLog(@"%@",jsonResponse);
                    [self processDataFromJSON:jsonResponse];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                }
            }  else {
                //Web server is returning an error
            }
        } else {
            // Fail
            NSLog(@"error : %@", error.description);
        }
    }
                     ] resume];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.userArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UsersTableViewCell *cell = (UsersTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    // Configure the cell...
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    
    NSDictionary *tempDictionary = [self.userArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [tempDictionary objectForKey:@"display_name"];
    cell.detailTextLabel.text = [tempDictionary objectForKey:@"location"];
    
    
    
    cell.imageView.image = nil;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    spinner.frame = cell.imageView.frame;
    UIView *parent = [cell.imageView superview];
    [parent addSubview:spinner];
    [parent bringSubviewToFront:spinner];
    cell.spinner = spinner;
    NSString *imgURLString = (NSString *)[tempDictionary objectForKey:@"profile_image"];
    if ([self.imageDictionary valueForKey:imgURLString]) {
        cell.imageView.image = [self.imageDictionary valueForKey:imgURLString];
    }
    else
    {
        [self performSelectorInBackground:@selector(downloadImage:) withObject:indexPath];
    }
    
    
    NSURL *url = [NSURL URLWithString:[tempDictionary objectForKey:@"profile_image"]];
    UIImage *loadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    cell.imageView.image = loadedImage;
    //[spinner stopAnimating];
    
    

    
    return cell;
}
- (void)downloadImage:(NSIndexPath *)path
{
    NSDictionary *tempDictionary = [self.userArray objectAtIndex:path.row];
    NSURL *url = [NSURL URLWithString:[tempDictionary objectForKey:@"profile_image"]];
    UIImage *loadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    dispatch_async(dispatch_get_main_queue(), ^{
        UsersTableViewCell *myCell = (UsersTableViewCell *)[self.tableView cellForRowAtIndexPath:path];
        myCell.imageView.image = loadedImage;
        [myCell.spinner stopAnimating];
    });
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
