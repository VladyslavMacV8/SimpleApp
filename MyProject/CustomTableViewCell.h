//
//  CustomTableViewCell.h
//  Application
//
//  Created by Vladyslav Kudelia on 12.09.16.
//  Copyright © 2016 Vladyslav Kudelia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *carImage;
@property (weak, nonatomic) IBOutlet UILabel *carMarkLabel;
@property (weak, nonatomic) IBOutlet UILabel *carModelLabel;
@property (weak, nonatomic) IBOutlet UILabel *carYearLabel;

@end
