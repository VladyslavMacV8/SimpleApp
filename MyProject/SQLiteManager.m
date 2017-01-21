//
//  SQLiteManager.m
//  MyProject
//
//  Created by Vladyslav Kudelia on 24.10.16.
//  Copyright © 2016 Vladyslav Kudelia. All rights reserved.
//

#import "SQLiteManager.h"

@interface SQLiteManager ()

@property (strong, nonatomic) NSString *fileName;
@property (assign, nonatomic) sqlite3 *database;
@property (assign, nonatomic) BOOL isOpen;

@end

@implementation SQLiteManager

- (instancetype)init {
    if (self = [super init]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *library = [[fileManager URLForDirectory:NSLibraryDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:false error:nil] URLByAppendingPathComponent:@"library.sqlite"];
        NSLog(@"%@", library);
        
        _fileName = [library absoluteString];
    }
    return self;
}

+ (instancetype)shredManager {
    static SQLiteManager *sharedMyManager = nil;
    @synchronized (self) {
        if (sharedMyManager == nil) {
            sharedMyManager = [self new];
        }
    }
    return sharedMyManager;
}

- (int)open {
    return sqlite3_open([_fileName UTF8String], &_database);
}

- (int)close {
    return sqlite3_close_v2(_database);
}

@end
