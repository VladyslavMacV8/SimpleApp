//
//  CarLibrery.h
//  MyProject
//
//  Created by Vladyslav Kudelia on 24.10.16.
//  Copyright © 2016 Vladyslav Kudelia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CarLibrary : NSObject

@property (readonly, nonatomic) NSMutableArray *cars;

+ (instancetype)sharedLibrary;
- (void)buildLibraryFromJSON;
- (void)initializeLibrary;
- (void)deleteSQLiteAllData;
- (void)saveDataFromArray:(NSMutableArray *)array;

@end
