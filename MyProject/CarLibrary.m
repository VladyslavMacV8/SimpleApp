//
//  CarLibrery.m
//  MyProject
//
//  Created by Vladyslav Kudelia on 24.10.16.
//  Copyright © 2016 Vladyslav Kudelia. All rights reserved.
//

#import "CarLibrary.h"
#import "CarObject.h"
#import "SQLiteManager.h"
#import <sqlite3.h>

@interface CarLibrary ()

@property (strong, nonatomic) NSMutableArray *cars;

@end

@implementation CarLibrary

- (instancetype)init {
    if (self = [super init]) {
        _cars = [NSMutableArray new];
    }
    return self;
}

+ (instancetype)sharedLibrary {
    static CarLibrary *sharedMyManager = nil;
    @synchronized (self) {
        if (sharedMyManager == nil) {
            sharedMyManager = [self new];
        }
    }
    return sharedMyManager;
}

- (void)deleteSQLiteAllData {
    SQLiteManager *sqlite = [SQLiteManager shredManager];
    [sqlite open];
    
    static char *query = "DELETE FROM Cars";
    
    sqlite3_stmt *statement = NULL;
    
    if (sqlite3_prepare_v2(sqlite.database, query, -1, &statement, NULL) != SQLITE_OK) {
        NSLog(@"%s", sqlite3_errmsg(sqlite.database));
    } else {
        sqlite3_step(statement);
    }
    
    sqlite3_finalize(statement);
    [sqlite close];
}

- (void)loadSQLiteDataFromDatabase {
    
}

- (void)saveDataFromArray:(NSMutableArray *)array {
    SQLiteManager *sqlite = [SQLiteManager shredManager];

    [sqlite open];
    
    for (CarObject *car in array) {
        NSNumber *year = @(car.year);
        NSData *data = UIImageJPEGRepresentation(car.image, 1);
        
        static char *sql = "INSERT INTO Cars (image, mark, model, year) VALUES(?, ?, ?, ?)";
        sqlite3_stmt *statement = NULL;
        
        if (sqlite3_prepare_v2(sqlite.database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSLog(@"%s", sqlite3_errmsg(sqlite.database));
        }
        
        sqlite3_bind_blob(statement, 1, [data bytes], (int)[data length], SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [car.mark UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [car.model UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 4, [year intValue]);
        
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"Error %s", sqlite3_errmsg(sqlite.database));
        } else {
            NSLog(@"Inser %lld", sqlite3_last_insert_rowid(sqlite.database));
        }
        sqlite3_finalize(statement);
    }
    [sqlite close];
}

- (void)buildLibraryFromJSON {
    SQLiteManager *sqlite = [SQLiteManager shredManager];
    
    if ([sqlite open] == SQLITE_OK) {
        NSString *sqlStatement = @"CREATE TABLE if not exists Cars (id integer primary key autoincrement, image blob, mark text, model text, year integer)";
        
        sqlite3_exec(sqlite.database, [sqlStatement UTF8String], NULL, NULL, NULL);
        
        NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"car" ofType:@"json"];
        NSURL *jsonURL = [NSURL fileURLWithPath:jsonPath];
        NSData *data = [NSData dataWithContentsOfURL:jsonURL options:NSDataReadingMappedIfSafe error:nil];
        
        NSMutableArray *cars = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        for (NSDictionary *car in cars) {
            NSNumber *year = car[@"year"];
            NSData *data = [[NSData alloc] initWithBase64EncodedString:car[@"image"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
            
            static char *sql = "INSERT INTO Cars (image, mark, model, year) VALUES(?, ?, ?, ?)";
            sqlite3_stmt *statement = NULL;
            
            if (sqlite3_prepare_v2(sqlite.database, sql, -1, &statement, NULL) != SQLITE_OK) {
                NSLog(@"%s", sqlite3_errmsg(sqlite.database));
            }
            
            sqlite3_bind_blob(statement, 1, [data bytes], (int)[data length], SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 2, [car[@"mark"] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3, [car[@"model"] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(statement, 4, [year intValue]);
            
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSLog(@"Error %s", sqlite3_errmsg(sqlite.database));
            } else {
                NSLog(@"Inser %lld", sqlite3_last_insert_rowid(sqlite.database));
            }
            
            sqlite3_finalize(statement);
        }
        
    }
    
    [sqlite close];
}

- (void)initializeLibrary {
    SQLiteManager *sqlite = [SQLiteManager shredManager];
    [sqlite open];
    
    const char *sql = "SELECT * FROM Cars";
    sqlite3_stmt *statement = NULL;
    if (sqlite3_prepare_v2(sqlite.database, sql, -1, &statement, NULL) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSData *data = [NSData dataWithBytes:sqlite3_column_blob(statement, 1) length:sqlite3_column_bytes(statement, 1)];
            char *mark = (char *)sqlite3_column_text(statement, 2);
            char *model = (char *)sqlite3_column_text(statement, 3);
            int year = sqlite3_column_int(statement, 4);
            
            CarObject *car = [CarObject new];
            car.image = [UIImage imageWithData:data];
            car.mark = [NSString stringWithUTF8String:mark];
            car.model = [NSString stringWithUTF8String:model];
            car.year = year;
            
            [_cars addObject:car];
        }
        sqlite3_finalize(statement);
    }
    [sqlite close];
}

@end
