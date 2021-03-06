//
//  CTEncodableObject.h
//
//  Created by Charlie Elliott on 2/9/13.
//  Copyright (c) 2013 Charlie Elliott
//

#import <Foundation/Foundation.h>

@protocol CTEncodableObject <NSCoding, NSCopying>
@end

@interface CTEncodableObject : NSObject <CTEncodableObject>

/**
 Returns a set of property names for this class which are readwrite and have storage.
 */
+ (NSSet *)propertyNamesForClass;

/**
 Returns a set of property names which should not be encoded or copied.
 Default implimentation returns nil.
 This is only needed if you would need to exclude a property which is readwrite and has storage.
 */
+ (NSSet *)unencodableKeys;

/**
 Recurse through all encodable children on the object, printing their debugDescriptions to the specified child-depth
 Default debugDescription uses NSIntegerMax
 */
- (NSString *)recursiveDescriptionWithDepth:(NSInteger)depth;

@end


@interface NSDictionary (CTEncodableObject)

/**
 Builds a nested dictionary from an encodable object, recursively traversing any child properties
 which derive from CTEncodableObject.
 */
+ (NSDictionary *)dictionaryWithEncodableObject:(CTEncodableObject *)object;

/**
 Builds a nested dictionary from an encodable object, recursively traversing any child properties
 which derive from CTEncodableObject up to the specified depth
 */
+ (NSDictionary *)dictionaryWithEncodableObject:(CTEncodableObject *)object recurseDepth:(NSInteger)depth;

@end
