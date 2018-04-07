//
//  UsersTableViewCell.h
//  StackOverFlowUsers
//
//  Created by Joseph Goldberg on 4/5/18.
//  Copyright © 2018 Joseph Goldberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UsersTableViewCell : UITableViewCell
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (nonatomic) IBOutlet UILabel *dateLabel;
@property (nonatomic) IBOutlet UILabel *usernameLabel;
@property (nonatomic) IBOutlet UILabel *locationLabel;
@property (nonatomic) IBOutlet UIImageView *profileImageView;
@end
