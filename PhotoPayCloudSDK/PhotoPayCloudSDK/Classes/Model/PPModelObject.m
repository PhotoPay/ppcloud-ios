//
//  PPModelObject.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/12/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPModelObject.h"

@implementation PPModelObject

- (id)initWithDictionary:(NSDictionary*)dictionary {
    return [super init];
}

- (NSMutableDictionary*)dictionaryWithModelObject {
    return [[NSMutableDictionary alloc] init];
}

+ (NSMutableArray*)dictionaryArrayWithModelObjectArray:(NSArray*)objectArray {
    NSMutableArray *dictionary = [[NSMutableArray alloc] init];
    
    for (PPModelObject *object in objectArray) {
        [dictionary addObject:[object dictionaryWithModelObject]];
    }
    
    return dictionary;
}

+ (NSString*)dictionaryStringWithDate:(NSDate*)date {
    return [[NSString alloc] initWithFormat:@"%llu", (unsigned long long)[date timeIntervalSince1970]];
}

+ (NSDate*)initDate:(id)dictionaryObject {
    return [self initDate:dictionaryObject
              defaultDate:nil];
}

+ (NSDate*)initDate:(id)dictionaryObject
        defaultDate:(NSDate *)defaultDate {
    
    if (dictionaryObject == [NSNull null]) {
        return defaultDate;
    }
    
    return [NSDate dateWithTimeIntervalSince1970:[dictionaryObject doubleValue] / 1000];
}

+ (NSString*)initString:(id)dictionaryObject {
    return [self initString:dictionaryObject
              defaultString:nil];
}

+ (NSString*)initString:(id)dictionaryObject
          defaultString:(NSString *)defaultString {
    
    if (dictionaryObject == [NSNull null]) {
        return defaultString;
    }
    
    return dictionaryObject;
}

+ (NSNumber*)initNumber:(id)dictionaryObject {
    return [self initNumber:dictionaryObject
              defaultNumber:nil];
}

+ (NSNumber*)initNumber:(id)dictionaryObject
          defaultNumber:(NSNumber *)defaultNumber {
    
    if (dictionaryObject == [NSNull null]) {
        return defaultNumber;
    }
    
    return dictionaryObject;
}

+ (NSUInteger)initEnum:(id)dictionaryObject
           enumStrings:(NSString *__strong *)enumStrings
      enumStringsCount:(NSUInteger)count {
    
    return [self initEnum:dictionaryObject
              enumStrings:enumStrings
         enumStringsCount:count
              defaultEnum:NSNotFound];
}

+ (NSUInteger)initEnum:(id)dictionaryObject
           enumStrings:(NSString *__strong *)enumStrings
      enumStringsCount:(NSUInteger)count
           defaultEnum:(NSUInteger)defaultEnum {
    
    if (dictionaryObject == [NSNull null]) {
        return defaultEnum;
    }
    
    NSArray *enumStringsArray = [[NSArray alloc] initWithObjects:enumStrings count:count];
    
    NSUInteger resultEnum = [enumStringsArray indexOfObject:dictionaryObject];
    
    if (resultEnum == NSNotFound) {
        return defaultEnum;
    }
    
    return resultEnum;
}

+ (NSMutableArray*)initArray:(id)dictinaryObject
                   className:(NSString *)name {
    
    return [self initArray:dictinaryObject
                 className:name
              defaultArray:[[NSMutableArray alloc] init]];
}

+ (NSMutableArray*)initArray:(id)dictinaryObject
                   className:(NSString *)name
                defaultArray:(NSMutableArray *)defaultArray {
    
    if (dictinaryObject == [NSNull null]) {
        return defaultArray;
    }
    
    Class class = NSClassFromString(name);
    
    if ([class isSubclassOfClass:[PPModelObject class]] == false) {
        [NSException raise:@"Invalid class for array deserialization"
                    format:@"Type of %@ is not a subclass of %@", name, NSStringFromClass([PPModelObject class])];
    }
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    for (NSDictionary *element in dictinaryObject) {
        [objects addObject:[[class alloc] initWithDictionary:element]];
    }
    
    return objects;
}

@end