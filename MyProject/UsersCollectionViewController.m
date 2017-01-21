//
//  UsersCollectionViewController.m
//  MyProject
//
//  Created by Vladyslav Kudelia on 13.10.16.
//  Copyright © 2016 Vladyslav Kudelia. All rights reserved.
//

#import "UsersCollectionViewController.h"
#import "ChatViewController.h"
#import "CustomCollectionViewCell.h"
#import <FirebaseDatabase/FirebaseDatabase.h>
#import <FirebaseAuth/FirebaseAuth.h>

@interface UsersCollectionViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (strong, nonatomic) FIRDatabaseReference *databaseReference;
@property (strong, nonatomic) FIRUser *loggedInUser;
@property (strong, nonatomic) NSMutableDictionary *usersDictionary;
@property (strong, nonatomic) NSMutableArray *usersArray;

@end

@implementation UsersCollectionViewController

static NSString * const reuseIdentifier = @"collectionView";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backgroundChat"]];
    imageView.alpha = 0.5;
    
    self.collectionView.backgroundView = imageView;
    
    [_loadingIndicator startAnimating];
    
    _loggedInUser = [[FIRAuth auth] currentUser];
    _databaseReference = [[FIRDatabase database] reference];
    
    _usersDictionary = [NSMutableDictionary new];
    _usersArray = [NSMutableArray new];
    
    [[_databaseReference child:@"user_profile"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        _usersDictionary = snapshot.value;
        [_usersArray removeAllObjects];
        for (NSString *userID in _usersDictionary) {
            NSMutableDictionary *details = [_usersDictionary objectForKey:userID];
            
            NSMutableDictionary *connections = [details objectForKey:@"connections"];
            
            for (NSString *deviceID in connections) {
                NSMutableDictionary *connection = [connections objectForKey:deviceID];
                if ([[connection objectForKey:@"online"] boolValue]) {
                    [details setValue:@true forKey:@"online"];
                } else {
                    if ([[details objectForKey:@"online"] boolValue] != true) {
                        [details setValue:@false forKey:@"online"];
                    }
                }
            }

            if (_loggedInUser.uid != userID) {
                [details setValue:userID forKey:@"uId"];
                [_usersArray addObject:details];
            }
            
            [self.collectionView reloadData];
            
            [_loadingIndicator stopAnimating];
        }
    }];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _usersArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    CustomCollectionViewCell *customCell = (CustomCollectionViewCell *)cell;
    
    NSURL *imageURL = [NSURL URLWithString:_usersArray[indexPath.row][@"profile_pic_small"]];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        
    customCell.photoOutlet.image = [UIImage imageWithData:imageData];
    customCell.photoOutlet.layer.borderWidth = 1.5;
        
    if ([_usersArray[indexPath.row][@"online"] boolValue]) {
        customCell.photoOutlet.layer.borderColor = [UIColor greenColor].CGColor;
    } else {
        customCell.photoOutlet.layer.borderColor = [UIColor redColor].CGColor;
    }
        
    customCell.nameOutlet.text = [_usersArray[indexPath.row][@"name"] componentsSeparatedByString:@" "][0];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
    UINavigationController *navigationController = segue.destinationViewController;
    ChatViewController *chatViewController = [[navigationController viewControllers] firstObject];
    
    chatViewController.senderId = _loggedInUser.uid;
    chatViewController.senderDisplayName = _usersArray[indexPath.row][@"name"];
    chatViewController.receiverData = _usersArray[indexPath.row];
}

@end
