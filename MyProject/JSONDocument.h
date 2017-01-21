//
//  JSONDocument.h
//  MyProject
//
//  Created by Vladyslav Kudelia on 28.10.16.
//  Copyright © 2016 Vladyslav Kudelia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONDocument : NSObject

@property (readonly, nonatomic) NSMutableArray *cars;

+ (instancetype)sharedLibrary;
- (void)saveJSONFrom:(NSMutableArray *)array;
- (void)loadJSONFromDefaultData;
- (void)loadJSONFromNewData;

@end
