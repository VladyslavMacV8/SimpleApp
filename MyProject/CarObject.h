//
//  CarObject.h
//  Application
//
//  Created by Vladyslav Kudelia on 12.09.16.
//  Copyright © 2016 Vladyslav Kudelia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CarObject : NSObject

@property (strong, nonatomic) NSString *mark;
@property (strong, nonatomic) NSString *model;
@property (assign, nonatomic) NSInteger year;
@property (strong, nonatomic) UIImage *image;

@end
