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
    self.userArray = jsonDictionary[@"items"];
    return;
}

- (void)makeAPIRequest
{
   
    
    NSURL *url = [NSURL URLWithString:@"https://api.stackexchange.com/2.2/users?site=stackoverflow"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *task =[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        UIAlertController *alert;
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        
        NSLog(@"RESPONSE: %@",response);
        
        if (!error) {
            // Success
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSError *jsonError;
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:0
                                                                               error:&jsonError];
                
                if (jsonError) {
                    // Error Parsing JSON
                    NSLog(@"Error Parsing JSON!");
                    alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                message:jsonError.description
                                                         preferredStyle:UIAlertControllerStyleAlert];
                    
                    [alert addAction:okAction];
                    [self presentViewController:alert
                                       animated:YES
                                     completion:nil];
                    
                } else {
                    // Success Parsing JSON
                    // Log NSDictionary response:
                    //NSLog(@"%@",jsonResponse);
                    [self processDataFromJSON:jsonResponse];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                }
            }  else {
                //Web server is returning an error
                NSLog(@"Web server is returning an error!");
                alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                            message:@"Web server returned an error!"
                                                     preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:okAction];
                [self presentViewController:alert
                                   animated:YES
                                 completion:nil];
            }
        } else {
            // Fail
            NSLog(@"error : %@", error.description);
            alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                        message:error.description
                                                 preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:okAction];
            [self presentViewController:alert
                               animated:YES
                             completion:nil];
        }
    }
                     ];
    [task resume];
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
    UsersTableViewCell *cell = (UsersTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                                                     forIndexPath:indexPath];
    // Configure the cell...
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    
    NSDictionary *tempDictionary = self.userArray[indexPath.row];
    cell.usernameLabel.text = tempDictionary[@"display_name"];
    cell.locationLabel.text = tempDictionary[@"location"];
    NSNumber *timeIntervalNumber = (NSNumber *)tempDictionary[@"last_access_date"];
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[timeIntervalNumber doubleValue]];
    NSString *dateString = [NSDateFormatter localizedStringFromDate:date
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterNoStyle];
    cell.dateLabel.text = dateString;
    
    //Set image to nil and have activityIndicator
    cell.profileImageView.image = nil;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    spinner.frame = cell.profileImageView.frame;
    UIView *parent = [cell.profileImageView superview];
    [parent addSubview:spinner];
    [parent bringSubviewToFront:spinner];
    cell.spinner = spinner;
    
    
    //Get image url as a string
    NSString *imgURLString = (NSString *)tempDictionary[@"profile_image"];
    if (self.imageDictionary[imgURLString]) {
        //load from cache
        cell.profileImageView.image = self.imageDictionary[imgURLString];
        [cell.spinner stopAnimating];
    }
    else
    {
        //download and save to cache
        [self performSelectorInBackground:@selector(downloadImage:) withObject:indexPath];
    }
    
    return cell;
}
- (void)downloadImage:(NSIndexPath *)path
{
    NSDictionary *tempDictionary = self.userArray[path.row];
    NSURL *url = [NSURL URLWithString:tempDictionary[@"profile_image"]];
    UIImage *loadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    //save to cache
    [self.imageDictionary setObject:loadedImage forKey:tempDictionary[@"profile_image"]];
    dispatch_async(dispatch_get_main_queue(), ^{
        UsersTableViewCell *myCell = (UsersTableViewCell *)[self.tableView cellForRowAtIndexPath:path];
        myCell.profileImageView.image = loadedImage;
        [myCell.spinner stopAnimating];
    });
}

@end
