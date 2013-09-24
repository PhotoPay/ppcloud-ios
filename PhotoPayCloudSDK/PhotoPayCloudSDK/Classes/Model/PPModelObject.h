//
//  PPModelObject.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/12/13.
//  Special thanks to Marko Mihovilić.
//
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PPModelObject : NSObject

/** Deserializes object from dictionary */
- (id)initWithDictionary:(NSDictionary*)dictionary;

/** Serializes object to dictionary */
- (NSMutableDictionary*)dictionaryWithModelObject;

/** Serializes an array of objects */
+ (NSMutableArray*)dictionaryArrayWithModelObjectArray:(NSArray*)objectArray;

/** Creates a string for serializing date object */
+ (NSString*)dictionaryStringWithDate:(NSDate*)date;

/** Initializes a date object from dictionary */
+ (NSDate*)initDate:(id)dictionaryObject;

/** Initializes a date object from dictionary. 
 Default date is set if there is no dictionary present */
+ (NSDate*)initDate:(id)dictionaryObject
        defaultDate:(NSDate*)defaultDate;

/** Initializes a string object from dictionary */
+ (NSString*)initString:(id)dictionaryObject;

/** Initializes a string object from dictionary. 
 Default string is set if there is no dictionary present */
+ (NSString*)initString:(id)dictionaryObject
          defaultString:(NSString*)defaultString;

/** Initializes a number object from dictionary */
+ (NSNumber*)initNumber:(id)dictionaryObject;

/** Initializes a number object from dictionary. 
 Default number is set if there is no dictionary present */
+ (NSNumber*)initNumber:(id)dictionaryObject
          defaultNumber:(NSNumber*)defaultNumber;

/** Initializes a enum from dictionary */
+ (NSUInteger)initEnum:(id)dictionaryObject
             enumTable:(NSDictionary*)enumTable;

/** Initializes a enum from dictionary */
+ (NSUInteger)initEnum:(id)dictionaryObject
             enumTable:(NSDictionary*)enumTable
           defaultEnum:(NSUInteger)defaultEnum;

/** Initializes an object from dictionary */
+ (id)initObject:(id)dictionaryObject
       className:(NSString*)name;

/** Initializes a array object from dictionary */
+ (NSMutableArray*)initArray:(id)dictionaryObject
                   className:(NSString*)name;

/** Initializes a array object from dictionary. 
 Default array is set if there is no dictionary present */
+ (NSMutableArray*)initArray:(id)dictinaryObject
                   className:(NSString*)name
                defaultArray:(NSMutableArray*)defaultArray;

@end