//
//  UserListViewController.m
//  GitHubUsers
//
//  Created by Viktor Gubriienko on 11.05.14.
//  Copyright (c) 2014 Viktor Gubriienko. All rights reserved.
//

#import "UserListViewController.h"
#import "AFJSONRequestOperation.h"
#import "UIImageView+AFNetworking.h"
#import "UIAlertView+Blocks.h"
#import "PopupHelper.h"

@interface UserListViewController ()

<
UITableViewDataSource,
UITableViewDelegate
>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end



@implementation UserListViewController {
    NSArray *_tableData;
    AFJSONRequestOperation *_usersOperation;
}

#pragma mark - VC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Need dalyed load to avoid warning about missing root ctrl. (PopupHelper->second window->issue)
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadUsers];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    
    cell.textLabel.text = _tableData[indexPath.row][@"login"];
    cell.detailTextLabel.text = _tableData[indexPath.row][@"html_url"];
    
    NSString *gravatarID = _tableData[indexPath.row][@"gravatar_id"];
    if ( gravatarID ) {
        [cell.imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@", gravatarID]]
                       placeholderImage:[UIImage imageNamed:@"avatarPlaceholder.png"]];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"avatarPlaceholder.png"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self showUserPage:_tableData[indexPath.row]];

}

#pragma mark - Private

- (void)loadUsers {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://api.github.com/users"]];
    
    __weak typeof(self) weakSelf = self;
    [PopupHelper popupModalSpinner];
    [_usersOperation cancel];
    _usersOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON){
                                                                          
                                                                          [PopupHelper removeModalSpinner];
                                                                          
                                                                          __strong typeof(self) strongSelf = weakSelf;
                                                                          if ( [JSON isKindOfClass:[NSArray class]] ) {
                                                                              strongSelf->_tableData = JSON;
                                                                              [strongSelf->_tableView reloadData];
                                                                          } else {
                                                                              [strongSelf showLoadingError:nil];
                                                                          }
                                                                      }
                                                                      failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                          
                                                                          [PopupHelper removeModalSpinner];
                                                                          
                                                                          __strong typeof(self) strongSelf = weakSelf;
                                                                          [strongSelf showLoadingError:error];
                                                                      }];
    [_usersOperation start];
}

- (void)showLoadingError:(NSError*)error {
    [[[UIAlertView alloc] initWithTitle:@"Users fetch error"
                                message:(error) ? error.localizedDescription : @"Unknown error"
                       cancelButtonItem:[RIButtonItem itemWithLabel:@"Retry"
                                                             action:^{
                                                                 [self loadUsers];
                                                             }]
                       otherButtonItems:nil] show];
}

- (void)showUserPage:(id)userData {
    
    NSURL *userURL = [NSURL URLWithString:userData[@"html_url"]];
    if ( userURL ) {
        [[UIApplication sharedApplication] openURL:userURL];
    } else {
        UIAlertView *alertView = [[UIAlertView new] initWithTitle:@"Bad user URL"
                                                          message:nil
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - Actions

- (IBAction)tapBuy {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/warframe-alerts/id775981113?mt=8"]];
}

@end
