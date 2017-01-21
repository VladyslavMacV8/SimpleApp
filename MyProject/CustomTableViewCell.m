//
//  CustomTableViewCell.m
//  Application
//
//  Created by Vladyslav Kudelia on 12.09.16.
//  Copyright © 2016 Vladyslav Kudelia. All rights reserved.
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    [self rotundity];
}

- (void)rotundity {
    [_carImage layoutIfNeeded];
    _carImage.layer.cornerRadius = _carImage.frame.size.width / 2;
    _carImage.clipsToBounds = true;
}

@end
