//
//  JSONDocument.m
//  MyProject
//
//  Created by Vladyslav Kudelia on 28.10.16.
//  Copyright © 2016 Vladyslav Kudelia. All rights reserved.
//

#import "JSONDocument.h"
#import "CarObject.h"

@interface JSONDocument ()

@property (strong, nonatomic) NSMutableArray *cars;

@end

@implementation JSONDocument

- (instancetype)init {
    if (self = [super init]) {
        _cars = [NSMutableArray new];
    }
    return self;
}

+ (instancetype)sharedLibrary {
    static JSONDocument *sharedMyJSON = nil;
    @synchronized (self) {
        if (sharedMyJSON == nil) {
            sharedMyJSON = [self new];
        }
    }
    return sharedMyJSON;
}

- (void)saveJSONFrom:(NSMutableArray *)array {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentDirectory = [fileManager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:false error:nil];
    NSURL *saveFile = [documentDirectory URLByAppendingPathComponent:@"newCar.json"];

    NSMutableArray *new = [NSMutableArray new];
    for (CarObject *car in array) {
        NSMutableDictionary *objectContainer = [NSMutableDictionary new];
        objectContainer[@"mark"] = car.mark;
        objectContainer[@"model"] = car.model;
        objectContainer[@"year"] = @(car.year);
        objectContainer[@"image"] = [UIImageJPEGRepresentation(car.image, 1.0) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        
        [new addObject:objectContainer];
    }

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:new options:NSJSONWritingPrettyPrinted error:nil];
    [jsonData writeToURL:saveFile atomically:true];

    NSLog(@"save json");
}

- (void)loadJSONFromDefaultData {
    NSLog(@"default");
    NSString *path = [[NSBundle mainBundle] pathForResource:@"car" ofType:@"json"];
    NSURL *jsonFile = [NSURL fileURLWithPath:path];
    NSData *jsonData = [NSData dataWithContentsOfURL:jsonFile];
    
    NSArray *entries = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    for (NSDictionary * entry in entries) {
        CarObject *car = [CarObject new];
        car.mark = entry[@"mark"];
        car.model = entry[@"model"];
        car.year = [entry[@"year"] integerValue];
        NSData *data = [[NSData alloc] initWithBase64EncodedString:entry[@"image"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
        car.image = [UIImage imageWithData: data];
        
        [_cars addObject:car];
    }
}

- (void)loadJSONFromNewData {
    NSLog(@"new");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentDirectory = [fileManager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSURL *saveFile = [documentDirectory URLByAppendingPathComponent:@"newCar.json"];
    
    NSError *error;
    NSString *json = [[NSString alloc] initWithContentsOfURL:saveFile encoding:NSUTF8StringEncoding error:&error];
    
    if (!json) {
        [self loadJSONFromDefaultData];
        [self saveJSONFrom:_cars];
    } else {
        NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
        
        NSArray *entries = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        for (NSDictionary *entry in entries) {
            CarObject *car = [CarObject new];
            car.mark = entry[@"mark"];
            car.model = entry[@"model"];
            car.year = [entry[@"year"] integerValue];
            NSData *data = [[NSData alloc] initWithBase64EncodedString:entry[@"image"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
            car.image = [UIImage imageWithData: data];
            
            [_cars addObject:car];
        }
    }
}

@end
