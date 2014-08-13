//
//  CTEncodableObject.m
//
//  Created by Charlie Elliott on 2/9/13.
//  Copyright (c) 2013 Charlie Elliott
//

#import "CTEncodableObject.h"
@import ObjectiveC;
@import QuickLook;

#ifdef DEBUG
#define CCEncodableObjectLogKeys 0
#endif

#define ct_PropertyAttributeValueReadonly "R"
#define ct_PropertyAttributeValueWeak "W"

@implementation CTEncodableObject

+ (BOOL)supportsSecureCoding
{
    return NO; // soon...
}

+ (NSSet *)propertyNamesForClass
{
    NSMutableSet *temp = [NSMutableSet set];
    Class superClass = class_getSuperclass(self);
    Method method = class_getClassMethod(superClass, _cmd);
    if(method != NULL)
        [temp unionSet:[superClass propertyNamesForClass]]; //recursively get superclass properties
    
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList(self, &count);
    for(int i = 0; i < count; i++)
    {
        const char *propertyName = property_getName(properties[i]);
        [temp addObject:@(propertyName)];
    }
    free(properties);
    
    return temp;
}

+ (NSSet *)encodableKeys
{
    NSSet *_encodableKeys = objc_getAssociatedObject(self, _cmd);
    if(!_encodableKeys)
    {
        NSMutableSet *temp = [NSMutableSet set];
        Class superClass = class_getSuperclass(self);
        Method method = class_getClassMethod(superClass, _cmd);
        if(method != NULL)
            [temp unionSet:[superClass encodableKeys]]; //recursively get superclass properties
        
        unsigned int count = 0;
        objc_property_t *properties = class_copyPropertyList(self, &count);
        for(int i = 0; i < count; i++)
        {
            objc_property_t prop = properties[i];
            char *readonly = property_copyAttributeValue(prop, ct_PropertyAttributeValueReadonly);
            char *weak = property_copyAttributeValue(prop, ct_PropertyAttributeValueWeak);
            if(!readonly && !weak)
                [temp addObject:@(property_getName(prop))];
            free(readonly);
            free(weak);
        }
        free(properties);
        
        [temp minusSet:[self unencodableKeys]];
        
        _encodableKeys = [temp copy];
        objc_setAssociatedObject(self, _cmd, _encodableKeys, OBJC_ASSOCIATION_RETAIN); //cache the keys on the class
        
#if defined(CCEncodableObjectLogKeys) && CCEncodableObjectLogKeys
        NSLog(@"%@ %@: %@", NSStringFromClass(self), NSStringFromSelector(_cmd), _encodableKeys);
#endif
    }
    
    return _encodableKeys;
}

+ (NSSet *)unencodableKeys
{
    return nil;
}

# pragma mark - Description

- (NSString *)debugDescription
{
    return [self recursiveDescriptionWithDepth:NSIntegerMax];
}

- (NSString *)recursiveDescriptionWithDepth:(NSInteger)depth
{
    NSDictionary *dictionaryRep = [NSDictionary dictionaryWithEncodableObject:self recurseDepth:depth];
    return [[super debugDescription] stringByAppendingString:[dictionaryRep debugDescription]];
}

# pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if(self)
    {
        NSSet *properties = [[self class] encodableKeys];
        for(NSString *key in properties)
        {
            if([aDecoder containsValueForKey:key])
            {
                id value = [aDecoder decodeObjectForKey:key];
                [self setValue:value forKey:key];
            }
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSSet *properties = [[self class] encodableKeys];
    for(NSString *key in properties)
        [aCoder encodeObject:[self valueForKey:key] forKey:key];
}

# pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    id encodableCopy = [[[self class] alloc] init];
    NSSet *properties = [[self class] encodableKeys];
    for(NSString *key in properties)
    {
        id value = [self valueForKey:key];
        [encodableCopy setValue:value forKey:key];
    }
    
    return encodableCopy;
}

# pragma mark - QuickLook

- (id)debugQuickLookObject
{
    return [self debugDescription];
}

@end


@implementation NSDictionary (CTEncodableObject)

+ (NSDictionary *)dictionaryWithEncodableObject:(CTEncodableObject *)object
{
    return [NSDictionary dictionaryWithEncodableObject:object recurseDepth:NSIntegerMax];
}

+ (NSDictionary *)dictionaryWithEncodableObject:(CTEncodableObject *)object recurseDepth:(NSInteger)depth
{
    NSMutableDictionary *temp = [NSMutableDictionary dictionary];
    NSSet *propertyNames = [[object class] encodableKeys];
    
    NSInteger childDepth = depth;
    for(NSString *key in propertyNames)
    {
        id value = [object valueForKey:key];
        if([value isKindOfClass:[CTEncodableObject class]] && --childDepth >= 0)
            value = [NSDictionary dictionaryWithEncodableObject:value];
        [temp setValue:value forKey:key];
    }
    
    return temp;
}

@end
