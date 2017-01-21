//
//  MainViewController.m
//  MyProject
//
//  Created by Vladyslav Kudelia on 26.10.16.
//  Copyright © 2016 Vladyslav Kudelia. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UIButton *chatButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *carButtonOutlet;
@property (weak, nonatomic) IBOutlet UILabel *infoLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *nameLabelOutlet;

@property (assign, nonatomic) BOOL maxOne;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _maxOne = true;
    
    [self animationForNameLabel];
    [self animations];
}

- (void)animationForNameLabel {
    _maxOne = !_maxOne;
    
    double fullCircle = 2 * M_PI;
    
    CGFloat upAndDown = _maxOne ? (CGFloat)-1 / 16 * fullCircle : (CGFloat)1 / 16 * fullCircle;
    CGFloat bigAndSmall = _maxOne ? 0.7 : 1.1;
    
    [UIView animateWithDuration:(double)1 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        CGAffineTransform rotation = CGAffineTransformMakeRotation(upAndDown);
        CGAffineTransform scale = CGAffineTransformMakeScale(bigAndSmall, bigAndSmall);
        _nameLabelOutlet.transform = CGAffineTransformConcat(rotation, scale);
    } completion:^(BOOL finished) {
        [self animationForNameLabel];
    }];
}

- (void)animations {
    _chatButtonOutlet.alpha = 0;
    _chatButtonOutlet.transform = CGAffineTransformMakeRotation(-M_PI);
    
    _carButtonOutlet.alpha = 0;
    _carButtonOutlet.transform = CGAffineTransformMakeRotation(M_PI);
    
    _infoLabelOutlet.alpha = 0;
    
    [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _chatButtonOutlet.center = CGPointMake(_chatButtonOutlet.center.x + 500, _chatButtonOutlet.center.y);
        _chatButtonOutlet.alpha = 1;
        _chatButtonOutlet.transform = CGAffineTransformMakeRotation(0);
        
        _carButtonOutlet.center = CGPointMake(_carButtonOutlet.center.x - 500, _carButtonOutlet.center.y);
        _carButtonOutlet.alpha = 1;
        _carButtonOutlet.transform = CGAffineTransformMakeRotation(0);
        
        _infoLabelOutlet.center = CGPointMake(_infoLabelOutlet.center.x, _infoLabelOutlet.center.y);
        _infoLabelOutlet.alpha = 1;
    } completion:nil];
}

@end
