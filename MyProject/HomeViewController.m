//
//  MessagesViewController.m
//  MyProject
//
//  Created by Vladyslav Kudelia on 12.10.16.
//  Copyright © 2016 Vladyslav Kudelia. All rights reserved.
//

#import "HomeViewController.h"
#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebaseStorage/FirebaseStorage.h>
#import <FirebaseDatabase/FirebaseDatabase.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *photoOutlet;
@property (weak, nonatomic) IBOutlet UILabel *nameOutlet;

@property (strong, nonatomic) NSString *deviceID;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    FIRUser *user = [FIRAuth auth].currentUser;
    if (user != nil) {
        _nameOutlet.text = user.displayName;
        
        [self manageConnections:user.uid];
    }
    
    FIRStorage *storage = [FIRStorage storage];
    FIRStorageReference *storageReference = [storage referenceForURL:@"gs://my-project-ab779.appspot.com/"];
    FIRStorageReference *profilePicureReference = [storageReference child: [NSString stringWithFormat:@"%@/profile_picture.jpg", user.uid]];
    
    [profilePicureReference dataWithMaxSize:1 * 1024 * 1024 completion:^(NSData *data, NSError *error){
        if (error != nil) {
            NSLog(@"downloading from storage error");
        } else {
            if (data != nil) {
                _photoOutlet.image = [UIImage imageWithData:data];
                [self rotundity];
            }
        }
    }];
    
    if (_photoOutlet.image == nil) {
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/picture" parameters:@{@"height":@300,@"width":@300,@"redirect":@false} HTTPMethod:@"GET"];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (error == nil) {
                NSMutableDictionary *dictionary = result;
                NSMutableDictionary *data = [dictionary objectForKey:@"data"];
                NSString *urlPicture = [data objectForKey:@"url"];
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlPicture]];
                if (imageData) {
                    [profilePicureReference putData:imageData metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
                        if (error == nil) {
                            [metadata downloadURL];
                        } else {
                            NSLog(@"downloading from url error");
                        }
                    }];
                    _photoOutlet.image = [UIImage imageWithData:imageData];
                    [self rotundity];
                }
            }
        }];
    }
    
    [self animations];
}

- (void)animations {
    CGFloat newOffsetY = -300;
    
    _nameOutlet.alpha = 0.0;
    _photoOutlet.alpha = 0.0;
    
    [UIView animateWithDuration:1.5 animations:^{
        _nameOutlet.center = CGPointMake(_nameOutlet.center.x, _nameOutlet.center.y + newOffsetY);
        _nameOutlet.alpha = 1.0;
    } completion:nil];
    
    [UIView animateWithDuration:1.5 delay:0 options: UIViewAnimationOptionCurveLinear animations:^{
        _photoOutlet.center = CGPointMake(_photoOutlet.center.x, _photoOutlet.center.y + -newOffsetY);
        _photoOutlet.alpha = 1.0;
    } completion:nil];
}

- (void)rotundity {
    [_photoOutlet layoutIfNeeded];
    _photoOutlet.layer.borderWidth = 2;
    _photoOutlet.layer.borderColor = [UIColor blackColor].CGColor;
    _photoOutlet.layer.cornerRadius = _photoOutlet.frame.size.height / 2;
    _photoOutlet.clipsToBounds = true;
}

- (void)manageConnections:(NSString *)userID {
    FIRDatabaseReference *myConnectionReference = [[FIRDatabase database] referenceWithPath:[NSString stringWithFormat:@"user_profile/%@/connections/%@", userID, _deviceID]];
    [[myConnectionReference child:@"online"] setValue:@true];
    [[myConnectionReference child:@"last_online"] setValue:[NSNumber numberWithDouble:[NSDate date].timeIntervalSince1970]];
    
    [myConnectionReference observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        BOOL connected = snapshot.value;
        
        if (connected) {return;}
    }];
}

- (IBAction)logoutButtonAction:(id)sender {
    FIRUser *user = [[FIRAuth auth] currentUser];
    FIRDatabaseReference *myConnectionReference = [[FIRDatabase database] referenceWithPath:[NSString stringWithFormat:@"user_profile/%@/connections/%@", user.uid, _deviceID]];
    [[myConnectionReference child:@"online"] setValue:@false];
    [[myConnectionReference child:@"last_online"] setValue:[NSNumber numberWithDouble:[NSDate date].timeIntervalSince1970]];
    NSError *error;
    [[FIRAuth auth] signOut:&error];
    NSLog(@"log out");
    
    [FBSDKAccessToken setCurrentAccessToken:nil];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"LogView"];
    [self presentViewController:viewController animated:true completion:nil];
}



@end
