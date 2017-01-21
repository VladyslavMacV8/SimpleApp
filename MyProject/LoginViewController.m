//
//  LoginViewController.m
//  MyProject
//
//  Created by Vladyslav Kudelia on 12.10.16.
//  Copyright © 2016 Vladyslav Kudelia. All rights reserved.
//

#import "LoginViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebaseDatabase/FirebaseDatabase.h>
#import <FirebaseStorage/FirebaseStorage.h>

@interface LoginViewController () <FBSDKLoginButtonDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadSpinnerOutlet;

@property (strong, nonatomic) FBSDKLoginButton *loginButton;
@property (strong, nonatomic) UILabel *label;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _loginButton = [FBSDKLoginButton new];
    _loginButton.hidden = true;
    
    [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth * _Nonnull auth, FIRUser * _Nullable user) {
        if (user != nil) {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *homeViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"HomeView"];
            [self presentViewController:homeViewController animated:true completion:nil];
        } else {
            _loginButton.center = self.view.center;
            _loginButton.delegate = self;
            [self.view addSubview:_loginButton];
            _loginButton.hidden = false;
        }
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self animationButton];
}

- (void)animationButton {
    CABasicAnimation *flyRight = [CABasicAnimation animationWithKeyPath:@"position.x"];
    flyRight.fromValue = [NSNumber numberWithDouble:-self.view.bounds.size.width/2];
    flyRight.toValue = [NSNumber numberWithDouble:self.view.bounds.size.width/2];
    flyRight.duration = 0.7;
    
    [_loginButton.layer addAnimation:flyRight forKey:nil];
    
    [self animationInfo];
}

- (void)animationInfo {
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, _loginButton.center.x + 30.0, self.view.frame.size.width, 30.0)];
    _label.backgroundColor = [UIColor clearColor];
    _label.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.textColor = [UIColor blueColor];
    _label.text = @"This is simple chat and now available enter only via Facebook";
    [self.view addSubview:_label];
    
    CABasicAnimation *flyLeft = [CABasicAnimation animationWithKeyPath:@"position.x"];
    flyLeft.fromValue = [NSNumber numberWithDouble:_label.layer.position.x + self.view.frame.size.width];
    flyLeft.toValue = [NSNumber numberWithDouble:_label.layer.position.x];
    flyLeft.duration = 7.0;
    [_label.layer addAnimation:flyLeft forKey:nil];
    
    CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn.fromValue = [NSNumber numberWithDouble:0.0];
    fadeIn.toValue = [NSNumber numberWithDouble:1.0];
    fadeIn.duration = 5.0;
    [_label.layer addAnimation:fadeIn forKey:nil];
}

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    NSLog(@"log in");
    
    _loginButton.hidden = true;
    _label.hidden = true;
    [_loadSpinnerOutlet startAnimating];
    
    if (error != nil) {
        _loginButton.hidden = false;
        [_loadSpinnerOutlet stopAnimating];
    } else if (result.isCancelled) {
        _loginButton.hidden = false;
        [_loadSpinnerOutlet stopAnimating];
    } else {
        FIRAuthCredential *credential = [FIRFacebookAuthProvider credentialWithAccessToken:[FBSDKAccessToken currentAccessToken].tokenString];
        [[FIRAuth auth] signInWithCredential:credential completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
            NSLog(@"log in from firebase");
            
            if (error == nil) {
                FIRStorage *storage = [FIRStorage storage];
                FIRStorageReference *storageReference = [storage referenceForURL:@"gs://my-project-ab779.appspot.com"];
                FIRStorageReference *profileReference = [storageReference child: [NSString stringWithFormat:@"%@/profile_pic_small.jpg", user.uid]];
                NSString *userID = user.uid;
                
                FIRDatabaseReference *databaseReference = [[FIRDatabase database] reference];
                [[[[databaseReference child:@"user_profile"] child:userID] child:@"profile_pic_small"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                    NSString *profilePicture = snapshot.value;
                    if (profilePicture == (NSString *)[NSNull null]) {
                        NSData *imageData = [NSData dataWithContentsOfURL:user.photoURL];
                        if (imageData) {
                            [profileReference putData:imageData metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
                                if (error == nil) {
                                    NSURL *downloadURL = [metadata downloadURL];
                                    [[[databaseReference child:@"user_profile"] child:[NSString stringWithFormat:@"%@/profile_pic_small", userID]] setValue:downloadURL.absoluteString];
                                } else {
                                    NSLog(@"download from url error");
                                }
                            }];
                        }
                        [[[databaseReference child:@"user_profile"] child:[NSString stringWithFormat:@"%@/name",userID]] setValue:user.displayName];
                    } else {
                        NSLog(@"user log is eirly");
                    }
                }];
            }
        }];
    }
}

- (IBAction)backToMainMenuButtonAction:(UIBarButtonItem *)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"MainView"];
    [self presentViewController:viewController animated:true completion:nil];
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {}

@end
