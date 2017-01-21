//
//  CarObject.m
//  Application
//
//  Created by Vladyslav Kudelia on 12.09.16.
//  Copyright © 2016 Vladyslav Kudelia. All rights reserved.
//

#import "CarObject.h"

@implementation CarObject

- (NSComparisonResult)compare:(id)otherObject {
    if ([otherObject isKindOfClass:[self class]]) {
        CarObject *otherCar = otherObject;
        return [_model compare:otherCar.model];
    } else {
        return NSOrderedAscending;
    }
}

@end
