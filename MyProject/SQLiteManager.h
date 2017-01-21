//
//  SQLiteManager.h
//  MyProject
//
//  Created by Vladyslav Kudelia on 24.10.16.
//  Copyright © 2016 Vladyslav Kudelia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface SQLiteManager : NSObject

@property (readonly, nonatomic) sqlite3 *database;
@property (readonly, nonatomic) BOOL isOpen;

+ (instancetype)shredManager;
- (int)open;
- (int)close;

@end
