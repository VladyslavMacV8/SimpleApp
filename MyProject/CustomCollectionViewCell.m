//
//  CustomCollectionViewCell.m
//  MyProject
//
//  Created by Vladyslav Kudelia on 13.10.16.
//  Copyright © 2016 Vladyslav Kudelia. All rights reserved.
//

#import "CustomCollectionViewCell.h"

@interface CustomCollectionViewCell ()

@end

@implementation CustomCollectionViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    [self rotundity];
}

- (void)rotundity {
    [_photoOutlet layoutIfNeeded];
    _photoOutlet.layer.cornerRadius = _photoOutlet.frame.size.height / 2;
    _photoOutlet.clipsToBounds = true;
}

@end
