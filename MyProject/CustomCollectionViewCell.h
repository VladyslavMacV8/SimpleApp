//
//  CustomCollectionViewCell.h
//  MyProject
//
//  Created by Vladyslav Kudelia on 13.10.16.
//  Copyright © 2016 Vladyslav Kudelia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photoOutlet;
@property (weak, nonatomic) IBOutlet UILabel *nameOutlet;

@end
